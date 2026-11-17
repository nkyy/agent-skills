#!/bin/bash
# 経緯を知らない小さめのモデル（Codex の gpt-6-luna）にコミットを読ませ、
# Why / What / Why not が「書かれた情報だけで」読み取れるかを確かめる。
# 使い方: check_why_luna.sh <repo> <base> [commit...]   （commit 省略時は base..HEAD）
# 判定は「根拠の引用」で行う。Luna が引用した文が、実際にメッセージ・差分にあるかを
# 機械的に照合する（小さいモデルが Why をそれらしく作っても合格にしないため）。
set -u
repo=$1; base=$2; shift 2
model=${LUNA_MODEL:-gpt-6-luna}
work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
commits=${*:-$(git -C "$repo" rev-list --reverse "$base..HEAD")}
for c in $commits; do
  subject=$(git -C "$repo" log -1 --format=%s "$c")
  git -C "$repo" log -1 --format=%B "$c" > "$work/msg"
  git -C "$repo" show --format= --unified=3 "$c" | head -n "${DIFF_LINES:-600}" > "$work/diff"
  cat > "$work/prompt" <<P
あなたはこのリポジトリの経緯を何も知らない読み手です。下のコミットメッセージと差分だけを読み、
次の JSON だけを出力してください（前後に文章やコードフェンスを付けない）。

{"why": "なぜこの変更をしたか（読み取れなければ空文字）",
 "why_quote": "その根拠になる文をコミットメッセージから一字一句そのまま引用（なければ空文字）",
 "tests": [{"name": "差分で追加・改名されたテストの名前", "what": "名前だけから読み取れる保証内容", "clear": true}],
 "comments": [{"comment": "差分で追加されたコードコメントの本文をそのまま", "verdict": "why_not か restates_code か other"}]}

規則:
- why と why_quote はコミットメッセージだけを根拠にする。差分から理由を推測して補わない。
- tests の what はテスト名だけから書き、本体は読まない。名前だけで保証内容が分からなければ clear を false。
- verdict: 「何をしなかったか・なぜ別のやり方をしないか」を説明していれば why_not、
  コードがしていることを言い直しているだけなら restates_code、それ以外（TODO など）は other。

=== コミットメッセージ ===
$(cat "$work/msg")
=== 差分 ===
$(cat "$work/diff")
P
  if ! codex exec -C "$repo" -s read-only -m "$model" -o "$work/out" "$(cat "$work/prompt")" < /dev/null > "$work/log" 2>&1; then
    echo "ERROR   ${c:0:8} $subject （codex exec 失敗: $(tail -1 "$work/log")）"; continue
  fi
  python3 - "$work/out" "$work/msg" "$work/diff" "${c:0:8}" "$subject" <<'PY'
import json, re, sys
out, msg, diff, c, subject = sys.argv[1], open(sys.argv[2]).read(), open(sys.argv[3]).read(), sys.argv[4], sys.argv[5]
norm = lambda s: re.sub(r'\s+', ' ', s).strip()
raw = open(out).read().strip()
m = re.search(r'\{.*\}', raw, re.S)
try: d = json.loads(m.group(0))
except Exception: print(f"ERROR   {c} {subject} （JSON を読めない）"); sys.exit()
q = norm(d.get('why_quote') or '')
why_ok = bool(q) and q in norm(msg)
print(f"{'ok' if why_ok else 'NO-WHY':<7} {c} {subject}")
print(f"        Why: {d.get('why') or '（読み取れない）'}" + ("" if why_ok else f"  ← 引用が本文にない: {q[:60]!r}" if q else ""))
added = norm(' '.join(l[1:] for l in diff.splitlines() if l.startswith('+')))
for t in d.get('tests') or []:
    if norm(t.get('name','')) not in added: continue   # 差分にない名前は捏造として捨てる
    mark = 'What  ' if t.get('clear') else 'VAGUE '
    print(f"        {mark}{t['name']}: {t.get('what','')}")
for cm in d.get('comments') or []:
    if norm(cm.get('comment','')) not in added: continue
    if cm.get('verdict') == 'restates_code':
        print(f"        HOW-COMMENT {cm['comment'][:80]!r}（コードの言い直し。Why not に直すか消す）")
PY
done
