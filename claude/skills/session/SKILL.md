---
name: session
description: Carry one piece of work across session boundaries. Use before closing a session on a large task so the next one can continue — "セッションを分けたい", "引き継ぎを残して", "一旦切る", "コンテキストが重い" — and at the start of a session to pick that work back up — "続きをやる", "前回の続き". Writes and reads one short handoff note per repository.
---

A large task loses accuracy as the context fills up. Split it across sessions instead: leave a
short handoff note before closing one, and start the next from that note alone.

**Write the entire output in Japanese**, and write the note itself in Japanese, even though this
file is written in English.

## Which direction

- Given `load` or `read` as an argument, read the note. Given `save` or `write`, write it.
- No argument: if this session has not done any work yet, read. Otherwise, write.

## Where the note lives

`~/.claude/projects/<slug>/plans/<work-name>.md`

- `<slug>` — the absolute path of the repository root (the working directory when there is no
  repository) with the drive colon and every path separator replaced by `-`.
  e.g. `C:\Users\x\dotfiles` becomes `C--Users-x-dotfiles`.
- `<work-name>` — kebab-case, naming the work rather than the session. Keep it unchanged across
  sessions so the same file is updated.
- Create `plans/` if it does not exist. Never write into the sibling `memory/`.

The note sits outside every repository on purpose: it never enters git, and it survives worktree
removal and `git clean -fdx`.

## Reading

1. List `~/.claude/projects/<slug>/plans/*.md` and find those whose header says
   `Status: in-progress`.
2. None — say so, and offer to start a note for the work at hand. One — read it. Several — list
   their titles and ask which.
3. Read the files named under 次の一手, and nothing else.
4. Report in Japanese what the work is, where it stopped, and what comes next — a few lines.
   Confirm the next action before touching anything.

Never rebuild context from the previous session's transcript, and never re-explore the codebase to
fill a gap the note left. If the note was not enough to continue from, that is a defect in the
note: fix the note as part of this session.

## Writing

1. Pick the target file — the in-progress note for this work, or a new one.
2. Overwrite it whole. The note describes the present state, not a diary of what happened.
3. Tell the user to `/clear` and run `/session` in a fresh session.

When the work is done, set `Status: done` and empty 次の一手. Never delete the file.

## The note

````markdown
# 横断データ設定のリファクタ
Repo: ~/ghq/.../stiv   Branch: refactor/cross-section   Status: in-progress
Updated: 2026-09-02

## 目的
この作業が何なのか。1〜3行。

## 現在の状態
- 実際に終わったことだけ。commit があれば hash を書く。
- 検証: `./gradlew test --tests '*CrossSection*'` → 12 passed

## 次の一手
- 具体的な次の1手
- 最初に読む: AnalysisFragment.kt:3580-3600, PixelScale.kt

## 決めたこと
- 2026-09-02 決めたこと — 理由

## 未解決・注意点
- 未確認のこと、詰まっていること
````

Rules for filling it in:

- 次の一手 always names the files to read first. The next session must not begin by searching.
- 現在の状態 carries only what you actually ran, with its real output. Anything unverified belongs
  under 未解決・注意点 — never state an untested change as done.
- Record a decision together with its reason. A decision without one gets re-litigated next
  session.
- Keep the note short enough to cost almost no context. Past roughly 60 lines it has become a
  diary; cut it back to the present state.
- Never put credentials, tokens, or personal data in the note.

## Boundary with memory

`~/.claude/projects/<slug>/memory/` holds facts that stay true — the machine's quirks, the user's
standing preferences, why a repository came to be as it is. Its `MEMORY.md` is loaded into every
session.

This note holds the in-flight state of one piece of work and goes stale the moment that work ends.
It is read only when this skill reads it.

If, while writing the note, you find something that will still be true after this work is over,
put it in memory instead and refer to it from 決めたこと by name.

## Watch for

- Do not turn this into task management. One note per piece of work, five sections, present tense.
- Do not write the note and then keep working. Writing it is how a session ends.
- Do not carry over what git already carries. What changed and why lives in the commit history;
  the note carries the uncommitted state, the next step, and what is still unverified.
