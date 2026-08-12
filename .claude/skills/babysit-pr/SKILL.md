---
name: babysit-pr
description: "Use when the user asks to babysit, watch, monitor, shepherd, or nurse a PR, or says 'file and babysit', 'keep an eye on it', 'get it green', or 'land it'. Covers waiting on CI, fixing real failures, keeping the branch current with trunk, and merging. For opening the PR in the first place, use file-pr."
---

# Babysit a PR

The job is to get the PR green and landed without expanding it. You are done when it merges, or when you hit something that needs a human.

## Setup

1. If `.jj/` exists, load the `jj-vcs` skill first.
2. Confirm which PR you are on (`gh pr view --json number,url,headRefName`). Never guess the number.

## Waiting on checks

Do not poll with `sleep`. `sleep 120 && gh run view ...` is blocked by the harness, and burning turns on it is the single most common mechanical failure in this setup (84 blocked calls across the history, 50 of them from one model). Use `Monitor` with an until-loop instead, or a single long-timeout foreground command that exits when the condition is met.

Pick the interval from how long CI actually takes in this repo, not from a guess. In `opentag` the combined `fmt · lint · typecheck · test · web build` check runs about 4m15s, so one check at ~4 minutes beats eight checks at 30 seconds. If you do not know the repo's CI duration, read it once from a recent run (`gh run list --limit 5 --json conclusion,createdAt,updatedAt`) and size the wait from that.

## When a check fails

1. Read the actual failing log. Do not infer the cause from the job name.
2. Separate a real failure from infrastructure flake. A flake gets one re-run; a real failure gets a fix.
3. Fix the cause where it lives, not where the check happened to notice it. A test that fails because the code is wrong gets a code fix, never a loosened assertion.
4. Push the fix and wait again.

If the same check fails three times for three different reasons, stop and report. That usually means the change is wrong at a level CI cannot tell you about.

## Keeping current with trunk

Watch for movement on trunk and rebase when the PR falls behind. If a PR that landed while you were waiting makes this one redundant, stop, report it, and ask before closing. Do not close a PR on your own initiative.

## Review comments

These repos usually have no review bots, so most PRs go green and land with no comments. If a human or a bot does comment:

- Verify every finding against the source before changing anything. A confident review comment is still a claim, not a fact.
- Fix the real ones. Reply with a written reason when dismissing one, then resolve it.
- Do not let review feedback expand the PR beyond the original goal. Address genuine shortcomings; note anything larger as follow-up work instead of absorbing it.

## Merging

Merge once checks are green and nothing is outstanding. Move the bookmark to tip and push once rather than pushing commits one at a time.

Report the merge with the PR URL. If you stopped short of merging, say exactly what blocked you and what you would do next.

## Scope

Never grow the diff while babysitting. The change that was reviewed is the change that lands. New problems you notice along the way get reported to the user, not fixed in this PR.
