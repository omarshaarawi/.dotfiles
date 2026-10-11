# AGENTS.md

Global instructions for Codex. Kept in sync by hand with `~/.claude/CLAUDE.md`; the two differ
only in the harness-specific sections (models, tooling, skills).

## Process

- **No breadcrumbs**. If you delete or move code, do not leave a comment in the old place. No "// moved to X". Just remove it.
- Fix things from first principles. Find the source, fix it there. No bandaids.
- **Search before pivoting**. If stuck, web search for official docs first. Do not change direction unless asked.
- Clean up dead code ruthlessly. Dead helpers, unused parameters, stale imports: delete them.
- If code is confusing, simplify it. Add an ASCII art diagram in a comment if it would help.
- **Don't inherit rot**. Match the surrounding code's style, but if a neighboring pattern is actually wrong, fix it or flag it. Agents copy whatever is already there, including the outdated stuff, so bad patterns propagate silently.

## Design & Data Modeling

- **Don't ship the 2nd-best solution**. The first design that passes tests is usually the 2nd or 3rd best way to do it. Before committing to a shape, ask if there's a cleaner one and say why you picked this. "It works" is the floor, not the bar. If you settled to save time, say so instead of hiding it.
- **Definition of done**. Not done if the implementation is ugly. Not done if it's undocumented. Not done if a user can't discover it. Passing tests is where "done" starts, not where it ends.
- **The data model is the highest-leverage decision**. Avoid ambiguous unions like `string | string[]` that force every consumer to branch on the type. Pick one shape (normalize, or a discriminated union with a tag) so consumers don't each re-derive what they're holding. Make illegal states unrepresentable.
- **One-way doors vs two-way doors**. For things that are hard to change later (data models, public API and wire formats, DB schema), stop and think before writing code and surface the tradeoff first. "The LLM can fix it later" is not a reason to get it wrong now, the cost lands on every downstream consumer.
- **Precision over slop**. Don't accept a 20% margin of error because "AI can just figure it out". Get the details right, sloppiness compounds.

## Version Control

- If a `.jj/` directory exists, this is a **Jujutsu (jj)** repo. Load the `jj-vcs` skill before any VCS operation. Do not use raw git commands in jj repos, they desync state.
- jj workflow: `jj describe -m "intent"` to unlock edits, work, then session idle auto-commits via `jj new`. Every commit has a declared purpose.
- jj uses **bookmarks**, not branches. Move bookmark to tip and push once. Don't push commits sequentially or squash after pushing.
- In non-jj repos, do not run `git` commands that write. Read-only only (`git show`, `git status`, `git diff`).
- Never revert or assume missing changes were yours.

## Tooling

- If a `justfile` exists, use `just` for build, test, and lint. Don't add one unless asked. Fall back to `Makefile` if present.
- TypeScript: use `just` targets; if none exist, confirm with the user before running `npm` or `pnpm` scripts.
- Python: use `just` targets; if absent, run `uv run` commands from `pyproject.toml`.
- Read `.github/workflows` to understand how CI runs tests. It should behave the same locally.
- For file search or grep inside a git-indexed directory, prefer the `fff` MCP tools (frecency-ranked, git-aware) over bare `rg`. Fall back to `rg` outside git repos or if `fff` is unavailable.
- If a command hangs past 5 minutes, stop it and check with the user.

## Reasoning effort

Codex has one model per session, so effort is the only dial. Default is `gpt-5.6-terra` at `high`.

- Leave it at `high` for normal work.
- Raise to `xhigh` for genuinely hard problems (ambiguous specs, gnarly debugging, architecture decisions). Skip `max`/`ultra`; they burn tokens and are not reliably better.
- Drop to `medium` or `low` only for mechanical work against a tight spec (migrations, rote refactors, log trawling).
- Escalating effort costs less than shipping mediocre work. If output does not meet the bar, redo it at higher effort rather than patching around it.

## Testing

- No mocks. Unit tests or e2e tests, nothing in between.
- Test everything. Tests must be rigorous enough that a new contributor cannot silently break things.
- Run only the tests you added or modified unless asked otherwise.

## Language Guidance

### TypeScript

- Never use `any`.
- Never use `as`. Model the real shapes with proper types.
- Model states so the compiler rejects the illegal ones: discriminated unions with a tag, not booleans-and-optionals soup. Lean on the type system as a correctness tool, not just style. Run the typechecker after edits and treat its errors as the feedback loop.
- Assume modern browsers unless told otherwise, skip polyfills.

### Python

- We use `uv` and `pyproject.toml`. No `pip` venvs, Poetry, or `requirements.txt` unless asked.
- Type hints everywhere. Explicit models, not loose dicts or strings.

## Dependencies

- Before adding a dependency, web search for the most maintained, widely-used option. Confirm with the user before adding.

## Communication

- Dry, concise humor. If uncertain a joke will land, don't attempt it. No forced memes, no flattery.
- Skip em dashes. Use commas, parentheses, or periods.
- Cursing in code comments is allowed. Jokes in comments are fine if used sparingly.
- If I sound angry, it's at the code, not at you.

## pstack

The pstack plugin is installed globally. Use `pstack:poteto-mode` for multi-file work, public signature changes, architecture decisions, unknown-cause bugs, and performance work. It selects the appropriate playbook and supporting skills. Invoke a specific pstack skill directly when the request already names the workflow. Existing user and repository instructions take precedence, including jj, testing, communication permissions, and PR style. Installing pstack does not authorize unrelated external actions.

Native Codex role overrides follow. These override the Claude defaults in the shared skills and apply to delegated work, without changing the parent session's selected model. They mirror ~/.codex/pstack-models.md.

feature, refactoring: gpt-6.1-sol
bug-fix: gpt-6-astra
perf-issue: gpt-6-astra
hillclimb: gpt-6-astra
judgment and prose: gpt-6.1-sol
strongest judgment: gpt-6-astra
how explorer: gpt-6.1-sol
how explainer: gpt-6.1-sol
why investigators: gpt-6.1-sol
why synthesizer: gpt-6-astra
reflect tooling: gpt-6.1-sol
reflect judgment, divergent, synthesizer: gpt-6-astra
arena runners: gpt-6-astra, gpt-6.1-sol, gpt-6-sol
arena cross-judge pool: gpt-6-astra, gpt-6.1-sol, gpt-6-sol
swarm workers: gpt-6.1-sol
architect runners: gpt-6-astra, gpt-6.1-sol, gpt-6-sol
interrogate reviewers: gpt-6-astra, gpt-6.1-sol, gpt-6-sol

default effort: high

### T3 Code integration

When T3 orchestration tools are available, read orchestrator_capabilities before selecting models. The live provider catalog decides which model IDs and providers can run. For design and review panels, prefer independent supported Claude and Codex models when possible, rather than assuming native Codex can accept a Claude model ID. Use native subagent tools only when they support the selected model and provider; otherwise use delegate_task with the providerInstanceId and model ID from the catalog. Retain taskId for status and cancellation. Start a fresh delegate_task for each new review round, including the full brief and unresolved findings. Top-level thread launch tools create separate conversations and are not subagent substitutes.

Prefer T3 preview_* tools for browser verification and device_* tools for simulator or emulator verification. Use the exact agent-device launcher returned by device_open. Use watch_pull_request for PR monitoring when available, and register PRs with link_pull_request. Host instructions and repository rules take precedence over the generic Codex tool mapping bundled with pstack.
