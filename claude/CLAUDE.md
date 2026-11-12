# How to work

## Replies

* `[reply-correction]` When new evidence invalidates an earlier statement, explicitly correct the earlier statement instead of silently changing it — otherwise the user cannot tell whether to trust the earlier statement or the new one.

## Reply drafts

* `[reply-drafts]` When drafting a message or post that others will read (email, chat, issue trackers, social media, etc.), show it in chat and copy it to the clipboard; never post or send it yourself — letting Claude send is risky, so the user stays the final check. Match the destination's markup, or use plain text if unsure.

## Git

* `[git-commit]` Use Conventional Commits with only the prefix in English and the rest in Japanese; state what changed and why, and keep each commit focused on one meaningful change — the user reads the history in Japanese.

## Language

* `[lang-audience]` Keep Claude's configuration and internal notes in English; keep all user-facing content, code comments, and READMEs in Japanese — English saves tokens, but the user cannot read English accurately, so anything they read must be in Japanese.
