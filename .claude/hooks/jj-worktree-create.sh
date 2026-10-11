#!/usr/bin/env bash
# WorktreeCreate hook: prefer `jj workspace add` over `git worktree add`.
# Reads Claude's hook JSON on stdin, prints the new worktree's absolute path on stdout.
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:${PATH:-}"

log() { printf '[jj-worktree-create] %s\n' "$*" >&2; }
die() { log "error: $*"; exit 1; }

input=$(cat)
# WorktreeCreate payload: { session_id, transcript_path, cwd, agent_type,
# hook_event_name, name }. No base path or ref are sent, so we default both.
# Older/alternate key spellings are tolerated for forward-compat.
base=$(printf '%s' "$input" | jq -r '.worktree_base_path // .worktreeBasePath // empty')
name=$(printf '%s' "$input" | jq -r '.name // .worktree_name // .worktreeName // empty')
cwd=$(printf '%s' "$input" | jq -r '.cwd // .currentWorkingDirectory // empty')
ref=$(printf '%s' "$input" | jq -r '.ref // .baseRef // empty')

dump_payload() {
  local debug_dir="${TMPDIR:-/tmp}"
  local debug_file="$debug_dir/jj-worktree-create.last-input.json"
  printf '%s\n' "$input" > "$debug_file" 2>/dev/null || true
  log "raw payload saved to $debug_file for inspection"
  log "keys seen: $(printf '%s' "$input" | jq -r 'keys | join(",")' 2>/dev/null || echo '(invalid json)')"
}

if [ -z "$name" ] || [ -z "$cwd" ]; then
  dump_payload
  [ -n "$name" ] || die "missing worktree name (tried worktree_name, worktreeName)"
  [ -n "$cwd" ]  || die "missing cwd (tried cwd, currentWorkingDirectory)"
fi

cd "$cwd"

find_root() {
  local dir="$1"
  while [ "$dir" != "/" ] && [ -n "$dir" ]; do
    if [ -d "$dir/.jj" ] || [ -d "$dir/.git" ] || [ -f "$dir/.git" ]; then
      printf '%s\n' "$dir"; return 0
    fi
    dir=$(dirname "$dir")
  done
  return 1
}

root=$(find_root "$cwd") || die "not inside a git or jj repository (cwd=$cwd)"

# If the harness didn't supply a base path, default to <repo-root>/.claude/worktrees.
# Outside-git callers in this user's setup always live inside a sub-repo, so this is
# the correct anchor.
if [ -z "$base" ]; then
  base="$root/.claude/worktrees"
  log "no worktree base path supplied; defaulting to $base"
fi

target="$base/$name"
cd "$root"

mkdir -p "$base"

if [ -d "$root/.jj" ]; then
  # Base the new workspace on trunk by default so parallel jobs don't inherit
  # in-progress work from the primary workspace. Respect $ref when EnterWorktree
  # passes one (e.g., the user's worktree.baseRef setting).
  if [ -n "$ref" ] && [ "$ref" != "HEAD" ]; then
    base_rev="$ref"
  else
    base_rev='trunk()'
  fi
  bookmark="claude/$name"
  log "jj workspace add -r '$base_rev' $target (repo root: $root)"
  jj workspace add -r "$base_rev" "$target" >&2
  # Create a bookmark at @ in the new workspace so the work has identity:
  # `jj tug` can advance it, and `jj git push --bookmark $bookmark` can ship it.
  log "jj bookmark create $bookmark -r @ (in $target)"
  (cd "$target" && jj bookmark create "$bookmark" -r @ >&2)
else
  log "git worktree add -b $name $target ${ref:-HEAD} (repo root: $root)"
  git worktree add -b "$name" "$target" "${ref:-HEAD}" >&2
fi

printf '%s\n' "$target"
