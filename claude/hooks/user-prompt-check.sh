#!/usr/bin/env bash
# UserPromptSubmit hook: 入力のたびに記憶すべきことがないか確認させる。標準出力がそのまま文脈に入る。
# Stop だと自分の応答で発火して無限ループになるため、判定対象は直前のターンで1ラリー遅れる。
cat >/dev/null

note='Check the PREVIOUS turn against [mem-decision] and [mem-finding]. If either applies, propose the memory entry and ask for approval before writing.'

# tasks.md が無い作業では作業確認の文言を出さない。ファイルの有無を見るだけなので安い。
if [ -f "${CLAUDE_PROJECT_DIR:-$PWD}/.claude/tasks.md" ]; then
  note="$note Also update .claude/tasks.md: check off what finished."
fi

printf '%s\n' "$note"
