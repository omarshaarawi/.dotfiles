# jj Workflow

Day-to-day jj workflows for personal repos and team repos where
your team uses git and you can't push to main.

## Core concepts

Your working directory is always a commit (`@`). There's no staging
area. Every jj command auto-snapshots your changes. Just edit files
and jj tracks everything.

Bookmarks are jj's branches. They don't auto-advance like git
branches. You move them explicitly or let `jj git push --change`
create them for you.

### describe vs commit vs new

These are the building blocks. Understand how they compose:

- `jj describe -m "msg"` -- label the current change. Can be done
  at any time, before/during/after working. Does not create a new
  change.
- `jj new` -- start a new empty change on top of the current one.
  The previous change is now "done" (but still editable later).
- `jj commit -m "msg"` -- shorthand for `jj describe -m "msg" && jj new`.

Both styles are idiomatic. Use whichever fits your brain:

```bash
# style A: describe as you go
jj describe -m "add rate limiting"
# ... work ...
jj new

# style B: commit when done
# ... work ...
jj commit -m "add rate limiting"
```

Style A lets you describe your intent before writing code, then
refine the message later. Style B is closer to the git habit.
Either way, `@` is always your in-progress work.

## Trunk branch

All aliases use `trunk()` which defaults to `main` or `master`. If
your team uses a different branch as the starting point (e.g.
`development`), override it globally or per-repo.

**Global default** (applies to all repos) in `~/.config/jj/config.toml`:

```toml
[revset-aliases]
'trunk()' = 'main'
```

**Per-repo override** (for repos that differ), run from inside the repo:

```bash
jj config set --repo revset-aliases.'trunk()' 'development'
```

This writes to `.jj/repo/config.toml` and only affects that repo.
Repos without a local override use the global default.

Every alias (`nt`, `reheat`, `retrunk`, the default log) will then
target the correct branch per repo. No other changes needed.

## Aliases

These are configured in `~/.config/jj/config.toml`:

| Alias       | What it does                                              |
|-------------|-----------------------------------------------------------|
| `jj nt`     | `jj new trunk()` -- start new work on main                |
| `jj tug`    | Move closest bookmark to `@-` -- for trunk-based push     |
| `jj open`   | List all your open stacks of work                         |
| `jj reheat` | Rebase current stack onto updated trunk                   |
| `jj retrunk`| Rebase arbitrary revisions onto trunk                     |
| `jj consume`| Move content from another change into `@`                 |
| `jj eject`  | Move content from `@` into another change                 |
| `jj examine`| Detailed view of any revision with diff                   |

## Personal repos (push to main)

For dotfiles, side projects, anything where you own main.

### The loop

```bash
jj nt                               # new change on trunk
jj describe -m "what you're doing"

# ... make changes ...

jj commit -m "what you did"         # or describe + new separately
jj tug                              # move main to @-
jj git push -b main
```

### Quick fixes

```bash
# change a description (any commit, not just @)
jj describe -m "better message"
jj describe -r <change-id> -m "fix that old message"

# undo the last jj operation (works for any command)
jj undo

# discard all working copy changes
jj restore

# discard changes to a specific file
jj restore path/to/file.txt
```

## Team repos (PRs required)

Your team uses git. Main is protected. You push feature branches
and open PRs. Nobody knows or cares that you use jj.

### Start a task

```bash
jj nt                               # new change on trunk
jj describe -m "feat: add rate limiting to API"

# ... work ...
```

### Push for review

`--change` auto-creates a bookmark named `push-<change-id>` and
pushes it. This is the official recommended workflow:

```bash
# if @ has your work:
jj git push --change @

# if @ is empty (you already did jj new):
jj git push --change @-
```

Then open the PR. `--head` is required because jj leaves git in
detached HEAD:

```bash
gh pr create --head push-<change-id> --base main \
  --title "feat: add rate limiting to API" \
  --body "description"
```

### Address review feedback

Edit the original commit directly. jj doesn't care about rewriting
history on unpushed or force-pushable branches:

```bash
jj edit <change-id>                 # switch working copy to that commit
# ... make fixes ...
jj git push --change <change-id>    # force-pushes automatically
jj new                              # back to a fresh working copy
```

Or add a new commit on top (if your team prefers additive history):

```bash
jj new <change-id>
jj describe -m "address review: handle nil case"
# ... fix ...
jj bookmark move push-<change-id> --to @
jj git push -b push-<change-id>
```

### Stay up to date with main

Someone merged to main while you're working:

```bash
jj git fetch                        # update remote bookmarks
jj reheat                           # rebase current stack onto updated trunk
```

If you have multiple in-flight branches, rebase each:

```bash
jj rebase -b <change-id> -d main
```

Or rebase all open work at once:

```bash
jj retrunk -s 'roots(open())'
```

### After PR is merged

```bash
jj git fetch                        # main advances to include your PR
jj nt                               # start fresh on updated trunk
```

Clean up the stale push bookmark:

```bash
jj bookmark delete push-<change-id>
jj git push --deleted
```

### Stacked PRs

PR B depends on PR A, but A hasn't merged yet.

```bash
# PR A
jj nt
jj describe -m "feat: add auth middleware"
# ... work ...
jj git push --change @

# PR B, on top of A
jj new
jj describe -m "feat: add rate limiting (needs auth)"
# ... work ...
jj git push --change @
```

Open PR A targeting main. Open PR B targeting PR A's branch.

When PR A merges:

```bash
jj git fetch
jj reheat                           # rebases B onto merged main
jj git push --change <B-change-id>  # force-pushes updated B
```

Now retarget PR B to main on GitHub.

## Workspaces

For running tests in one workspace while coding in another, or
reviewing a co-worker's PR without touching your work.

### Create a workspace

```bash
jj workspace add ../myrepo-review
```

Same repo, separate working copy. Each workspace can have a
different commit checked out.

### Use it for reviews

```bash
cd ../myrepo-review
jj git fetch
jj new <pr-branch>@origin           # check out the PR
# run tests, review code
jj abandon @                        # clean up when done
cd ../myrepo                        # back to your work
```

See PR_REVIEW_FLOW.md for the full review workflow with neovim.

### Use it for long-running tests

```bash
jj workspace add ../myrepo-test
cd ../myrepo-test
jj edit <the-commit-to-test>
just test                            # runs while you keep coding
```

### Stale workspace

If you modify a workspace's commit from another workspace, it
becomes stale. Fix it:

```bash
cd ../myrepo-review
jj workspace update-stale
```

### Clean up

```bash
jj workspace forget <workspace-name>
rm -rf ../myrepo-test
```

## Splitting and squashing

### Split a commit (hunk.nvim)

```bash
jj split                            # opens neovim with hunk.nvim
                                    # select hunks for first commit
                                    # rest goes in second commit
```

### Squash into parent

```bash
jj squash                           # all changes into parent
jj squash -m "combined message"     # with new message
jj squash --into <id>               # into a specific ancestor
```

### Move content between changes

```bash
jj consume <change-id> path/to/file # pull content from another change into @
jj eject <change-id> --interactive  # push content from @ into another change
```

These are inverses. Useful when you accidentally put work in the
wrong commit.

### Absorb

Auto-distribute working copy changes into the commits that last
touched those lines:

```bash
jj absorb
```

Make corrections, `jj absorb` routes each hunk to the right
ancestor. Great for fixup workflows.

## Conflicts

jj lets you commit conflicts and resolve them later.

```bash
jj st                               # shows conflicted files
jj diff                             # shows conflict markers
```

jj conflict markers are different from git:

```
<<<<<<< Conflict 1 of 1
%%%%%%% Changes from base to side #1
-old line
+side 1 line
+++++++ Contents of side #2
side 2 line
>>>>>>>
```

Edit the file to remove markers. `jj st` to verify resolution.
You can resolve conflicts incrementally, one file at a time, or
even partially within a file.

## Useful commands

```bash
jj open                                        # all your in-flight work
jj examine <change-id>                         # detailed view with diff
```

## Useful revsets

```bash
jj log -r 'mine()'                             # your commits
jj log -r 'mine() & ~empty()'                  # your non-empty commits
jj log -r 'stack()'                            # current stack of work
jj log -r 'open()'                             # all open stacks
jj log -r 'bookmarks() & ~remote_bookmarks()'  # local-only bookmarks
jj log -r 'remote_bookmarks()..@'              # ancestors of @ not on remote
jj log -r 'trunk()..@'                         # your stack on top of trunk
```

## Quick reference

| Action                    | Command                                  |
|---------------------------|------------------------------------------|
| Start work on trunk       | `jj nt`                                  |
| Describe                  | `jj desc -m "message"`                   |
| Describe + new            | `jj commit -m "message"`                 |
| View status               | `jj st`                                  |
| View diff                 | `jj diff`                                |
| View log                  | `jj log`                                 |
| View all open work        | `jj open`                                |
| Detailed view of revision | `jj examine <change-id>`                 |
| Push PR (auto-bookmark)   | `jj git push --change @`                 |
| Push bookmark             | `jj git push -b <name>`                  |
| Move bookmark to @-       | `jj tug`                                 |
| Fetch                     | `jj git fetch`                           |
| Rebase stack onto trunk   | `jj reheat`                              |
| Rebase anything onto trunk| `jj retrunk -s <rev>`                    |
| Edit earlier commit       | `jj edit <change-id>`                    |
| Squash into parent        | `jj squash`                              |
| Squash into specific      | `jj squash --into <id>`                  |
| Pull content into @       | `jj consume <id> [paths]`                |
| Push content from @       | `jj eject <id> [--interactive]`          |
| Auto-distribute fixes     | `jj absorb`                              |
| Split commit              | `jj split`                               |
| Abandon commit            | `jj abandon <change-id>`                 |
| Undo last operation       | `jj undo`                                |
| Discard working changes   | `jj restore`                             |
| Create workspace          | `jj workspace add <path>`                |
| Delete stale bookmark     | `jj bookmark delete <name>`              |
| Push bookmark deletions   | `jj git push --deleted`                  |
