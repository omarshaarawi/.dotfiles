#!/usr/bin/env bash
# WorktreeRemove hook: forget the jj workspace (or remove the git worktree), then rm the dir.
# Failures here are non-blocking; Claude only logs them in debug mode.
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:${PATH:-}"

log() { printf '[jj-worktree-remove] %s\n' "$*" >&2; }

input=$(cat)
# WorktreeRemove payload mirrors WorktreeCreate; the worktree dir arrives as
# `path` (older/alternate spellings tolerated).
path=$(printf '%s' "$input" | jq -r '.path // .worktree_path // .worktreePath // empty')

if [ -z "$path" ]; then
  log "no worktree path in payload; cannot clean up. keys seen: $(printf '%s' "$input" | jq -r 'keys | join(",")' 2>/dev/null || echo '(invalid json)')"
  printf '%s\n' "$input" > "${TMPDIR:-/tmp}/jj-worktree-remove.last-input.json" 2>/dev/null || true
  exit 0
fi

if [ ! -e "$path" ]; then
  log "$path already gone"
  exit 0
fi

name=$(basename "$path")

if [ -e "$path/.jj" ]; then
  bookmark="claude/$name"
  log "jj bookmark delete $bookmark (best-effort, before forget)"
  (cd "$path" && jj bookmark delete "$bookmark" >&2) || \
    log "no bookmark $bookmark to delete (already gone or never created)"
  log "jj workspace forget $name"
  if (cd "$path" && jj workspace forget "$name" >&2); then
    rm -rf "$path"
  else
    log "jj workspace forget failed; leaving $path intact for manual cleanup"
    exit 0
  fi
else
  log "git worktree remove --force $path"
  if git worktree remove --force "$path" >&2; then
    :
  else
    log "git worktree remove failed; falling back to rm -rf"
    rm -rf "$path"
  fi
fi
