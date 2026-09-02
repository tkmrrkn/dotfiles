---
name: rules
description: List the rules currently in force in this session, with rule ID, source and last-modified date. Use when asked what rules are being followed, to show the rules, or for the reasoning behind a decision, and when auditing the rule set or checking it for contradictions. Given part of a rule ID as an argument, show only that rule in detail.
allowed-tools: Bash(ls:*), Bash(cat:*), Bash(stat:*), Bash(date:*), Bash(git log:*), Bash(grep:*), Bash(wc:*), Read, Glob, Grep
---

Inspect the rules actually in force in this session and list them. Read-only — never modify a file.

**Render the entire output in Japanese**, including table headers, even though this file is written in English.

## Where to look

1. `~/.claude/CLAUDE.md` — rules shared across every project. Each entry carries a `[rule-id]`.
2. Any `CLAUDE.md` found walking up from the current directory — project-specific rules.
3. Notes under `~/.claude/projects/<encoded-name>/memory/` whose frontmatter is `type: feedback` or `type: user`.
   - Encoding: replace path separators and the drive colon with `-`.
     e.g. `C:\Users\x\dotfiles` becomes `C--Users-x-dotfiles`
   - Exclude `type: project` — it is not guidance to follow.
4. Behaviour-affecting entries in `~/.claude/settings.json` (language, model, permissions, hooks, and so on).
5. Custom skills and commands in `~/.claude/skills/` and `~/.claude/commands/`.

## Getting the last-modified date

- Tracked by git: `git log -1 --format=%ad --date=short -- <file>`
- Untracked: the file's mtime

## Output

A table with these columns: rule ID, one-line summary of the rule, source, last modified.

- Rules without an ID (project memory and the like) get `—` in the ID column and are identified by their source filename.
- Memory notes are stored in English; translate their summaries into Japanese for display.
- Never expand a rule in full. One summarized line each — a scannable list beats completeness.
- Mark anything last modified more than 90 days ago with ⚠.
- After the table, list anything under a "needs review" heading if it contradicts another rule or may not be in force at all: pointing at a path that does not exist, a name that disagrees with its content, or duplicating the system prompt so that writing it changes nothing.
- Close with one line giving the total volume: file count, approximate character count, and how much of that is auto-injected every session.

## Arguments

When `$ARGUMENTS` contains part of a rule ID, skip the list and show that rule in full instead — its complete text, source, last-modified date, and related rules.
