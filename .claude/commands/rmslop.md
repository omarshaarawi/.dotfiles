---
description: Remove AI code slop from the current branch
---

Check the diff of the current branch against trunk, and remove all AI generated slop introduced in this branch.

Getting the diff: if `.jj/` exists, load the jj-vcs skill and diff against `trunk()`. Otherwise use read-only git: diff against the merge-base with the default branch (`origin/HEAD`, falling back to `main`/`master`/`dev`, whichever exists).

Slop includes:

- Extra comments that a human wouldn't add or that are inconsistent with the rest of the file
- Extra defensive checks or try/catch blocks that are abnormal for that area of the codebase (especially if called by trusted / validated codepaths)
- Casts to `any` (or `as` casts) to get around type issues
- Dead code, unused parameters, stale imports introduced in this branch
- Breadcrumb comments ("// moved to X", "// previously did Y")
- Any other style that is inconsistent with the file
- Unnecessary emoji usage

Only touch lines introduced in this branch. Do not reformat or "improve" surrounding code.

Report at the end with only a 1-3 sentence summary of what you changed.

$ARGUMENTS
