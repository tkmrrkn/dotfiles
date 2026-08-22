#!/bin/bash
# Claude Code status line: current directory, model name, context usage %, and rate limit usage %.

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty')
dirname=""
[ -n "$cwd" ] && dirname=$(basename "$cwd")

model=$(echo "$input" | jq -r '.model.display_name')
effort=$(echo "$input" | jq -r '.effort.level // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
five_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

fmt_reset() {
  local epoch="$1" fmt="$2"
  [ -n "$epoch" ] && date -d "@$epoch" "+$fmt" 2>/dev/null
}

five_reset_str=$(fmt_reset "$five_reset" "%-I:%M %p")
week_reset_str=$(fmt_reset "$week_reset" "%-m/%-d %-I:%M %p")

RESET='\033[0m'
DIM='\033[2m'
CYAN='\033[2;36m'
GREEN='\033[2;32m'
YELLOW='\033[2;33m'
MAGENTA='\033[2;35m'
BLUE='\033[2;34m'

if [ -n "$dirname" ]; then
  out=$(printf "${BLUE}%s${RESET}" "$dirname")
  out="$out $(printf "${DIM}|${RESET}")"
  out="$out $(printf "${CYAN}%s${RESET}" "$model")"
else
  out=$(printf "${CYAN}%s${RESET}" "$model")
fi

if [ -n "$effort" ]; then
  seg=$(printf "${DIM}|${RESET} ${GREEN}%s${RESET}" "$effort")
  out="$out $seg"
fi

if [ -n "$used_pct" ]; then
  seg=$(printf "${DIM}|${RESET} ${YELLOW}Ctx %.0f%%${RESET}" "$used_pct")
  out="$out $seg"
fi

if [ -n "$five" ]; then
  seg=$(printf "${DIM}|${RESET} ${MAGENTA}5h %.0f%%${RESET}" "$five")
  if [ -n "$five_reset_str" ]; then
    seg="$seg$(printf " ${DIM}(%s)${RESET}" "$five_reset_str")"
  fi
  out="$out $seg"
fi

if [ -n "$week" ]; then
  seg=$(printf "${DIM}|${RESET} ${MAGENTA}7d %.0f%%${RESET}" "$week")
  if [ -n "$week_reset_str" ]; then
    seg="$seg$(printf " ${DIM}(%s)${RESET}" "$week_reset_str")"
  fi
  out="$out $seg"
fi

printf "%b" "$out"
