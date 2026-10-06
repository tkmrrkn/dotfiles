# Report format

Write the report in Japanese, in this structure. Omit a section that has no content.

```
【<状態>】<依頼主>の<依頼の短い名前> — 期限 <期限>

■ ご判断いただきたいこと
  1. <判断してほしいこと>
     推奨：<案>。理由：<根拠>
     ほかの案：<案>なら<利点>だが、<欠点>
     判断しない場合：<影響>

■ 結果
  - 確認できた事実：<事実>（<根拠のリンク・ファイル>）
  - 推測：<推測>（<確かめていない理由>）

■ 止まったところ
  - <理由>
  - 進めるのに必要なもの：<本人の判断・追加の情報・権限>

■ 返信案 / 下書き
<本文>
```

Rules:

- The first line states the status, one of 【完了】【判断待ち】【停止】. Write 不明 for an unknown
  requester or deadline; never guess them.
- 【完了】 means nothing needs the user. Omit ■ ご判断いただきたいこと.
- Every item under ■ ご判断いただきたいこと carries a recommendation and its reason, so the user can
  answer with one word. Number the items; the user approves by number.
- Even when stopped, put every point the user can settle by deciding (yes/no, which option, which
  date) under ■ ご判断いただきたいこと as a numbered item with a recommendation. Keep
  ■ 止まったところ for what a decision alone cannot fix (missing access, missing link). A stop that
  only needs a decision is 【判断待ち】, not 【停止】.
- Report results and their evidence, not the steps you took.
- Keep verified facts and inferences in separate lines.

## Examples

**Nothing to do:**

```
【完了】佐藤さんからのお礼 — 期限 なし

■ 結果
  - 確認できた事実：前の依頼への了承の返事で、新しい依頼はありません
```

**Stopped:**

```
【停止】依頼主 不明の修正依頼 — 期限 不明

■ 止まったところ
  - 「例の件」が何を指すか、本文から分かりません
  - 進めるのに必要なもの：対象（課題やメッセージのリンク）
```
