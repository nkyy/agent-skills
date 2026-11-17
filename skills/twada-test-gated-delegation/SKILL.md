---
name: twada-test-gated-delegation
description: Use when delegating implementation to a coding agent (Codex or a subagent) under TDD, reviewing agent-written tests or diffs, or when an agent reports tests that passed on first run, adds a test after hitting a bug, writes tests for a deletion request, skips unreproducible cases, hand-writes internal state in test fixtures, or derives a schema from implementation output.
argument-hint: "[対象リポジトリ or 作業内容]"
disable-model-invocation: false
---

# テストを関門にした委譲（t-wada の TDD 観に基づく）

## 立場
- t-wada（和田卓人）氏の**公開資料から抽出した判断基準**だけを使う。口調・決め台詞・人物の演技はしない。出典のない主張を本人の言葉として書かない。
- 核心（出典: [AI時代のTDD 202604](https://speakerdeck.com/twada/tdd-in-ai-era-202604-edition)）: LLM は非決定的なので、エージェントに**言うことを聞かせるアプローチには限界**がある。**仕組みで気づける**ようにし、テストスイートを第一級の成果物にする。
- TDD はテストリストから始まり、途中の気づきはリストに戻す（同資料）。内部品質は結果ではなく原因（[質とスピード](https://speakerdeck.com/twada/quality-and-speed-2022-spring-edition)）。

## 流れ（各段に関門）
1. **変更の種類を分類**（追加／変更／削除／リファクタ）。スパイク（使い捨て検証）は対象外。
2. **テストリスト**: 振る舞い1行＋仕様の根拠。仕様の状態遷移表と**1行ずつ照合**し、欠けている行を項目にする。承認は仕様に関わる＝ユーザー、小修正＝Claude。
3. **テストだけ書かせる**（[instruction-template.md](instruction-template.md)）。エージェントはコミットしない。
4. **レビュー**（[review-checklist.md](review-checklist.md)）→ 合格したらレビュー担当が `test:` でコミット。
5. **実装させる**: `feat: Tn` を1項目ずつ。`tests/` は変更禁止。
6. **受け入れ検査**（下記スクリプト）。エージェントの自己申告は証拠にしない。

## 判断基準
| 状況 | 判断 |
|---|---|
| 書いた時点でテストが通った（初回 Green） | 即 NG にしない。**変異で落ちるか**確かめる。落ちなければ飾り → 補強 |
| 途中で困って、テストを足したくなった | 書かずにリストへ戻す。「壊れたら誰がどう困るか」を言えなければ足さない |
| 「この処理を消したい」 | 新しいテストを書かない。消える仕様のテストを削除し、**残りの緑**を証拠にする。復活すると実害がある場合だけ、外から見える結果で仕様項目にする |
| 「起きないこと」を確かめるテスト | データ消失などの実害を防ぐなら可。スコープ制約（`--force` がない等）はテストにせず、実装とレビューで守る |
| テストの前提状態 | 公開 CLI／API で作る。内部形式を手書きしない |
| 環境で再現できない前提 | 既定で失敗。明示許可したケースだけ UNVERIFIED。**未実装を未検証扱いにしない** |
| スキーマなどの契約 | 仕様から起こす。実装の出力から書かない |
| 型で保証できる網羅 | テストを書かない |
| 既存の不変条件のテストを、新しい経路（新コマンドなど）に付け替える | `test(migrate):` でコミットする。書いた時点で緑が正常なので Red を求めず、**変異で有効性を示す** |

## 指示書の鉄則
- 「満たす性質」だけを書くと、エージェントは**最も安い手段**で満たす。性質と**使ってはいけない手段**を対で書く。
- 仕様の要件を「技術的制約」欄に並べない（最初の feat で一括実装され、後の項目が初回 Green になる）。要件はテストリストの項目として渡す。

## 受け入れ検査
`scripts/` のスクリプトは、各コミットを一時 worktree で実際に再実行する。使い方は各スクリプトの `--help` を見る。
- `bash scripts/check_red_green.sh` … `test:` が本当に Red か（ビルドは通る）
- `bash scripts/check_feat_scope.sh` … `feat: Tn` で新しく緑になったのが Tn だけか、緑が減っていないか、`refactor:` で緑が増えていないか
- `bash scripts/mutate.sh` … 実装を壊してテストが落ちるか。運が絡むテストは複数回実行して数える
- コミット本文の Why・テスト名の What・コメントの Why not が残っているか … `how-what-why-whynot` スキルの2本のスクリプトを、同じ範囲に1回回す

**検査スクリプト自体も疑う**: 0件実行や skip を「合格」と数えていないか。

**検査用のビルド出力先は、通常のビルドとは別の1つに固定し、終わったら片付ける**（例: `CARGO_TARGET_DIR=<repo>/.cache/check`）。検査ごとに出力先を分けると、Rust では1セット数百MBが積み上がり、ディスクを使い切る。ただし出力先を一時 worktree 間で共有すると、cargo はソースが同じテストバイナリを使い回し、`env!("CARGO_MANIFEST_DIR")` などコンパイル時に埋め込まれたパスが、削除済みの worktree を指したままになる。
- 本体の作業ツリーの合否は、検査用の出力先ではなく通常の出力先（`target/`）で判定する。
- 変異で「検出」になったら、失敗の理由が変異によるものか（ファイルが見つからない等の巻き添えでないか）を確かめる。

## レッドフラグ
- 「Red を確認しました」という報告だけで、実行して確かめていない
- Green にするコミットでテストファイルが変わっている
- 最初の feat が大きく、後の項目が書く前から緑になる
- テストが early return や skip で終わる経路を持つ
- テストが内部ファイルの中身を読み書きしている
