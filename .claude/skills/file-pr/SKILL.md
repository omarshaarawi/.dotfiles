---
name: file-pr
description: "Use when the user asks to file, open, create, put up, or send a PR, including shorthand like 'file it', 'file and babysit', 'ship it', or 'open a PR for this'. Covers writing the title and body and pushing the bookmark or branch. For watching a PR until it merges, use babysit-pr."
---

# File a PR

## Before you write anything

1. If `.jj/` exists, load the `jj-vcs` skill first. Raw git writes desync jj state.
2. Check whether a PR for this change already exists (`gh pr list --head <bookmark>`). Update it instead of opening a second one.
3. Read the diff against trunk and confirm it matches what was actually asked for. If the diff contains work nobody asked for, stop and say so rather than filing it.
4. Read the last ~20 titles in this repo's log and match their capitalization and shape. The rules below are defaults; the repo's existing log wins.

## The title

The title becomes the commit subject. Single line, imperative, no conventional-commit prefix, no ticket prefix unless that repo already uses one.

State the behavior that changes, not the mechanism that changes it. A reader who was not in the conversation should be able to tell what is different afterward.

Real examples from `opentag`:

```
bad   feat(vault): add vault_resolve tool — agent reads any vault field by op:// ref
good  Deliver a reply's plain @Name as a real Discord mention

bad   TAG-455: SigV4 signing — AWS works properly from a hosted deploy
good  Stop the site selling a deployment we don't offer

bad   hotfix: tolerate legacy plaintext provider_defs (production crash loop)
good  Make the cluster namespace a tenant boundary, not a tuning knob
```

The bad ones lead with the machinery (`SigV4 signing`, `add vault_resolve tool`) or carry a prefix that this repo's own rules forbid. The good ones name the changed behavior and read as a sentence.

## The body

Empty, or one line. Not a summary of the diff, not a bulleted inventory of files, not a test plan.

Use the one line only when the title cannot carry the why on its own. When you use it, state the problem that existed before, in the words the user used when they reported it.

```
bad   Removed implicit workspace carryover from every new thread entry point;
      new threads now inherit only the project from context.
good  New threads on an existing worktree ignored the worktree default, so the
      preference silently did nothing.
```

No "generated with" trailers. No co-author lines. No model or harness attribution unless the user asks for it.

## Filing

- Open a real PR, never a draft. Drafts do not trigger the checks.
- Push the bookmark to tip and open the PR in one pass. Do not push commits sequentially and do not squash after pushing.
- Report the URL back to the user as the last thing you say.

## Screenshots

Anything with a visible surface gets an image or a recording in the PR. If you cannot attach one, say so explicitly instead of filing a UI change with no evidence.

## Stop here

Filing is done when the PR exists and the URL is reported. Do not merge, do not watch the checks, and do not start follow-up work unless the user asked to babysit.
