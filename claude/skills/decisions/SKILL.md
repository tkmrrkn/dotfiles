---
name: decisions
description: List what was decided and what was discovered in this project. Use when asked why something is the way it is, what was decided before, whether the same question is being re-litigated, or to recall an option that was already rejected. Given a term as an argument, show only that topic in detail.
allowed-tools: Bash(ls:*), Bash(cat:*), Bash(stat:*), Bash(date:*), Bash(grep:*), Bash(wc:*), Read, Glob, Grep
---

List this project's decisions and findings. Read-only — never modify a file.

**Render the entire output in Japanese**, including table headers, even though this file is written in English.

Rules — the guidance to be followed — are out of scope here; the `rules` skill covers those.

## Where to look

Only notes under `~/.claude/projects/<encoded-name>/memory/` whose frontmatter is `type: project`.

- Encoding: replace path separators and the drive colon with `-`.
  e.g. `C:\Users\x\dotfiles` becomes `C--Users-x-dotfiles`
- Exclude `type: feedback` and `type: user` — those are rules, handled by the `rules` skill.
- `MEMORY.md` is the index; read each note for its body.

## Output

Notes are stored entirely in English. Translate them into Japanese for display.

One section per topic, not a table — the number of rejected options varies wildly between topics and a fixed-column table crushes them together.

Each section is a level-2 heading carrying the topic name, its slug and its last-modified date, then:

- A **conclusion** line: what currently holds.
- A **rejected** list, one bullet per option, each as "option — one-line reason". This is the core of what stops the same proposal coming back — never omit a reason. Omit the whole list when there is nothing rejected.
- For constraints and traps (written under `[mem-finding]`), state them as the conclusion and skip the rejected list.

Keep every line short enough to read without horizontal scrolling. Last modified comes from the file's mtime, since these are not tracked by git.

Close the whole listing with one line giving the topic count and the approximate character count of `MEMORY.md` — that index is auto-injected every session, so it is the number to watch for bloat.

## Arguments

When `$ARGUMENTS` contains a term, skip the list and show that topic in full instead, in Japanese — expanding the reasoning behind the decision and the reason for each rejected option.
