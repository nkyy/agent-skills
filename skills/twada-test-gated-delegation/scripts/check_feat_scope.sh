#!/usr/bin/env bash
# 各コミットで緑のテストを実測し、feat: Tn で新しく緑になったのが Tn だけかを判定する。
# 先回り実装（後の項目まで一度に実装する）、緑の後退、refactor: での振る舞い変化を検出する。
set -u
usage() {
  cat <<'EOF'
usage: PASSED_CMD=... LIST_CMD=... bash check_feat_scope.sh <repo> <base-commit>

  PASSED_CMD  全テストを実行し、緑になったテストの ID を1行ずつ出すコマンド
              例(cargo): cargo test 2>&1 | sed -nE 's/^test (t[0-9]+)_[a-z0-9_]* \.\.\. ok$/\1/p'
              例(go):    go test -count=1 -v ./... 2>&1 | sed -nE 's/^--- PASS: Test(T[0-9]+).*/\1/p'
  LIST_CMD    テストの一覧を出すコマンド（1件も無ければ NG とするため）
              例(cargo): cargo test -- --list 2>/dev/null | grep ': test$'
  ITEM_PREFIX テストリスト項目の接頭辞。コミット件名 "feat: <ITEM_PREFIX><n>" を認識する（既定: T）
  ID_FORMAT   その n からテスト ID を作る printf 書式（既定: t%02d。例: ITEM_PREFIX=C なら c%02d）
EOF
}
[ "${1:-}" = --help ] || [ $# -ne 2 ] && { usage; [ "${1:-}" = --help ]; exit $?; }
: "${PASSED_CMD:?PASSED_CMD を設定してください（--help）}" "${LIST_CMD:?LIST_CMD を設定してください（--help）}"
ID_FORMAT=${ID_FORMAT:-t%02d}
ITEM_PREFIX=${ITEM_PREFIX:-T}
REPO=$1 BASE=$2
WT=$(mktemp -d)/wt
git -C "$REPO" worktree add -q --detach "$WT" "$BASE" >/dev/null || exit 1
trap 'git -C "$REPO" worktree remove --force "$WT" >/dev/null 2>&1' EXIT

listed() { (cd "$WT" && bash -c "$LIST_CMD" 2>/dev/null); }
green() {
  if [ -z "$(listed)" ]; then echo NO-TESTS; return; fi
  (cd "$WT" && bash -c "$PASSED_CMD" 2>/dev/null) | sort -u
}
prev=$(green)
echo "base $(git -C "$REPO" log -1 --format=%h "$BASE"): green=[$(echo $prev)]"
for sha in $(git -C "$REPO" rev-list --reverse "$BASE"..HEAD); do
  subj=$(git -C "$REPO" log -1 --format=%s "$sha"); type=${subj%%:*}; type=${type%%(*}
  git -C "$WT" checkout -q --detach "$sha"
  now=$(green)
  if [ "$now" = NO-TESTS ]; then echo "${sha:0:8} $subj  [NG: テストが1件も無い]"; continue; fi
  added=$(comm -13 <(echo "$prev") <(echo "$now") | grep . | tr '\n' ' ')
  lost=$(comm -23 <(echo "$prev") <(echo "$now") | grep .)
  # 緑が減ったテストを「テストごと削除された」と「赤くなった」に分ける
  list_now=$(listed)
  removed=$(for id in $lost; do grep -q "$id" <<<"$list_now" || echo "$id"; done | tr '\n' ' ')
  turned_red=$(for id in $lost; do grep -q "$id" <<<"$list_now" && echo "$id"; done | tr '\n' ' ')
  lost=$(tr '\n' ' ' <<<"$lost")
  verdict=ok
  [ -n "${turned_red// }" ] && verdict="NG: 緑が赤に戻った($turned_red)"
  [ -n "${removed// }" ] && verdict="$verdict / 要確認: テストが削除された($removed) 仕様変更による削除か"
  if [ "$type" = feat ]; then
    n=$(sed -nE "s/^feat(\\([^)]*\\))?: ${ITEM_PREFIX}([0-9]+).*/\\2/p" <<<"$subj")
    if [ -n "$n" ]; then
      target=$(printf "$ID_FORMAT" "$((10#$n))")
      extra=$(tr ' ' '\n' <<<"$added" | grep . | grep -vx "$target" | tr '\n' ' ')
      [ -n "$extra" ] && verdict="$verdict / 要確認: 対象外も緑になった($extra) 先回り実装の疑い"
      grep -qw "$target" <<<"$now" || verdict="$verdict / NG: 対象 $target が緑でない"
    fi
  fi
  # コード（テスト以外の非文書ファイル）を変えていないのに結果が変わったら、不安定なテストを疑う
  code_changed=$(git -C "$REPO" diff --name-only "$sha^" "$sha" | grep -vE '\.(md|txt)$|^docs/' | head -1)
  if [ -z "$code_changed" ] && { [ -n "${added// }" ] || [ -n "${lost// }" ]; }; then
    verdict="$verdict / 要確認: コードの変更なしに結果が変わった（不安定なテストの疑い。同じコミットで繰り返し実行して確かめる）"
  fi
  [ "$type" = refactor ] && [ -n "$added" ] && verdict="$verdict / 要確認: refactor で緑が増えた（振る舞いが変わった疑い）"
  echo "${sha:0:8} $subj  +[$added] -[$lost]  [$verdict]"
  prev=$now
done
