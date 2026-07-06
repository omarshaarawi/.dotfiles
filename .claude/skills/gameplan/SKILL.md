---
name: gameplan
description: "Write a TDD-first gameplan for a Jira ticket (typically PENG-XXXX, Pactima/Snapdocs). Use when the user asks to gameplan, plan, scope, write up, or investigate a ticket — or pastes a Jira issue URL. Fetches the ticket, traces the bug in code, checks Loom recordings, cross-refs the Obsidian vault, then writes a structured doc to the snapdocs vault. Trigger phrases: 'gameplan PENG-...', 'plan this ticket', 'write up <ticket>', 'investigate <ticket>', 'help me think through <ticket>'."
---

# gameplan — TDD-first ticket investigation and writeup

This skill produces ticket gameplan docs in **Omar's house style** — the format used across `~/Library/CloudStorage/GoogleDrive-omar.shaarawi@snapdocs.com/My Drive/snapdocs/tickets/`. The pattern is **understanding before solutioning**, with a failing test written **before** picking among fix options.

The skill does *not* implement the fix. It produces the doc, the failing-test contract, and a clear list of fix options. Implementation is a separate session.

---

## When to use

- User asks: "gameplan PENG-XXXX," "plan this ticket," "write up <ticket>," "scope <ticket>," "help me think through <ticket>"
- User pastes a Jira issue URL (`snapdocs-eng.atlassian.net/browse/PENG-...`)
- User asks for a "TDD plan" or "test-first plan" for a ticket

If the user just asks a question *about* the code, that's not gameplan — answer directly.

---

## Inputs

- A ticket key (`PENG-2587`), a Jira URL, or a one-line description.
- Optionally, a Loom URL or a path to an extracted Loom (`~/git/loom-extractor/out/loom-<id>/`).
- Optionally, the answer to "is the API the bug, or the FE?" — but usually you have to figure this out.

---

## Workflow

### Phase 1 — Fetch the ticket

Use the Atlassian MCP server. The cloudId is `snapdocs-eng.atlassian.net`.

```
mcp__atlassian__getJiraIssue with
  cloudId = "snapdocs-eng.atlassian.net"
  issueIdOrKey = "PENG-XXXX"
  responseContentFormat = "markdown"
```

Pull: summary, description, priority, status, sprint, reporter, assignee, comments, related links.

**If the ticket description is sparse** (just a Loom or one line), don't bail — Pactima tickets are often this short. Move to Phase 2.

### Phase 2 — Loom recording

If the description has a Loom URL, check for a local extract first:

```
ls ~/git/loom-extractor/out/loom-<first-12-chars-of-id>/
```

If `summary.md` and `timeline.md` exist, read them. They give frame-by-frame OCR — usually enough to identify the failing UI surface and the exact error message. Quote the exact error text from the recording in the doc.

If the extract is missing, tell the user and offer to invoke the `loom-extract` skill. Don't try to watch the video directly.

### Phase 3 — Trace the bug

Pactima monorepo lives at `~/git/pactima/{pactima-api, pactima-web-app, pactima-angular-internal}`.

Standard trace order, depending on the surface:

1. **Error string from Loom** → `grep -rn "<error string>" ~/git/pactima/pactima-api/src/assets/errors-catalog/errors-list.ts` to map to its error code, then grep the codebase for `<error code>` to find the throw site.
2. **Controller** → check the relevant controller (e.g. `eSignaturePackagesCcRecipients.controller.ts`) for status guards, validation, write paths.
3. **Route** → `pactima-api/src/routes/...` for any middleware (`ScopeAuthorizer`, status middleware) you might have missed.
4. **Model** → `pactima-api/src/models/...` for pre-save hooks and schema-level validation.
5. **Utils / shared** → `pactima-api/src/utils/eSignatureUtils.ts` is the access-gate hub.
6. **Front-end** → `pactima-web-app/src/app/...`. Especially: components/services that call the failing API, plus *sister components* doing the same job correctly (often the bug is in one caller, not in the shared component).
7. **Tests** → look for adjacent specs. `pactima-api/spec/` and `pactima-web-app/src/**/*.spec.ts`.

**Look for sister implementations.** When the FE has a bug, there is often a sibling component that solves the same problem correctly (e.g. `signing-station-side-bar-live.editSigner` vs `e-signatures-details.handleChangeSignerInfo`). Citing the working sibling shapes the fix.

**Distinguish error codes.** Pactima has many four-digit error codes that look similar (`E_SIGNATURE_SIGNERS.0002` vs `E_SIGNATURE_PACKAGES.0012` vs `E_SIGNATURE_CC_RECIPIENTS.0006`). Quote the exact code in the doc and don't conflate them.

### Phase 4 — Cross-ref the vault

Use `mcp__qmd__query` against the `obsidian` collection. Useful queries:

- The status enum / glossary: `[[17 - Glossary]]`, `[[04 - Database & Models]]`
- Workflow / state machines: `[[18a - Participant Pools State Transition Matrix]]`, `[[09 - Business Logic & Domain Rules]]`
- Adjacent tickets: search by feature area
- Real-time / WS: `[[18h - PENG-2443 Real-Time Pool Updates Testing Guide]]`

Cite each as `[[Title]] — one-line hook`. Don't list cross-refs that aren't actually used in the doc.

### Phase 5 — Reframe the ticket

This is the most distinctive part of the house style. **Read the ticket text adversarially.** The reporter's framing is often loose. Examples:

- "Notaries get the email" might mean "schedule-setter participants get the email" — different code path.
- "Allow updating X when in SCHEDULED status" might mean "the API already allows it, but the UI routes through the wrong endpoint" — no API status-guard relaxation needed.
- "Sometimes works, sometimes doesn't" might mean "an iframe parent papers over the bug when a separate condition fires."

If your reading differs from the literal title, **say so explicitly** in the **Acceptance criteria (as I read it)** section. Phrase it as your interpretation, not as a correction. Then preserve the original framing for grep-ability.

### Phase 6 — Write the doc

Save to `~/Library/CloudStorage/GoogleDrive-omar.shaarawi@snapdocs.com/My Drive/snapdocs/tickets/PENG-XXXX.md`.

**Filename rule:**
- Single-symptom bug: `PENG-XXXX.md`
- Multi-component or multi-feature: `PENG-XXXX <Short Title>.md`
- Use the existing folder for inspiration on naming.

**Don't:** write to `~/git/pactima/`. That's the code repo, not the notes vault.

---

## Doc skeleton (in this exact order)

```markdown
# PENG-XXXX — <one-line restatement of the actual problem, not the Jira title>

**Type:** <Bug|Task|Story> · **Priority:** <P1|P2> · **Sprint:** <N> (ends YYYY-MM-DD) · **Status:** <In Progress>
**Reporter:** <name> · **Assignee:** <name>
**Jira:** https://snapdocs-eng.atlassian.net/browse/PENG-XXXX
**Repo(s):** <pactima-api, pactima-web-app, ...>
**Bookmark:** feature/PENG-XXXX-<short-slug>
**Loom:** <url> (extracted: <local path>)  [if applicable]
**Related:** [[adjacent ticket/note]]  [if applicable]

## The problem

Prose. Concrete user-visible behavior. Quote exact error strings. If the ticket framing is loose, paragraph that re-frames it against the wiring. Distinguish symptoms if there are multiple.

## Acceptance criteria (as I read it)

Numbered list. The phrase "as I read it" is load-bearing — it flags ambiguity in the original AC and forces alignment.

## Where the bug lives

File:line:function with code snippets. Always before any fix strategy.
Subsections per symptom if there are multiple.
Cite sister implementations that get it right.

## Why this looks like a <X> problem  [optional, only if reframing]

For tickets where the reporter's framing diverges from the actual defect — explain why the framing is plausible, then where it actually breaks.

## Root cause (summary)

Short, conceptual. Names the underlying error, not the symptom. Often one paragraph.

## Domain context  [optional, longer for new areas]

Tables, ASCII workflow diagrams, "X vs Y" disambiguation. Distinguish similar terms (e.g., `participant-notifier` vs `enrollee-finder`).

## Fix strategy

Options A / B / C with explicit pros and cons. Recommend one. If you've shipped already, add an "As shipped — Option D" with the pivot reason.

## Test plan (TDD)

**The contract.** One sentence. The observable fact (not implementation choice) that the fix must produce.

**Why this contract.** Explain why the chosen assertion holds across all listed fix options. The lowest-common-denominator that survives A/B/C.

**File path** for the new test (use a `peng-XXXX` suffix, e.g. `eSignaturePackagesActions.finishSession.peng-2566.controller.test.ts`).

**Sections:** Setup → Mocks → Act → Assert. The assert that fails today is called out separately from sanity asserts that should still pass.

**Mock at the IO seam, run the real code.** sendHTMLEmail, S3, sendSocketEvent are spies; everything else (Mongo via MongoMemoryServer, the workflow walker, model methods) runs for real.

**Out of scope** — explicit, with follow-up filing intent.

## Interpretation choices

Numbered. Each: *Chose X. Rejected Y because Z.* Locks in every soft spot in the AC.

## Open questions

For reporter / sprint review. Never blockers. *"All answers are compatible with what shipped."*

## Files to change  [if pre-implementation]

Per repo, file-by-file, what will be done. Use this section name when planning.

## Files changed (as-built)  [if post-implementation]

Per repo. Plus the regression sweep command and result count (`44/44 green`).

## Vault context (qmd cross-refs)

`[[Title]]` — one-line "what this note told me." Skip if no real cross-refs.

## Related code (for reference)

Bullet list of file:line pointers for reviewers. Easy navigation.
```

---

## TDD discipline (the distinctive part)

**Write the test before picking the fix option.** The test goes against a contract that survives across all candidate fix shapes. Recipe:

1. State the **contract** in one sentence — an observable fact, not an implementation choice.
2. List the **fix options** and explain why the chosen assertion holds across all of them. Pick the lowest-common-denominator.
3. Give the test file path up front. Naming convention: include the ticket key (`peng-XXXX`) in the filename so it's grep-able.
4. **Setup → Mocks → Act → Assert**. The asserting-the-bug assertion is called out *separately* from the sanity asserts (which should still pass on `main`).
5. **Mock at the IO seam, run the real code.** Real `MongoMemoryServer`, real workflow code, real model methods. Spies only on `sendHTMLEmail`, S3, socket emits, etc.
6. **Two-layer split** when useful: filter-level unit + handler-level e2e. PENG-2559 (13 unit + 7 e2e) is the canonical example.
7. **Out of scope** — list it with explicit follow-up intent.

---

## What NOT to do

- **Don't implement the fix.** This skill produces the gameplan and the failing-test design. Implementation is a separate, opt-in step.
- **Don't conflate similar error codes.** Look up each one in `errors-list.ts` and quote it precisely.
- **Don't skip the reframe.** If your reading differs from the ticket title, that's the most important thing to surface.
- **Don't write to the pactima repo.** Outputs go to the snapdocs vault.
- **Don't invent vault cross-refs.** Use qmd to find real ones; if there aren't any, skip the section.
- **Don't add a fix-option pivot ("As shipped — Option D") at planning time.** That section only appears post-implementation when you actually pivoted away from the planned option.
- **Don't write a test plan that only works for Option A.** If your assertion only survives one option, you've over-fitted. Generalize.

---

## When the ticket doesn't reproduce

Some tickets resolve into "cannot reproduce" after investigation (PENG-2559 is the canonical case). The doc still ships, but the shape changes:

- Open with a **TL;DR** that states the conclusion ("cannot reproduce; here is what likely happened").
- Run the reporter's exact configurations as e2e tests anyway — the test file becomes the reproduction harness.
- Surface the **real edge cases** that match what the reporter probably hit (e.g., owner-as-signer trap).
- File adjacent issues as follow-up tickets, not in this PR.
- Recommend closing as Cannot Reproduce with the closure note including the edge cases.

---

## Pactima environment cheatsheet

- **Repos:** `~/git/pactima/{pactima-api, pactima-web-app, pactima-angular-internal}`
- **Notes vault:** `~/Library/CloudStorage/GoogleDrive-omar.shaarawi@snapdocs.com/My Drive/snapdocs/`
- **Tickets folder:** `<vault>/tickets/`
- **Loom extracts:** `~/git/loom-extractor/out/loom-<first-12-chars>/`
- **Atlassian cloudId:** `snapdocs-eng.atlassian.net`
- **Test runners:** `vitest` for both API and web-app
- **API DB-backed tests:** `MongoMemoryServer` (no mocks of model methods)
- **VCS:** `jj` (load `jujutsu` skill before any VCS write); pactima is a `jj` repo

---

## Reference docs (canonical examples in the vault)

When in doubt about tone, structure, or tradeoff explanation, read these existing tickets:

- `PENG-2566 On-demand Pool Cosigner Email Timing.md` — gold-standard for fix-option enumeration + TDD contract that survives across A/B/C.
- `PENG-2538 Disable Signer Notifications for Pools.md` — gold-standard for "discovered during implementation, separate follow-up" pattern.
- `PENG-2559.md` — canonical "cannot reproduce, here's what really happened" doc.
- `PENG-2532 Data Residency on User Joining.md` — heavy interpretation-choices section.
- `PENG-2522.md` — short ticket, minimal fix; not every doc needs to be 200 lines.
