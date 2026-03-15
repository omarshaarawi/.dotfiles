# PR Review Flow

How to review PRs without disrupting your current work.

## Plugins

### octo.nvim (GitHub integration)

Full PR and issue management inside neovim. Diffs render in buffers
so LSP, treesitter, and your keybindings all work.

```
<leader>op              list PRs (telescope picker)
<leader>oi              list issues
<leader>os              search GitHub
```

From a PR buffer:

```
<localleader>vs         start review (opens diff tab with file panel)
<localleader>vr         resume a pending review
]q / [q                 next/prev changed file
]t / [t                 next/prev comment thread
<localleader>ca         add comment (visual select for multi-line)
<localleader>sa         add suggestion (visual select the code)
<localleader>vs         submit review
<C-a>                   approve (in submit window)
<C-r>                   request changes (in submit window)
<C-m>                   comment only (in submit window)
<C-c>                   close review tab
<localleader>pm         merge
<localleader>psm        squash and merge
<localleader>prm        rebase and merge
<C-b>                   open in browser
```

### diffview.nvim (multi-file diffs)

For viewing local changes, branch diffs, and file history. Reads
from git (works with jj colocated repos).

```
<leader>dv              open diffview (all uncommitted changes)
<leader>dc              close diffview
<leader>dh              file history for current file
<leader>db              full branch history
```

Inside diffview: `j`/`k` in the file panel, `<CR>` to open a file,
`]c`/`[c` to jump between hunks.

You can also pass a range: `:DiffviewOpen origin/main...HEAD`

### 99 (agent-assisted review)

Pipes agent results (OpenCode/Claude Code) into your quickfix list.

```
<leader>9s              search (prompts for query, results in quickfix)
<leader>9v              visual replace (select code, give prompt)
<leader>9x              stop all in-flight requests
```

### supermaven (inline completions)

Ghost text appears as you type. No special commands needed.

```
<Tab>                   accept full suggestion
<C-j>                   accept one word
<C-]>                   dismiss
```

First launch: `:SupermavenUseFree` or `:SupermavenUsePro` to activate.

### hunk.nvim (jj diff editor)

Not invoked from neovim directly. Triggered by jj when it needs
interactive diff selection:

```bash
jj split                # split current commit
jj squash -i            # interactively pick hunks to squash
```

Inside hunk.nvim:

```
a                       toggle a line
A                       toggle a hunk
]h / [h                 next/prev hunk
<Tab>                   jump between left/right panes
<leader><CR>            accept selection
q                       abort (exits non-zero, jj cancels)
```

## Review workflows

### Quick review (no checkout)

For most PRs. Octo fetches everything from the GitHub API. Your
working copy is untouched.

```
<leader>op                          pick the PR
<localleader>vs                     start review
]q / [q                             navigate changed files
<localleader>ca                     comment (visual select for multi-line)
<localleader>sa                     suggest replacement code
<localleader>vs                     submit
<C-a> / <C-r> / <C-m>              approve / request changes / comment
```

No LSP, no running tests. If you need those, use the deep review.

### Deep review (need to run the code)

Use a jj workspace. Second working copy, same repo. Your current
work stays exactly where it is.

#### Setup (one time per repo)

```bash
jj workspace add ../myrepo-review
```

Two directories now:

```
~/git/myrepo/           # your work (default workspace)
~/git/myrepo-review/    # for reviews
```

#### Review

```bash
cd ~/git/myrepo-review
jj git fetch
jj new <pr-branch>@origin          # check out the PR code
just test                           # run tests, build, whatever
```

Open neovim in the review workspace:

```
<leader>dv              diffview to inspect changes
<leader>op              octo to leave comments
<leader>9s              ask agent: "review these changes, focus on
                        error handling and edge cases"
```

Walk through 99 results in quickfix (`]q`/`[q`), use octo to post
the ones you agree with.

#### When done

```bash
jj abandon @                        # drop the temporary commit
cd ~/git/myrepo                     # back to your work
```

#### Cleanup (optional)

```bash
jj workspace forget review
rm -rf ../myrepo-review
```

Or just leave it. Costs almost nothing.

### Agent-assisted review

Use 99 before or during your manual review:

```
<leader>9s
> review PR #123, check for:
> - missing error handling
> - broken type contracts
> - untested edge cases
> - anything that could break existing behavior
```

Results go to quickfix. Use as a starting point, not a replacement
for your own review.

### Resuming a review

If you started a review in octo and got interrupted:

```
<leader>op              pick the same PR
<localleader>vr         resume pending review (not vs)
```

Your draft comments are still there.
