# 仕事の進め方

`[...]` はルールID。会話で名指しするために使う。内容を変えたらIDも直す。

## Git
- `[git-conventional]` コミットメッセージは Conventional Commits の接頭辞だけ英語、残りは日本語。
- `[git-why]` コミットメッセージには何をなぜ変えたかを書く。
- `[git-split-coarse]` コミットは意味のあるまとまりのうち最も粗い単位で分割する。

## 記憶
- `[mem-decision]` 却下した選択肢がある判断は memory に書く。
- `[mem-finding]` 調べて分かった制約や罠のうち、コードから読み取れないものは memory に書く。
- `[mem-topic]` memory は主題ごとに1ファイル。決定が変わったら上書きする。
- `[mem-lang]` memory は全文英語で書く。
- `[mem-index]` MEMORY.md の目次行は「スラッグ — 現在の結論」の形にする。
- `[mem-report]` memory を書いたら、ファイル名と1行要約をその場で伝える。

## 作業経過
- `[task-ask]` 修正を伴う作業では、着手前に `.claude/tasks.md` の要否をユーザーに確認する。簡単な作業では作らない。
- `[task-approve]` 作業をチェックボックスで細分化し、承認を得てから着手する。
- `[task-ignore]` `.claude/tasks.md` は git 管理しない。
- `[task-done]` 作業が全部終わったら `.claude/tasks.md` を削除する。

## メタ
- `[meta-rule-style]` ルールは1行で簡潔に書く。ただし複数の意味に読める書き方はしない。
