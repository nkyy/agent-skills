---
name: applying-laws-of-ux
description: Use when building, changing, or reviewing any screen UI (web page, app screen, component, form, dashboard, onboarding, pricing, settings, modal, table) — especially when a screen asks for many inputs, offers many options or actions, carries decorative copy or filler visuals, or has not been looked at in a browser. Based on Laws of UX (lawsofux.com).
disable-model-invocation: false
---

# Laws of UX を画面に適用する

AI が作る画面は「全部入り・全部同じ強さ・装飾過多・見ずに完了」になりやすい。
画面ごとに**ユーザーの主タスクを1つに決め、それ以外を削る・後ろへ回す・弱める**。法則の詳細は `laws.md`。

## 1. 作る前: 画面メモ（5行）を書く

コードを書く前に、画面ごとに次の5行を書いてユーザーへの報告にも含める。

```
主タスク: <この画面でユーザーが終えたいこと 1つ>
主アクション: <押してほしいボタン 1つ。他はすべて二次扱い>
今聞く入力: <主タスクに不可欠な項目だけ> / 後回し: <後で聞く・既定値で済む項目>
既定値・推奨: <迷わせる選択肢それぞれに、どれを既定または「おすすめ」にするか>
慣習: <ユーザーが知っている同種画面と同じ配置・用語にする点>
```

## 2. 作るとき: 既定の形

| 決めること | 既定の形 | 根拠の法則 |
|---|---|---|
| 入力項目 | 今聞く入力だけ置く。後回しの項目は後のステップか設定へ | Tesler, Cognitive Load, Goal-Gradient |
| 選択肢 | 3〜4個を超えたら推奨を1つ目立たせ、残りは比較表か「すべて見る」へ | Hick, Choice Overload, Von Restorff |
| 操作ボタン | 主アクションだけ塗りボタン。二次は枠線/テキスト、3個を超える操作は「その他」メニューへ | Hick, Von Restorff, Fitts |
| 破壊的操作 | 確認より「元に戻す」を優先。確認文は対象と件数を明記 | Peak-End, Mental Model |
| グループ化 | 関係する要素は余白で寄せ、関係ない要素は離す。枠は必要な時だけ | Proximity, Common Region, Chunking |
| 文言・装飾 | 主タスクの判断に使わない見出し・キャッチコピー・飾りグラフ・偽データは置かない | Selective Attention, Cognitive Load, Prägnanz |
| 配置・用語 | 同種の定番 UI と同じ位置・名前（ログインは右上、検索は上部、など） | Jakob, Mental Model |
| 待ち時間 | 400ms を超える処理は即時に反応を返し、進捗か骨組み表示を出す | Doherty |
| 長い手順 | 進捗を示し、最初の一歩を軽く。完了画面を最後の印象として作る | Goal-Gradient, Peak-End, Zeigarnik |
| 空・エラー状態 | 空状態に次の一手、エラーに直し方。入力は寛容に受けて正規化 | Postel, Paradox of the Active User |
| 押す対象 | 主要ボタンは大きく、指やカーソルの近くに。タッチは 44px 以上 | Fitts |

## 3. 作った後: 画面を見て点検する

完了報告の前に、ブラウザで実画面を開いてスクリーンショットを撮り（デスクトップ幅とモバイル幅）、次を確かめる。見られない場合は「未確認」と報告する。

1. 3秒見て、主アクションが1つだけ目立っているか
2. 画面メモの「後回し」の項目が画面に出ていないか
3. 判断に使わない文言・装飾が残っていないか（各テキストに「これを消すと困る人は？」）
4. データが実際に表示されているか（空表・コンソールエラーがないか）
5. 空状態・エラー状態・完了状態を1回ずつ表示させたか

点検で見つけた問題は直してから報告する。報告には画面メモと、どの点検項目を直したかを書く。
