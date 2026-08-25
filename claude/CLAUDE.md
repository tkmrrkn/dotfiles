# How to work

`[...]` is a rule ID, used to refer to a rule from anywhere.

## Code
- `[code-comment-length]` Keep code comments to one or two lines; put the investigation trail in the conversation or the commit message.

## Git
- `[git-message-language]` In commit messages only the Conventional Commits prefix is English; the rest is Japanese.
- `[git-message-content]` State what changed and why in the commit message.
- `[git-commit-granularity]` Split commits at the coarsest unit that still means something.

## Memory
- `[mem-decision]` Propose a memory entry for a rejected option only when re-proposing it would cost real work; skip whatever code, comments or commit messages already explain.
- `[mem-finding]` Propose a memory entry for a discovered constraint or trap only when rediscovering it would cost real work; skip whatever is readable from the code.
- `[mem-approval]` Never create, overwrite or delete a memory file until the user has approved it; show the proposed text when asking.
- `[mem-granularity]` One file per topic and one home per fact. Overwrite on change; link with `[[slug]]` rather than restating what another file owns.
- `[mem-index]` MEMORY.md index lines take the form "slug — current conclusion".
- `[mem-scope]` Global guidance becomes a CLAUDE.md rule; everything else goes to the memory of the project owning the artifact — Claude's own config belongs to dotfiles.
- `[mem-report]` After writing memory, report the filename and a one-line summary.

## Work in progress
- `[task-plan]` Before starting work that changes things, break it into checkboxes in `.claude/tasks.md` and get approval. Skip it for simple work.
- `[task-git]` Never commit `.claude/tasks.md`.
- `[task-completion]` Delete `.claude/tasks.md` once all the work is finished.

## Instructions
- `[inst-scope]` Never exclude anything from an instruction's scope on your own judgement; apply it broadly and say what you covered, or ask.

## Replies
- `[reply-ask-placement]` Gather everything that needs the user's answer — questions, approvals, choices — as a numbered list at the very end of the message, never inline.
- `[reply-ask-count]` Ask the fewest questions that settle the decision.
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
