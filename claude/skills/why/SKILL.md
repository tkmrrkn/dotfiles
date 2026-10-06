---
name: why
description: Takes an error — piped command output, a log file path, or pasted text — reads the current repository for context, and reports the likely cause, its evidence, and the commands that confirm it. Read-only; changes nothing.
argument-hint: "[ログファイルのパス]（エラー本文は標準入力で渡す）"
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash(git status *), Bash(git log *), Bash(git diff *)
---

# Explain an error

The user hands over an error. Find its likely cause and report it. Write everything the user reads
in Japanese.

Argument: $ARGUMENTS

## Where the error is

- The argument is a file path: that file is the log. Read it. For a long log, read the end first,
  then search it for the first error line (`Error`, `Exception`, `Traceback`, `FATAL`, `failed`)
  and read around that.
- Otherwise: the error text is in the message itself, after the command.
- Neither holds any error text: say so in one line and stop.

## What to read

Read only. Change no files and run nothing that changes state; the user may not see this until
later, and a change they did not ask for is worse than a slow answer.

Read the current directory for context: the files the stack trace names, configuration, README,
dependency files, `git log` and `git diff` for recent changes. Never search for or move to another
repository.

## Report

Write the report in this structure. Omit a section that has no content.

```
【<確度>】<原因を一文で>
※ <エラーに出てくるファイル> はこのフォルダにありません。そのリポジトリに移って実行し直すと、コードを読んで絞り込めます。

■ 根拠
  - 確認できた事実：<事実>（<ファイル:行 またはログの行>）
  - 推測：<推測>（<確かめていない理由>）

■ 確かめ方
  1. <コマンド> — <結果が何なら、どの原因と分かるか>

■ 直し方
  <手順またはコマンド>
```

Rules:

- `<確度>` is one of 【確定】【推測】【不明】.
  - 【確定】: the cause is shown by what you read (the code, the config, the log itself).
  - 【推測】: the cause is likely but rests on something you could not read (environment
    variables, another machine, a server). ■ 確かめ方 is required.
  - 【不明】: the error text does not contain the cause (e.g. a trace cut off above the error
    line). State what is missing and how to get it, e.g. the full output of which command.
- Write the ※ line only when the files the error names (the user's own code, not libraries or the
  runtime) are not in the current directory.
- List at most three candidate causes, most likely first.
- Every command under ■ 確かめ方 and ■ 直し方 is for the user to run. Write them for PowerShell
  unless the error shows another shell.
- ■ 直し方 appears only for 【確定】, or for 【推測】 when the fix is harmless to try.
- End with the report. Do not offer to make changes; this run cannot continue the conversation.
