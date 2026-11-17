# agent-skills

Claude Code と Codex で使う、一般的なスキルと共通ルール。どの PC でも同じ進め方で開発できるようにするためのもの。

案件のナレッジ・機密・個人の事業に関わるものは入れない（それは各 PC の `~/.claude/skills/` に直接置く）。

## 中身

| スキル | 使う場面 |
|---|---|
| `how-what-why-whynot` | コミット・テスト・コメントに、それぞれ Why / What / Why not が書けているか確かめる |
| `twada-test-gated-delegation` | TDD でエージェントに実装を任せ、テストと差分を検査する |
| `acceptance-review` | 作者とは別のレビュアーが、実物を見て採否を言い切る |
| `applying-laws-of-ux` | 画面を作る・直すときに Laws of UX を当てる |
| `imozuru` | 知らない分野を、用語・人・場から芋づる式にたどって原文を集める |

`claude/CLAUDE.md` は、どの PC でも使う共通ルール。

## 入れ方

```sh
git clone https://github.com/nkyy/agent-skills.git ~/agent-skills
~/agent-skills/install.sh
```

`install.sh` は次をする（何度実行してもよい）。

- `skills/*` を `~/.claude/skills/`（Claude Code）と `~/.agents/skills/`（Codex）にリンクする
- `~/.claude/CLAUDE.md` の先頭に `@<clone 先>/claude/CLAUDE.md` を足し、共通ルールを読み込ませる。PC ごとのルールはその下に書く

更新は `git pull` だけでよい（リンクなので入れ直しは要らない）。新しいスキルを足したときだけ `install.sh` をもう一度実行する。
