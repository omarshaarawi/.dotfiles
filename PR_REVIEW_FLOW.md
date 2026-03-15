# PR Review Flow

How to review PRs without disrupting your current work.
Uses jj workspaces, octo.nvim, diffview, and 99.

## The problem

You're mid-task. A co-worker asks you to review their PR. You need to:

1. See their code without losing your in-progress work
2. Run their code / tests if needed
3. Leave comments, approve or request changes
4. Get back to exactly where you were

## Quick review (no checkout needed)

If you just need to read the diff and leave comments, you don't need to
check anything out. Octo fetches everything from the GitHub API.

```
nvim
<leader>op                          pick the PR
<localleader>vs                     start review
]q / [q                             navigate changed files
<localleader>ca                     comment on a line (visual select for multi-line)
<localleader>sa                     suggest replacement code (visual select)
<localleader>vs                     submit
<C-a> approve / <C-r> request changes / <C-m> comment only
```

No branch switching, no stashing, no worktrees. Your working copy is
untouched. This covers 80% of reviews.

Downside: no LSP, no running tests, no jumping to definitions outside
the diff. If you need that, read on.

## Deep review (need to run the code)

Use a jj workspace. This gives you a second working copy of the same
repo in a separate directory. Your current work stays exactly where it
is.

### Setup (one time per repo)

From your repo root:

```bash
jj workspace add ../myrepo-review
```

This creates `../myrepo-review` with its own working copy, sharing the
same jj repo. You now have two directories:

```
~/git/myrepo/           # your normal work (default workspace)
~/git/myrepo-review/    # for reviews
```

### Review flow

```bash
# fetch the PR branch
cd ~/git/myrepo-review
jj git fetch

# find the PR's branch and create a new commit on top of it
jj new <pr-branch-bookmark>
# example: jj new origin/feature/auth-refactor

# now you have the PR code in ~/git/myrepo-review
# run tests, build, whatever
just test
```

Open neovim in the review workspace:

```bash
nvim .
```

From neovim:

```
<leader>dv                          diffview against the base branch
<leader>op                          octo to leave comments
<leader>9s                          ask 99 to review: "review the changes
                                    on this branch, focus on error handling
                                    and missing edge cases"
```

The 99 results land in your quickfix list. Walk through them with `]q`,
use octo to post the ones you agree with.

### When done

```bash
# back in the review workspace
jj abandon @                        # drop the temporary commit
```

Switch back to your normal workspace:

```bash
cd ~/git/myrepo
```

Your work is exactly where you left it. jj workspaces share the repo
but have independent working copies.

### Cleanup (optional)

If you rarely review and don't want the extra directory hanging around:

```bash
jj workspace forget review          # if you named it "review"
rm -rf ../myrepo-review
```

Or just leave it. It costs almost nothing (it's the same repo, just a
second working copy checkout).

## Agent-assisted review

Before or during your review, use 99 to get a first pass:

```
<leader>9s
> review PR #123, check for:
> - missing error handling
> - broken type contracts
> - untested edge cases
> - anything that could break existing behavior
```

Results go to your quickfix list. Navigate with `]q` / `[q`. Use these
as a starting point for your own review, not a replacement.

You can also target specific concerns:

```
<leader>9s
> are there any race conditions in the changes to the connection pool?
```

## Resuming a review

If you started a review in octo and got interrupted:

```
<leader>op                          pick the same PR
<localleader>vr                     resume pending review (not vs, which starts a new one)
```

Your draft comments are still there.

## Cheat sheet

| Action                        | Command                            |
|-------------------------------|-------------------------------------|
| List PRs                      | `<leader>op`                       |
| List issues                   | `<leader>oi`                       |
| Start review                  | `<localleader>vs`                  |
| Resume review                 | `<localleader>vr`                  |
| Next/prev changed file        | `]q` / `[q`                        |
| Next/prev comment thread      | `]t` / `[t`                        |
| Add comment                   | `<localleader>ca`                  |
| Add suggestion                | `<localleader>sa`                  |
| Submit review                 | `<localleader>vs`                  |
| Approve                       | `<C-a>` (in submit window)         |
| Request changes               | `<C-r>` (in submit window)         |
| Comment only                  | `<C-m>` (in submit window)         |
| Close review tab              | `<C-c>`                            |
| Merge PR                      | `<localleader>pm`                  |
| Squash merge                  | `<localleader>psm`                 |
| Open diffview                 | `<leader>dv`                       |
| Close diffview                | `<leader>dc`                       |
| File history                  | `<leader>dh`                       |
| 99 search                     | `<leader>9s`                       |
| Fetch PR branch (terminal)    | `jj git fetch`                     |
| Create review workspace       | `jj workspace add ../repo-review`  |
| Jump to PR code               | `jj new <pr-branch>`               |
| Clean up after review         | `jj abandon @`                     |
| Forget workspace              | `jj workspace forget review`       |
