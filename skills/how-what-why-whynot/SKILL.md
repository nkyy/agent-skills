---
name: how-what-why-whynot
description: Use when writing or reviewing commits, tests, or code comments, accepting an agent's commit range, or when a commit has no body, a test name does not say what it guarantees, or a comment restates the code. Checks that each kind of information lives in its proper place: code says How, tests say What, commit logs say Why, comments say Why not.
argument-hint: "[リポジトリ] [base]（base..HEAD を確かめる）"
disable-model-invocation: false
---

# 情報の置き場所: How / What / Why / Why not

| 置き場所 | 書くこと | 例 |
|---|---|---|
| コード | **How**（どうやるか） | 読めば手順が分かる名前と構造。コメントで補わない |
| テスト | **What**（何を保証するか） | テスト名だけで保証内容が分かる。`test1` は不可 |
| コミットログ | **Why**（なぜ変えたか） | 本文に理由を書く。件名だけのコミットは不可 |
| コメント | **Why not**（なぜ別のやり方をしないか） | 「unwrap ではなく None: 壊れた設定で起動を止めないため」。コードの言い直しは不可 |

判断の基準は「経緯を知らない読み手が、そこに書かれた情報だけで分かるか」。会話・チケット・レビューの中にしかない理由は、残っていないのと同じ。

## 書くとき

- `feat`・`fix`・`refactor`・`perf`・`test` のコミットには、本文に Why を書く（何を変えたかは差分が語る）。
- コメントを書きたくなったら、まず名前と構造で How を表せないか考える。残すコメントは Why not だけ。
- エージェントに作業させる指示書には、この表を入れ、コミット本文に Why を求める。

## 確かめるとき（2段）

1. **機械的な確認**（速く、結果がぶれない）: 本文のないコミットを検出する。
   ```
   scripts/check_commit_bodies.sh <repo> <base>
   ```
2. **読み手のテスト**（経緯を知らない小さめのモデルに読ませる）: Codex の `gpt-6-luna` にコミットごとのメッセージと差分を読ませ、Why・テスト名の What・コメントの Why not が読み取れるかを確かめる。
   ```
   scripts/check_why_luna.sh <repo> <base> [commit...]
   ```
   - **判定は「根拠の引用」で行う。** 小さいモデルは、書かれていない Why を差分からそれらしく作ることがある。Luna が引用した文が実際にメッセージにあるかをスクリプトが照合し、なければ `NO-WHY` にする。
   - 出力: `NO-WHY`（Why が残っていない）、`VAGUE`（テスト名から保証内容が分からない）、`HOW-COMMENT`（コードの言い直し）。
   - モデルは `LUNA_MODEL`、差分の上限行数は `DIFF_LINES`（既定 600）で変えられる。

指摘は書き直しの依頼として返す。履歴の書き換え（rebase での本文追加）は、共有前のブランチで、ユーザーが了承した場合だけにする。

## 使う場面

- エージェントの成果物の受け入れ検査（`twada-test-gated-delegation` の受け入れ検査の一部として、feat の範囲に1回回す）。
- 自分でコミットする前の見直し。
- コードレビュー。
