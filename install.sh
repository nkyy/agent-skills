#!/bin/bash
# このリポジトリのスキルと共通ルールを、この PC の Claude Code / Codex から使えるようにする。
#
# 使い方: ./install.sh            （何度実行してもよい）
#
# すること:
#   1. skills/<name> を ~/.claude/skills/<name>（Claude Code）と ~/.agents/skills/<name>（Codex）へリンクする
#   2. ~/.claude/CLAUDE.md の先頭に、共通ルール claude/CLAUDE.md を読み込む 1 行を足す
#      （ファイルがなければ作る。PC ごとのルールはその下に書く）
#
# 同じ名前の実ファイル・実フォルダがすでにある場所はリンクせず、警告だけ出す（上書きして消さないため）。
set -eu
repo=$(cd "$(dirname "$0")" && pwd)

link_skill() { # $1=スキルのフォルダ $2=リンクを置くフォルダ
  local src=$1 dir=$2 dst
  dst=$dir/$(basename "$src")
  mkdir -p "$dir"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "SKIP  $dst （実体があるのでリンクしない）"; return
  fi
  ln -sfn "$src" "$dst"
  echo "LINK  $dst -> $src"
}

for s in "$repo"/skills/*/; do
  s=${s%/}
  link_skill "$s" "$HOME/.claude/skills"
  link_skill "$s" "$HOME/.agents/skills"
done

import="@${repo/#$HOME/~}/claude/CLAUDE.md"   # ~ 表記にして、PC ごとのユーザー名を書き込まない
md=$HOME/.claude/CLAUDE.md
if [ -f "$md" ] && grep -qF "$import" "$md"; then
  echo "OK    $md は共通ルールを読み込み済み"
else
  mkdir -p "$(dirname "$md")"
  tmp=$(mktemp)
  { echo "$import"; echo; [ -f "$md" ] && cat "$md"; } > "$tmp"
  mv "$tmp" "$md"
  echo "EDIT  $md の先頭に $import を足した"
fi
