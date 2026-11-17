# Laws of UX 早見表（設計判断別）

出典: https://lawsofux.com/<slug>/ （各法則の解説・参考文献はそちら）。ここでは「画面で何をするか」に言い換えている。

## 選択肢と入力の量

| 法則 (slug) | 画面での使い方 | AI がやりがちな失敗 |
|---|---|---|
| Hick's Law (hicks-law) | 選択肢は少なく、推奨を示して決定時間を減らす | 操作ボタンを6個横並び |
| Choice Overload (choice-overload) | 比較が要る時だけ比較表。初期表示は絞る | 4プランを同じ強さで並べ、推奨なし |
| Tesler's Law (teslers-law) | 減らせない複雑さはシステム側（既定値・自動推定）が持つ | 国・電話・役職を毎回ユーザーに入力させる |
| Cognitive Load (cognitive-load) | 主タスクに不要な情報を画面から外す | キャッチコピーや説明パネルを周囲に配置 |
| Miller's Law (millers-law) | 覚えさせない。項目は意味のまとまりに分ける | 長い一覧を区切りなしで提示 |
| Working Memory (working-memory) | 前の画面の情報が判断に要るなら今の画面にも出す | 確認画面で入力内容を表示しない |
| Chunking (chunking) | 長い入力・数字・リストを小さな塊に分ける | 1枚の長いフォーム |
| Pareto Principle (pareto-principle) | よく使う2割の機能を最前面に、残りは奥へ | 全機能を同じ階層に並べる |
| Occam's Razor (occams-razor) | 同じ目的を果たすなら要素の少ない案を選ぶ | 同じ情報を見出し・説明・注記で三重に書く |

## 視覚のまとまり（ゲシュタルト）

| 法則 (slug) | 画面での使い方 | AI がやりがちな失敗 |
|---|---|---|
| Law of Proximity (law-of-proximity) | ラベルと入力、見出しと本文を寄せ、別グループは離す | 均等な余白で何が組か分からない |
| Law of Common Region (law-of-common-region) | 本当に1つの単位だけを枠やカードで囲む | 全部をカードに入れて枠だらけ |
| Law of Similarity (law-of-similarity) | 同じ機能は同じ見た目、違う機能は違う見た目 | リンクとボタンとタグが同じ見た目 |
| Law of Uniform Connectedness (law-of-uniform-connectedness) | 手順や関係は線・背景でつなぐ | ステップ表示と内容がつながっていない |
| Law of Prägnanz (law-of-pr%C3%A4gnanz) | 単純な形・整列で一目で読めるようにする | 飾りイラストや意味のない図形 |

## 注目と記憶

| 法則 (slug) | 画面での使い方 | AI がやりがちな失敗 |
|---|---|---|
| Von Restorff Effect (von-restorff-effect) | 目立たせるのは1画面1つ（主アクション・推奨） | 色付きバッジ・強調が多すぎて何も目立たない |
| Selective Attention (selective-attention) | ユーザーは目的以外を無視する。重要情報を広告風にしない | 重要な注意書きを装飾パネルに置く |
| Serial Position Effect (serial-position-effect) | 重要な項目は一覧の最初か最後に | 主要ナビを中央に埋もれさせる |
| Aesthetic-Usability Effect (aesthetic-usability-effect) | 整った見た目は信頼を生むが、使いにくさを隠す。テストで確かめる | 見た目の良さで動作確認を省く |
| Cognitive Bias (cognitive-bias) | 既定値・並び順・表現が判断を誘導することを自覚し、ユーザーに不利な誘導をしない | 解約・オプトアウトを見つけにくくする |

## 操作と応答

| 法則 (slug) | 画面での使い方 | AI がやりがちな失敗 |
|---|---|---|
| Fitts's Law (fittss-law) | 頻繁・重要な操作は大きく近く。破壊的操作は主操作から離す | 削除ボタンを保存の隣に同サイズで置く |
| Doherty Threshold (doherty-threshold) | 400ms 以内に反応。遅い処理は楽観的更新・骨組み表示 | 押しても何も変わらない時間がある |
| Postel's Law (postels-law) | 入力の揺れ（全角・空白・区切り）を受け入れて正規化 | 電話番号のハイフン有無でエラー |
| Flow (flow) | 作業中に割り込まない。モーダル・通知は必要最小限 | 操作のたびにトースト・確認ダイアログ |
| Parkinson's Law (parkinsons-law) | 自動入力・既定値で作業時間そのものを縮める | 既知の情報を再入力させる |

## 期待と慣習

| 法則 (slug) | 画面での使い方 | AI がやりがちな失敗 |
|---|---|---|
| Jakob's Law (jakobs-law) | 定番の配置・アイコン・用語に合わせる | 独自の言い回しのナビ名 |
| Mental Model (mental-model) | ユーザーの言葉と因果で状態や操作を説明する | 内部の状態名をそのまま表示 |
| Paradox of the Active User (paradox-of-the-active-user) | 説明を読ませる前提にしない。画面そのものに次の一手を置く | 使い方をヘルプモーダルに押し込む |

## 体験の流れ

| 法則 (slug) | 画面での使い方 | AI がやりがちな失敗 |
|---|---|---|
| Goal-Gradient Effect (goal-gradient-effect) | 進捗を見せ、最初の一歩を短く | 最初の画面に最も重い入力 |
| Zeigarnik Effect (zeigarnik-effect) | 未完了タスクを見える形で残し、再開しやすくする | 途中離脱で入力が消える |
| Peak-End Rule (peak-end-rule) | 最も感情が動く瞬間（エラー・完了）と最後の画面を丁寧に作る | 完了画面が素っ気ない、エラーが不親切 |
