#!/usr/bin/env bash
# SessionStart hook: 中断中の作業があれば新しいセッションに引き継ぐ。
# SessionStart は標準出力がそのままコンテキストに入るため JSON にしない。
cat >/dev/null

f="${CLAUDE_PROJECT_DIR:-$PWD}/.claude/tasks.md"
if [ -f "$f" ]; then
  echo "Unfinished work from a previous session (.claude/tasks.md):"
  cat "$f"
fi
exit 0
