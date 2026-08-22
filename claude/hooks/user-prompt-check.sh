#!/usr/bin/env bash
# UserPromptSubmit hook: ユーザー入力のたびに、記憶すべきことがないか確認させる。
#
# Stop ではなく UserPromptSubmit を使う理由（2026-08-23 実測）:
#   Stop は Claude 自身の応答で発火するため、additionalContext を返すと無限ループになる。
#   UserPromptSubmit はユーザーが入力したときだけ発火するのでループしない。
#   代償として、判定対象は「直前のターン」になり 1 ラリー遅れる。
#
# 判断基準そのものは ~/.claude/CLAUDE.md 側にあるため、ここでは参照するだけにする。
# UserPromptSubmit は標準出力がそのままコンテキストに入るので JSON にしない。
cat >/dev/null

note='Check the PREVIOUS turn against [mem-propose-decision] and [mem-propose-finding]. If either applies, propose the memory entry and ask for approval before writing.'

# tasks.md が無い作業では作業確認の文言を出さない。ファイルの有無を見るだけなので安い。
if [ -f "${CLAUDE_PROJECT_DIR:-$PWD}/.claude/tasks.md" ]; then
  note="$note Also update .claude/tasks.md: check off what finished."
fi

printf '%s\n' "$note"
