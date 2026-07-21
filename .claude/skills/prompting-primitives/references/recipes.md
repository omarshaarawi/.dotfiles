# Portable recipes

Copy-pasteable implementations of the process primitives, lifted verbatim (or near-verbatim) from opencode v2. Adapt paths and rules per repo.

## 1. House style as tested lint rules (ast-grep)

Style rules agents must otherwise infer from prose become a deterministic pass/fail signal, and the rules themselves have tests so a bad rule can't silently stop matching.

Layout:

```
script/ast-grep/
  sgconfig.yml
  rules/no-star-import.yml
  rule-tests/no-star-import-test.yml
```

`sgconfig.yml`:

```yaml
ruleDirs:
  - rules
testConfigs:
  - testDir: rule-tests
```

Rules are ~10 lines each. Real examples:

```yaml
# rules/no-star-import.yml
id: no-star-import
language: TypeScript
message: Do not use star imports.
severity: error
rule:
  all:
    - kind: namespace_import
    - inside:
        kind: import_statement
        stopBy: end
```

```yaml
# rules/no-json-parse-cast.yml -- bans `JSON.parse(x) as T`
id: no-json-parse-cast
language: TypeScript
message: Prefer Effect Schema JSON decoding over JSON.parse casts.
severity: error
rule:
  pattern: JSON.parse($INPUT) as $TYPE
```

```yaml
# rules/no-nested-effect-service-yield.yml -- constraint regex scopes it to services
id: no-nested-effect-service-yield
language: TypeScript
message: Bind Effect services before calling methods instead of nesting service yields.
severity: error
rule:
  any:
    - pattern: (yield* $SERVICE).$METHOD($$$ARGS)
    - pattern: (yield* $SERVICE).$PROPERTY.$METHOD($$$ARGS)
constraints:
  SERVICE:
    regex: \.Service$
```

Rule tests are valid/invalid example lists; snapshots live in `rule-tests/__snapshots__`:

```yaml
# rule-tests/no-star-import-test.yml
id: no-star-import
valid:
  - import { Foo } from "./foo"
  - export * as Foo from "./foo"
invalid:
  - import * as Foo from "./foo"
  - import type * as Foo from "./foo"
```

Wiring (root `package.json`):

```json
"lint:effect-patterns": "ast-grep scan -c script/ast-grep/sgconfig.yml packages/core/src packages/server/src",
"test:lint-rules": "ast-grep test -c script/ast-grep/sgconfig.yml"
```

Pattern: whenever a style rule appears twice in review feedback or an AGENTS.md, promote it to an ast-grep rule. Prose gets skimmed; `severity: error` gets obeyed.

## 2. Guardrails in tooling, not prose

Root `package.json` in a monorepo where tests must run per-package:

```json
"test": "echo 'do not run tests from root' && exit 1"
```

The grep-able guard string (`do-not-run-tests-from-root`) makes the failure searchable when an agent hits it.

## 3. The /learn command (self-correcting context)

Verbatim from `.opencode/command/learn.md`. Port to Claude Code as a skill or slash command; swap AGENTS.md for CLAUDE.md scoping as needed.

```markdown
Analyze this session and extract non-obvious learnings to add to AGENTS.md files.

AGENTS.md files can exist at any directory level. Place learnings as close to
the relevant code as possible:
- Project-wide learnings -> root AGENTS.md
- Package/module-specific -> packages/foo/AGENTS.md
- Feature-specific -> src/auth/AGENTS.md

What counts as a learning (non-obvious discoveries only):
- Hidden relationships between files or modules
- Execution paths that differ from how code appears
- Non-obvious configuration, env vars, or flags
- Debugging breakthroughs when error messages were misleading
- API/tool quirks and workarounds
- Build/test commands not in README
- Architectural decisions and constraints
- Files that must change together

What NOT to include:
- Obvious facts from documentation
- Standard language/framework behavior
- Things already in an AGENTS.md
- Verbose explanations
- Session-specific details

Process:
1. Review session for discoveries, errors that took multiple attempts, unexpected connections
2. Determine scope: what directory does each learning apply to?
3. Read existing AGENTS.md files at relevant levels
4. Create or update AGENTS.md at the appropriate level
5. Keep entries to 1-3 lines per insight
```

## 4. The /rmslop command (de-slopping pass)

Verbatim from `.opencode/command/rmslop.md`:

```markdown
Check the diff against dev, and remove all AI generated slop introduced in this branch.

This includes:
- Extra comments that a human wouldn't add or is inconsistent with the rest of the file
- Extra defensive checks or try/catch blocks that are abnormal for that area of the
  codebase (especially if called by trusted / validated codepaths)
- Casts to any to get around type issues
- Any other style that is inconsistent with the file
- Unnecessary emoji usage

Report at the end with only a 1-3 sentence summary of what you changed
```

## 5. Hypothesis ledger (for optimization work)

Structure of `perf/test-suite.md`. One doc per optimization campaign, checked in, append-only:

```markdown
# <Campaign name>

## Goal
<one sentence, including what must NOT regress>

## Benchmark Command
<exact commands, run from where, with scoping env vars for exploration>

## Primary Metric
`METRIC test_suite_seconds=<median wall clock seconds>`

## Hypotheses
| Hypothesis | Change | Before | After | Decision | Notes |
|---|---|---|---|---|---|

## Dead Ends
| Hypothesis | Change | Result | Decision | Notes |
|---|---|---|---|---|
```

Rules: every experiment lands as a row (keep or discard); discarded approaches go to Dead Ends so no future agent retries them; the metric line format is machine-greppable.

## 6. Plan template (Verification Laws + Rejected Alternatives)

Skeleton of `plans/session-generate.md`, the strongest agent-runbook format found:

```markdown
# <Feature>

Status: In progress | Done | Abandoned

## Decision
<what we are building, one paragraph>

## Why The Current Shape Resists It
<the friction that makes this non-trivial>

## Target Architecture
<ASCII data-flow diagram + the seam interfaces>

## Implementation Sequence
<numbered commit-sized stages; each ends with a testable checkpoint;
 include negative scope per stage: "This commit should not add X">

## Verification Laws
<numbered, falsifiable statements that convert directly into tests, e.g.
 "1. Request equivalence: ..." "4. Single attempt: one call produces exactly
 one llm.generate invocation" "8. Empty success: a provider response with no
 assistant text returns ''">

## Rejected First Implementations
<each tempting-but-wrong approach, named, with why it fails, e.g.
 "### Prompt, Wait, And Read -- mutates Session History, enters the agent loop">

## Expected Scope
<files/packages touched, size estimate>
```

## 7. Spec conventions

- Authority table in the spec index: one row per concern, naming the artifact that owns that truth. Specs explain what is "difficult to recover from one source file"; they are not API reference and not a backlog.
- Section headings are assertable invariants ("Prompt Admission Precedes Execution"), so a diff can be checked against the heading list.
- Lifecycle tag at the top of every doc: Accepted-and-implemented / Proposed-and-unimplemented / Historical Context.
- Non-goals stated inline ("Hard-crash recovery ... remains out of scope").
- Load-bearing vocabulary is Capitalized and defined once; wrong usages are policed in review ("do not write 'provider turn'").
