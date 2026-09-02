# How to work

`[...]` is a rule ID, used to refer to a rule from anywhere.

## Code
- `[code-comment-length]` Keep code comments to one or two lines; put the investigation trail in the conversation or the commit message.

## Git
- `[git-message-language]` In commit messages only the Conventional Commits prefix is English; the rest is Japanese.
- `[git-message-content]` State what changed and why in the commit message.
- `[git-commit-granularity]` Split commits at the coarsest unit that still means something.

## Work in progress
- `[task-plan]` Before starting work that changes things, break it into checkboxes in `.claude/tasks.md` and get approval. Skip it for simple work.
- `[task-git]` Never commit `.claude/tasks.md`.
- `[task-completion]` Delete `.claude/tasks.md` once all the work is finished.

## Instructions
- `[inst-scope]` Never exclude anything from an instruction's scope on your own judgement; apply it broadly and say what you covered, or ask.
- `[inst-ambiguity]` When an instruction can be read more than one way, stop before acting and settle the reading with the user; never proceed on a guess.
- `[inst-approval]` Approval covers only what the answer names; silence, a partial answer and an intent to report afterwards are not approval.

## Replies
- `[reply-ask-placement]` Gather everything that needs the user's answer — questions, approvals, choices — as a numbered list at the very end of the message, never inline.
- `[reply-ask-count]` Ask the fewest questions that settle the decision.
- `[reply-ask-granularity]` One numbered item per decision; never bundle independent decisions into a single item.
- `[reply-ask-options]` Where a sensible default exists, propose it for confirmation instead of asking an open question.
- `[reply-order]` Lead with the conclusion or result; reasoning and detail come after it.
- `[reply-detail]` Include only what the user needs in order to decide or act; leave the rest out.
- `[reply-problem-timing]` Raise a problem the moment it appears, not once it has grown.
- `[reply-certainty]` Keep verified fact and your own inference apart, and say which is which.

## Language
- `[lang-audience]` Claude's own config and notes (CLAUDE.md, skills, memory, feedback rules) are English; everything a person reads - replies, code comments, READMEs - is Japanese.

## Meta
- `[meta-rule-id]` A rule ID names the subject the rule governs, never its current content.
- `[meta-rule-rename]` Renaming a rule ID is a last resort; when renaming, find every reference and update them all in the same change.
- `[meta-rule-style]` Write each rule as one concise line, never one that reads two ways.
