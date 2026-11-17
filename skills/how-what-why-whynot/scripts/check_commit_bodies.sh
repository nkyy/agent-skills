#!/bin/bash
# 機械的な確認: feat/fix/refactor/perf/test のコミットに本文（Why）があるか。
# 使い方: check_commit_bodies.sh <repo> <base>   （base..HEAD を確かめる）
# 判定がぶれない欠落（本文がない）だけを見る。中身の質は check_why_luna.sh で確かめる。
set -u
repo=$1; base=$2; fail=0
for c in $(git -C "$repo" rev-list --reverse "$base..HEAD"); do
  subject=$(git -C "$repo" log -1 --format=%s "$c")
  type=$(printf '%s' "$subject" | sed -nE 's/^([a-z]+)(\([^)]*\))?!?:.*/\1/p')
  case "$type" in feat|fix|refactor|perf|test) ;; *) continue ;; esac
  # 本文から空行と trailer（Co-Authored-By: など）を除いた行数
  body=$(git -C "$repo" log -1 --format=%b "$c" | grep -vE '^[[:space:]]*$' | grep -vE '^[A-Za-z-]+: ' | wc -l | tr -d ' ')
  if [ "$body" -eq 0 ]; then echo "NO-WHY  ${c:0:8} $subject"; fail=1; else echo "ok      ${c:0:8} $subject"; fi
done
exit $fail
