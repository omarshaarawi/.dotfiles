#!/usr/bin/env bash
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
repo=$(echo "$input" | jq -r '.workspace.repo | if . then .owner + "/" + .name else empty end')
worktree=$(echo "$input" | jq -r '.workspace.git_worktree // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')

# Shorten home dir
cwd="${cwd/#$HOME/\~}"

# Kanagawa palette (truecolor)
CREAM=$'\033[38;2;220;215;186m'
BLUE=$'\033[38;2;126;156;216m'
MUTED=$'\033[38;2;84;84;109m'
GREEN=$'\033[38;2;118;148;106m'
PURPLE=$'\033[38;2;149;127;184m'
RESET=$'\033[0m'

SEP="${MUTED} | ${RESET}"
out=""

# Directory
out="${CREAM}[ ${cwd} ]${RESET}"

# Repo (owner/name), with worktree if present
if [ -n "$repo" ]; then
  if [ -n "$worktree" ]; then
    out="${out}${SEP}${GREEN}${repo} (${worktree})${RESET}"
  else
    out="${out}${SEP}${GREEN}${repo}${RESET}"
  fi
fi

# Model
if [ -n "$model" ]; then
  out="${out}${SEP}${BLUE}${model}${RESET}"
fi

# Effort level (when present)
if [ -n "$effort" ]; then
  out="${out}${SEP}${PURPLE}${effort}${RESET}"
fi

# Context usage
if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct")
  out="${out}${SEP}${MUTED}ctx:${used_int}%${RESET}"
fi

printf "%s\n" "$out"
