#!/usr/bin/env bash
# test: コミットを一時 worktree で実際に再実行し、本当に Red だったかを判定する。
# feat:/refactor: の判定は check_feat_scope.sh が行う（テストを先にまとめてコミットする流れでは、
# 途中の feat で後の項目のテストが赤いのは正常なので、全テスト Green を条件にできない）。
# エージェントの自己申告（コミット本文）は証拠として使わない。
set -u
usage() {
  cat <<'EOF'
usage: BUILD_CMD=... TEST_CMD=... bash check_red_green.sh <repo> <base-commit>

  <base-commit> の次から HEAD までの各コミットを判定する。
  test:   TEST_CMD が失敗し、かつ BUILD_CMD は成功（ビルド失敗だけの Red は認めない）
  test(migrate):  判定しない（既存の不変条件を新しい経路に付け替えたテスト。緑が正常。変異で有効性を示す）
  それ以外  判定しない（feat:/refactor: は check_feat_scope.sh で判定する）

  LIST_CMD   （任意）テスト一覧を出すコマンド。指定すると、新しいテストを1件も追加していない
             test: コミット（削除・修正のみ）を「追加なし」として Red の検査から外す
  BUILD_CMD  テストのビルドだけを行うコマンド（例: "cargo test --no-run -q" / "go vet ./..."）
  TEST_CMD   全テストを実行するコマンド（例: "cargo test -q" / "go test -count=1 ./..."）
  各コマンドは worktree のルートで bash -c として実行する。
EOF
}
[ "${1:-}" = --help ] || [ $# -ne 2 ] && { usage; [ "${1:-}" = --help ]; exit $?; }
: "${BUILD_CMD:?BUILD_CMD を設定してください（--help）}" "${TEST_CMD:?TEST_CMD を設定してください（--help）}"
REPO=$1 BASE=$2
WT=$(mktemp -d)/wt
git -C "$REPO" worktree add -q --detach "$WT" "$BASE" >/dev/null || exit 1
trap 'git -C "$REPO" worktree remove --force "$WT" >/dev/null 2>&1' EXIT

printf '%-9s %-9s %-5s %-5s %s\n' commit type build test subject
for sha in $(git -C "$REPO" rev-list --reverse "$BASE"..HEAD); do
  subj=$(git -C "$REPO" log -1 --format=%s "$sha"); type=${subj%%:*}
  [ "$type" = "test(migrate)" ] && type=migrate || type=${type%%(*}
  case "$type" in test) ;; *) printf '%-9s %-9s %-5s %-5s %s\n' "${sha:0:8}" "$type" - - "$subj"; continue;; esac
  if [ -n "${LIST_CMD:-}" ]; then
    git -C "$WT" checkout -q --detach "$sha^"; before=$(cd "$WT" && bash -c "$LIST_CMD" 2>/dev/null | sort)
    git -C "$WT" checkout -q --detach "$sha"; after=$(cd "$WT" && bash -c "$LIST_CMD" 2>/dev/null | sort)
    if [ -z "$(comm -13 <(echo "$before") <(echo "$after") | grep .)" ]; then
      printf '%-9s %-9s %-5s %-5s %s  [%s]\n' "${sha:0:8}" "$type" - - "$subj" "追加なし（削除・修正のみ）: Red の検査対象外"
      continue
    fi
  fi
  git -C "$WT" checkout -q --detach "$sha"
  (cd "$WT" && bash -c "$BUILD_CMD" >/dev/null 2>&1) && build=ok || build=NG
  (cd "$WT" && bash -c "$TEST_CMD" >/dev/null 2>&1) && res=PASS || res=FAIL
  verdict=ok
  { [ "$res" = FAIL ] && [ "$build" = ok ]; } || verdict="NG(Red ではない: test=$res build=$build)"
  printf '%-9s %-9s %-5s %-5s %s  [%s]\n' "${sha:0:8}" "$type" "$build" "$res" "$subj" "$verdict"
done
