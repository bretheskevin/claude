#!/bin/bash

# Read JSON input
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
dir_name=$(basename "$cwd")

# Colors — combine reset+attr in single sequence for Claude Code statusline compatibility
DIM='\033[0;2m'
RESET='\033[0m'
CYAN='\033[0;36m'
CYAN_BOLD='\033[0;1;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
ORANGE='\033[0;38;5;172m'
BLUE='\033[0;34m'

SEP="${DIM} | ${RESET}"

output=""

# -- Directory --
output+="${CYAN_BOLD}${dir_name}${RESET}"

# -- Git section --
if cd "$cwd" 2>/dev/null && git rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

  if [ -n "$branch" ]; then
    # Extract ticket ID from branch name (e.g., feature/GCO-1331 -> GCO-1331)
    ticket=$(echo "$branch" | grep -oE '[A-Z]+-[0-9]+' | head -1)
    if [ -n "$ticket" ]; then
      branch_prefix="${branch%%${ticket}*}"
      # Make GCO-XXXX tickets clickable hyperlinks
      if [[ "$ticket" == GCO-* ]]; then
        gitlab_url="https://gitlab.com/myunisoft/tpme/myu-gestion/gestion-financiere/-/tree/${branch}"
        jira_url="https://myunisoft.atlassian.net/browse/${ticket}"
        gitlab_link='\033]8;;'"${gitlab_url}"'\033\\'"${MAGENTA}${ticket}${RESET}"'\033]8;;\033\\'
        jira_link='\033]8;;'"${jira_url}"'\033\\'"${BLUE}[J]${RESET}"'\033]8;;\033\\'
        branch_display="${DIM}${branch_prefix}${RESET}${gitlab_link} ${jira_link}"
      else
        branch_display="${DIM}${branch_prefix}${RESET}${MAGENTA}${ticket}${RESET}"
      fi
    else
      branch_display="${MAGENTA}${branch}${RESET}"
    fi

    output+="${SEP}${branch_display}"

    # Ahead/behind remote
    upstream=$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
    if [ -n "$upstream" ]; then
      counts=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
      ahead=$(echo "$counts" | cut -f1)
      behind=$(echo "$counts" | cut -f2)
      ab=""
      [ "$ahead" -gt 0 ] 2>/dev/null && ab+="${GREEN}+${ahead}${RESET}"
      [ "$behind" -gt 0 ] 2>/dev/null && { [ -n "$ab" ] && ab+=" "; ab+="${RED}-${behind}${RESET}"; }
      [ -n "$ab" ] && output+=" ${ab}"
    fi

  fi
fi

# -- Now Playing (macOS) --
if command -v nowplaying-cli >/dev/null 2>&1; then
  np_raw=$(nowplaying-cli get title artist playbackRate 2>/dev/null)
  np_title=$(echo "$np_raw"  | sed -n '1p')
  np_artist=$(echo "$np_raw" | sed -n '2p')
  np_rate=$(echo "$np_raw"   | sed -n '3p')

  if [ -n "$np_title" ] && [ "$np_title" != "null" ]; then
    is_playing=0
    [ "$np_rate" = "1" ] || [ "$np_rate" = "1.0" ] || [ "$np_rate" = "1.00" ] && is_playing=1

    # Icon: rotate with wall clock when playing, pause glyph when not
    if [ "$is_playing" = "1" ]; then
      frames=("♪" "♫" "♩" "♬")
      idx=$(( $(date +%s) % 4 ))
      icon="${ORANGE}${frames[$idx]}${RESET}"
    else
      icon="${DIM}⏸${RESET}"
    fi

    np_display="${np_title}"
    [ -n "$np_artist" ] && [ "$np_artist" != "null" ] && np_display+=" ${DIM}—${RESET} ${np_artist}"
    output+="${SEP}${icon} ${np_display}"
  fi
fi

printf '%b' "$output"
