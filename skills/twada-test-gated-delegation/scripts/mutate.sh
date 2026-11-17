#!/usr/bin/env bash
# 実装をわざと壊し（変異）、対応するテストが落ちるかを数える。元の作業ツリーは触らない。
set -u
usage() {
  cat <<'EOF'
usage: RUN_ONE_CMD=... RAN_REGEX=... bash mutate.sh <repo> <mutations-file>

  <mutations-file> の各行（# で始まる行と空行は無視）:
      <テストID>|<変異の説明>|<ファイル>|<実行回数>|<perl -0pi の置換式>
  置換式は最後の欄で、行末までをそのまま読む（式の中に | を含めてよい）。
  例: t12_relative|入力パスをそのまま保存|src/main.rs|1|s/location: root,/location: path.into(),/

  RUN_ONE_CMD  1つのテストを実行するコマンド。{test} がテストIDに置き換わる
               例(cargo): cargo test --test port_tests {test} -- --exact
               （-q を付けるとテスト名の行が出ず、RAN_REGEX で走ったことを確認できない）
  RAN_REGEX    出力中に「そのテストが実際に走った」ことを示す正規表現。{test} を置き換える
               例(cargo): ^test {test} \.\.\. (ok|FAILED)$
  BUILD_CMD    変異後のビルド確認（既定: true）
  対象コミットは HEAD（未コミットのテストは一時 worktree に含まれず NO-TEST-RAN になる。先にコミットする）。結果: 検出 k/n 回 / NOT-APPLIED（置換が当たらない）/ BUILD-ERR / NO-TEST-RAN
  「検出 0/n」は、テストが弱いか、結果が変わらない変異（等価変異）。コードを読んで区別する。
EOF
}
[ "${1:-}" = --help ] || [ $# -ne 2 ] && { usage; [ "${1:-}" = --help ]; exit $?; }
: "${RUN_ONE_CMD:?RUN_ONE_CMD を設定してください（--help）}" "${RAN_REGEX:?RAN_REGEX を設定してください（--help）}"
BUILD_CMD=${BUILD_CMD:-true}
REPO=$1 SPEC=$2

while IFS='|' read -r test name file runs expr; do
  case "$test" in ''|\#*) continue;; esac
  runs=${runs:-1}
  wt=$(mktemp -d)/wt
  git -C "$REPO" worktree add -q --detach "$wt" HEAD </dev/null >/dev/null 2>&1
  cp "$wt/$file" "$wt/$file.orig"
  perl -0pi -e "$expr" "$wt/$file"
  res=
  if cmp -s "$wt/$file" "$wt/$file.orig"; then res=NOT-APPLIED
  elif ! (cd "$wt" && bash -c "$BUILD_CMD" </dev/null >/dev/null 2>&1); then res=BUILD-ERR
  else
    killed=0 ran=0 cmd=${RUN_ONE_CMD//\{test\}/$test} re=${RAN_REGEX//\{test\}/$test}
    for _ in $(seq "$runs"); do
      out=$(cd "$wt" && bash -c "$cmd" </dev/null 2>&1); rc=$?
      grep -qE "$re" <<<"$out" || { res=NO-TEST-RAN; break; }
      ran=$((ran + 1)); [ $rc -ne 0 ] && killed=$((killed + 1))
    done
    [ -z "$res" ] && res="検出 $killed/$ran 回"
  fi
  printf '%-40s %-40s %s\n' "$test" "$name" "$res"
  git -C "$REPO" worktree remove --force "$wt" >/dev/null 2>&1
done < "$SPEC"
