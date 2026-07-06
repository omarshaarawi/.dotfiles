---
name: jujutsu
description: "Required for any git/VCS operation. If `.jj/` exists, this is a Jujutsu (jj) repo — raw git commands may desync repository state. Load this skill before running VCS commands."
allowed-tools: Bash(jj *)
---

# Jujutsu (jj) Version Control System

A Git-compatible VCS with mutable commits, automatic rebasing, and no staging area.

**Tested with jj v0.42.0** — jj evolves quickly; verify commands against `jj help <subcommand>` if something fails.

---

## Non-Interactive Environment Rules

When running as an agent or in any non-interactive context, several jj commands open an editor or interactive UI and will hang indefinitely. Follow these rules strictly:

| Blocked command | Safe alternative |
|---|---|
| `jj desc` (no `-m`) | `jj desc -m "message"` |
| `jj squash` (no `-m`, inherits parent msg) | `jj squash -m "message"` if you need to set the message |
| `jj split` | Use `jj restore` to manually redistribute changes |
| `jj squash -i` | Use `jj restore` and targeted squash instead |
| `jj resolve` | Edit conflict markers in files directly |
| `jj commit` (no `-m`) | `jj commit -m "message"` |

**After any mutation** (`squash`, `abandon`, `rebase`, `restore`, `absorb`), run `jj st` to confirm success.

---

## Core Concepts

### The working copy is a commit

Your working directory is always a commit, referenced as `@`. Changes are automatically snapshotted when you run any jj command. There is no staging area and no need to `git add`.

### Commits are mutable

Unlike git, any commit can be freely modified after creation. This means you can refine messages, split or combine commits, and reorder history without ceremony.

### Change IDs vs commit IDs

- **Change ID** (e.g., `tqpwlqmp`): Stable across rewrites. Prefer these in commands.
- **Commit ID** (e.g., `3ccf7581`): Content hash that changes when the commit is rewritten.

### Revsets

Revsets are jj's language for selecting revisions. A few essential patterns:

```bash
@              # Working copy
@-             # Parent of working copy
@--            # Grandparent
foo-            # Parent of change "foo"
foo+            # Children of change "foo"
foo::bar        # foo through bar (inclusive)
bookmarks()     # All bookmarked revisions
mine()          # Your commits
description(regex)  # Commits matching description
```

Use revsets anywhere a revision is expected: `jj log -r 'mine() & ~empty()'`

Full reference: `jj help revsets`

---

## First-Time Setup

```bash
# Set your identity
jj config set --user user.name "Your Name"
jj config set --user user.email "you@example.com"
```

---

## Essential Workflow

### Starting work

```bash
# Describe what you intend to do
jj desc -m "Add user authentication to login endpoint"

# Make your changes — they're automatically tracked
# ... edit files ...

# Check status
jj st
```

Alternatively, some people prefer coding first and describing after — jj supports both equally well:

```bash
# Make changes first
# ... edit files ...

# Then describe what you did
jj desc -m "Add user authentication to login endpoint"
```

### Creating the next commit

```bash
# Finish current work, start a new empty commit on top
jj new
jj desc -m "Next task description"
```

`jj commit -m "message"` is a shorthand that describes the current commit and creates a new empty one on top in a single step:

```bash
jj commit -m "Add user authentication to login endpoint"
# Equivalent to: jj desc -m "..." && jj new
```

### Viewing history

```bash
jj log                    # Recent commits
jj log -p                 # With diffs
jj log -r 'mine()'       # Only your commits
jj show <change-id>      # Specific commit details
jj diff                   # Working copy changes
jj diff --from @- --to @  # Explicit parent-to-working-copy diff
```

### Moving between commits

```bash
jj new                     # New empty commit on top of current
jj new <change-id>         # New commit on top of a specific revision
jj new <id1> <id2>         # New merge commit with multiple parents
jj edit <change-id>        # Switch working copy to an existing commit
jj prev -e                 # Edit the parent commit
jj next -e                 # Edit the child commit
```

---

## Refining Commits

### Squashing

Move changes from the current commit into its parent:

```bash
jj squash                  # Squash all changes into parent
jj squash -m "Combined message"  # With explicit message
jj squash --into <id>      # Squash into a specific ancestor (not just parent)
```

### Absorbing

Automatically distribute working copy changes to the commits that last modified those lines:

```bash
jj absorb
```

This is powerful for fixup workflows — make corrections in your working copy and absorb routes each hunk to the right ancestor commit.

### Restoring and discarding

```bash
jj restore                          # Discard all working copy changes
jj restore path/to/file.txt        # Discard changes to specific files
jj restore --from <id> file.txt    # Restore a file from another revision
```

### Abandoning

Remove a commit entirely; its descendants are rebased onto its parent:

```bash
jj abandon <change-id>
```

### Undoing

Reverse the last jj operation (works for any command):

```bash
jj undo
```

### Viewing the operation log

```bash
jj op log    # See all operations, useful before undo
```

---

## Rebasing

One of jj's most powerful features. All rebases automatically cascade to descendants.

```bash
# Rebase current commit onto a new parent
jj rebase -r @ -d <new-parent>

# Rebase a commit and all its descendants
jj rebase -s <change-id> -d <new-parent>

# Rebase a range of commits
jj rebase -s <start> -d <destination>
```

Common patterns:

```bash
# Move your work on top of latest main
jj rebase -s <your-branch-root> -d main

# Reorder commits: move commit X before commit Y
jj rebase -r <X> -d <Y->   # Place X before Y (on Y's parent)
```

---

## Bookmarks (Branches)

Bookmarks are jj's equivalent of git branches. **They do not auto-advance** — you must move them manually.

```bash
jj bookmark create my-feature -r @     # Create at current commit
jj bookmark move my-feature --to @      # Move to current commit
jj bookmark list                        # List all bookmarks
jj bookmark delete my-feature           # Delete a bookmark
```

---

## Git Integration

### Cloning and initializing

```bash
jj git clone <url>              # Clone a git repo into a jj repo
jj git init --colocate          # Initialize jj inside an existing git repo
```

### Fetching and pushing

```bash
jj git fetch                    # Fetch from all remotes
jj git fetch --remote origin    # Fetch from a specific remote

jj git push -b <bookmark-name>  # Push a bookmark
```

**Before pushing**, always verify:
1. The bookmark points to the intended commit: `jj bookmark list`
2. The commits are clean and atomic: `jj log -r <bookmark>`
3. Move the bookmark if needed: `jj bookmark move <name> --to @`

### Colocated repos (`.jj/` + `.git/`)

This is the most common setup. Both tools see the same repository, but they can get out of sync.

**Rules for colocated repos:**
- Prefer jj commands for all day-to-day work
- jj automatically exports bookmarks to git branches and imports git changes
- If you must use git directly (e.g., for a tool that requires it), ensure jj's working copy is clean first with `jj st`
- After running git commands, run any jj command (e.g., `jj st`) to trigger re-import
- Avoid `git commit`, `git rebase`, `git merge` — let jj handle these operations

**If git complains about detached HEAD:** This is normal. jj doesn't use git's HEAD the same way. Use jj commands to navigate.

---

## Trunk-Based Workflow (This Setup)

This machine's jj config (`~/.dotfiles/.config/jj/config.toml`) defines custom aliases for a
trunk-based, stacked-diff workflow. Prefer these over hand-rolling the equivalent commands.

`trunk()` resolves to the remote's main branch (e.g. `main@origin` / `development@origin`). It
**only advances when you fetch** — there is no auto-fetch hook, so **always run `jj git fetch`
before rebasing onto trunk.**

| Alias | Expands to | Use for |
|---|---|---|
| `jj nt` | `new trunk()` | Start fresh work on top of trunk |
| `jj tug` | `bookmark move --from heads(::@- & bookmarks()) --to @-` | Move the nearest bookmark up to `@-` (after `jj new`, before push) |
| `jj open` | `log -r open()` | List all your open stacks |
| `jj retrunk -s <rev>` | `rebase -d trunk() -s <rev>` | Rebase a specific revision/stack onto trunk |
| `jj reheat` | `rebase -d trunk() -s roots(trunk()..stack(@))` | Rebase the *current* stack onto fresh trunk |
| `jj consume <rev> [paths]` | `squash --into @ --from <rev>` | Pull content from `<rev>` into `@` |
| `jj eject <rev>` | `squash --from @ --into <rev>` | Push content from `@` into `<rev>` |
| `jj examine <rev>` | `log -T builtin_log_detailed -p -r <rev>` | Detailed `-p` view of a revision |

Typical loop:

```bash
jj git fetch            # advance trunk()
jj nt                   # new work on trunk
jj desc -m "..."        # describe, then edit files
# ... iterate, refine ...
jj tug                  # move the bookmark to your finished commit
jj git push -b <name>   # push
```

To pick up new trunk under in-progress work: `jj git fetch && jj reheat`.

**Stale/divergent local bookmark** (e.g. local `development` drifted onto a feature commit):
reset it to the remote instead of rebasing onto it.

```bash
jj bookmark set development -r development@origin
```

⚠️ **Check for unpushed commits FIRST.** Resetting a bookmark onto the remote silently orphans
any local commits the remote doesn't have — this has destroyed real, verified work (OpenTag,
2026-07-01: four unpushed commits on `main` dropped by exactly this reset; recovered days later
from `refs/jj/keep`). Before any `jj bookmark set <name> -r <name>@origin`:

```bash
jj log -r '<name>@origin..<name>' --no-graph   # anything listed = unpushed local commits
```

If that prints commits, they are about to be orphaned — push them, re-land them on a dev branch,
or explicitly decide to discard them. Only reset when it prints nothing.

Because `trunk()` tracks the remote, a drifting local bookmark won't poison rebases — but reset it
anyway so `jj log` reads true.

**Repo-analytics aliases** also exist (`jj churn`, `jj authors`, `jj hotspots`, `jj velocity`,
`jj firefights`) — they shell out via `jj util exec` to summarize commit history. Handy for
investigating a codebase; not part of the day-to-day commit loop.

---

## Handling Conflicts

jj allows you to commit conflicts and resolve them later — they don't block your workflow.

```bash
# See what's conflicted
jj st

# View conflict details
jj diff
```

**To resolve conflicts in a non-interactive environment:**

1. Open the conflicted file — look for conflict markers:
   ```
   <<<<<<< Conflict 1 of 1
   %%%%%%% Changes from base to side #1
   -old line
   +side 1 line
   +++++++ Contents of side #2
   side 2 line
   >>>>>>>
   ```
   Note: jj uses a diff-style format, not git's `<<<<<<<`/`=======`/`>>>>>>>` format. The `%%%%%%%` section shows a diff from the base to one side, and the `+++++++` section shows the other side's content.

2. Edit the file to contain the desired result, removing all markers

3. Verify resolution: `jj st` — the file should no longer show as conflicted

---

## Commit Message Style

Use imperative verb phrases in sentence case, no trailing period:

```
Add validation to user input forms
Fix null pointer in payment processor
Remove deprecated API endpoints
Update dependencies to latest versions
```

This is a common convention, not a hard rule — match whatever style the project uses.

---

## Quick Reference

| Action | Command |
|---|---|
| Describe commit | `jj desc -m "message"` |
| View status | `jj st` |
| View log | `jj log` |
| View diff | `jj diff` |
| New commit | `jj new` |
| Commit + new | `jj commit -m "message"` |
| Edit commit | `jj edit <id>` |
| Squash to parent | `jj squash` |
| Squash to target | `jj squash --into <id>` |
| Auto-distribute | `jj absorb` |
| Rebase | `jj rebase -r <id> -d <dest>` |
| Abandon commit | `jj abandon <id>` |
| Undo last operation | `jj undo` |
| Operation history | `jj op log` |
| Restore files | `jj restore [paths]` |
| Create bookmark | `jj bookmark create <name> -r @` |
| Move bookmark | `jj bookmark move <name> --to @` |
| Fetch from remote | `jj git fetch` |
| Push bookmark | `jj git push -b <name>` |
| Set config | `jj config set --user <key> "value"` |
| New work on trunk | `jj nt` |
| Move bookmark to `@-` | `jj tug` |
| List open stacks | `jj open` |
| Rebase stack onto trunk | `jj git fetch && jj reheat` |
| Rebase rev onto trunk | `jj retrunk -s <rev>` |
| Reset stale bookmark | `jj bookmark set <name> -r <name>@origin` |
