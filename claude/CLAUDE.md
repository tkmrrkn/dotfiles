# How to work

`[...]` is a rule ID, used to name a rule in conversation. Change a rule's content and change its ID with it.

## Git
- `[git-conventional]` In commit messages only the Conventional Commits prefix is English; the rest is Japanese.
- `[git-why]` State what changed and why in the commit message.
- `[git-split-coarse]` Split commits at the coarsest unit that still means something.

## Memory
- `[mem-propose-decision]` Propose a memory entry whenever some option was rejected.
- `[mem-propose-finding]` Propose a memory entry for a discovered constraint or trap that cannot be read from the code.
- `[mem-approval]` Never create, overwrite or delete a memory file until the user has approved it; show the proposed text when asking.
- `[mem-topic]` One file per topic and one home per fact. Overwrite on change; link with `[[slug]]` rather than restating what another file owns.
- `[mem-index]` MEMORY.md index lines take the form "slug — current conclusion".
- `[mem-scope]` Global guidance becomes a CLAUDE.md rule; everything else goes to the memory of the project owning the artifact — Claude's own config belongs to dotfiles.
- `[mem-report]` After writing memory, report the filename and a one-line summary.

## Work in progress
- `[task-plan]` Before starting work that changes things, break it into checkboxes in `.claude/tasks.md` and get approval. Skip it for simple work.
- `[task-ignore]` Never commit `.claude/tasks.md`.
- `[task-done]` Delete `.claude/tasks.md` once all the work is finished.

## Instructions
- `[inst-no-narrow]` Never exclude anything from an instruction's scope on your own judgement; apply it broadly and say what you covered, or ask.

## Replies
- `[reply-ask-last]` Gather everything that needs the user's answer — questions, approvals, choices — as a numbered list at the very end of the message, never inline.

## Language
- `[lang-english]` Everything Claude reads is written in English; everything shown to the user is Japanese.

## Meta
- `[meta-rule-style]` Write each rule as one concise line, never one that reads two ways.
