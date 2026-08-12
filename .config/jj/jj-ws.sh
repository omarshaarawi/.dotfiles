#!/usr/bin/env bash
# Workspace lifecycle for jj. `sprout` makes one, `reap` removes the finished ones.
#
# Why this exists: nothing in jj retires a workspace. They accumulate, go stale, and
# a stale workspace is not merely clutter -- with snapshot.auto-update-stale=true it
# will silently discard unsnapshotted edits. Reaping on landing is what keeps a
# workspace from ever reaching that state.
set -uo pipefail

# Every jj call here pins auto-update-stale=false. Reap must be able to SEE a stale
# workspace's uncommitted edits to refuse to delete it; letting jj auto-reset first
# would destroy the very evidence the safety check depends on.
jjq() { jj --config snapshot.auto-update-stale=false "$@"; }

die() { printf 'jj-ws: %s\n' "$*" >&2; exit 1; }

root="$(jjq workspace root 2>/dev/null)" || die "not inside a jj workspace"
repo_root="$(cd "$root" && jjq root 2>/dev/null)" || repo_root="$root"
here="$(basename "$root")"

# name<TAB>abs-path for every workspace in this repo.
workspaces() {
  (cd "$repo_root" && jjq workspace list 2>/dev/null) | while IFS= read -r line; do
    n="${line%%:*}"; rest="${line#*: }"; p="${rest%% *}"
    [ "$p" = "." ] && a="$repo_root" || a="$(cd "$repo_root" && cd "$p" 2>/dev/null && pwd)"
    [ -n "$a" ] && printf '%s\t%s\n' "$n" "$a"
  done
}

# Commits this workspace would lose. jj's immutable set is trunk ancestors + tags +
# untracked remote bookmarks, so anything still mutable AND non-empty exists only in
# this checkout: not landed, not pushed. Zero of those means nothing is at risk.
# Names are quoted -- workspace names contain '-' and dates, which the revset parser
# would otherwise chew on.
unlanded() {
  (cd "$repo_root" && jjq log --no-graph -r "mutable() & ~empty() & ::'$1'@" -T '"x\n"' 2>/dev/null) | grep -c '^x$'
}

# Which of the three safe cases applies, so the verdict is auditable rather than
# a bare "trust me".
why_safe() {
  local d
  d="$(cd "$repo_root" && jjq log --no-graph -r "'$1'@" \
        -T 'if(empty,"empty","") ++ "\t" ++ remote_bookmarks.map(|b| b.name()).join(",")' 2>/dev/null | head -1)"
  local e="${d%%	*}" r="${d##*	}"
  if [ -n "$e" ]; then echo "empty, nothing to lose"
  elif [ -n "$r" ]; then echo "pushed: ${r%%,*}"
  else echo "landed on trunk"; fi
}

cmd_reap() {
  local apply=0
  [ "${1:-}" = "--apply" ] && apply=1

  printf '%-38s %-9s %s\n' WORKSPACE VERDICT REASON
  local reap=() n
  while IFS=$'\t' read -r name path; do
    [ -z "$name" ] && continue
    if [ "$name" = "default" ]; then
      printf '%-38s %-9s %s\n' "$name" keep "default workspace"; continue
    fi
    if [ "$path" = "$root" ]; then
      printf '%-38s %-9s %s\n' "$name" keep "you are standing in it"; continue
    fi
    # Snapshot first so uncommitted edits become real commits and are counted below.
    # Without this a workspace full of unsaved work looks empty and gets reaped.
    [ -d "$path" ] && (cd "$path" && jjq st >/dev/null 2>&1)
    n="$(unlanded "$name")"
    if [ "$n" -gt 0 ]; then
      printf '%-38s %-9s %s\n' "$name" KEEP "$n commit(s) only in this checkout"
    else
      printf '%-38s %-9s %s\n' "$name" reap "$(why_safe "$name")"
      reap+=("$name	$path")
    fi
  done < <(workspaces)

  [ "${#reap[@]}" -eq 0 ] && { echo; echo "nothing to reap."; return 0; }

  echo
  if [ "$apply" = 0 ]; then
    echo "${#reap[@]} reapable. re-run 'jj reap --apply' to remove them."
    return 0
  fi
  for e in "${reap[@]}"; do
    name="${e%%	*}"; path="${e##*	}"
    (cd "$repo_root" && jjq workspace forget "$name") >/dev/null 2>&1 \
      || { echo "  ! forget failed: $name (left on disk)"; continue; }
    rm -rf "$path" || { echo "  ! rm failed: $path"; continue; }
    echo "  reaped $name"
  done
}

cmd_sprout() {
  local name="${1:-}"
  [ -z "$name" ] && die "usage: jj sprout <name>"
  local parent dir
  parent="$(dirname "$repo_root")"
  dir="$parent/$(basename "$repo_root")-$name"
  [ -e "$dir" ] && die "$dir already exists"

  (cd "$repo_root" && jjq workspace add --name "$name" "$dir") || die "workspace add failed"

  # Deps are per-workspace on purpose: workspaces sit on different commits, so a
  # shared node_modules would hand you another branch's dependency tree. bun already
  # hardlinks from its global cache, so the real cost is far below the apparent size.
  if [ -f "$dir/bun.lock" ] || [ -f "$dir/bun.lockb" ]; then
    ( cd "$dir" && bun install ) || echo "jj-ws: bun install failed in $dir -- run it yourself"
  elif [ -f "$dir/package-lock.json" ]; then
    ( cd "$dir" && npm ci ) || echo "jj-ws: npm ci failed in $dir -- run it yourself"
  fi
  echo "sprouted $dir"
}

case "${1:-}" in
  reap)   shift; cmd_reap "$@" ;;
  sprout) shift; cmd_sprout "$@" ;;
  *) die "usage: jj-ws {reap [--apply] | sprout <name>}" ;;
esac
