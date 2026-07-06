# CLAUDE.md

## Process

- **No breadcrumbs**. If you delete or move code, do not leave a comment in the old place. No "// moved to X". Just remove it.
- Fix things from first principles. Find the source, fix it there. No bandaids.
- **Search before pivoting**. If stuck, web search for official docs first. Do not change direction unless asked.
- Clean up dead code ruthlessly. Dead helpers, unused parameters, stale imports: delete them.
- If code is confusing, simplify it. Add an ASCII art diagram in a comment if it would help.
- **Don't inherit rot**. Match the surrounding code's style, but if a neighboring pattern is actually wrong, fix it or flag it. Agents copy whatever is already there, including the outdated stuff, so bad patterns propagate silently.
- Leave each repo better than you found it. If something smells, fix it.
- When taking on new work: think about architecture, research docs, review the existing codebase, compare, then implement or ask about tradeoffs.
- **AST-first where it helps**. Prefer `ast-grep` for tree-safe edits when it beats regex.
- Do not overly comment code. If its obvious, leave it out. If it's not, add a comment. Comments are for the reader, not the author.

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
- Only the primary agent manages jj workflow (describe/new/push). Subagents that hit the edit gate should return to parent.
- In non-jj repos, do not run `git` commands that write. Read-only only (`git show`, `git status`, `git diff`).
- Never revert or assume missing changes were yours.

## Tooling

- If a `justfile` exists, use `just` for build, test, and lint. Don't add one unless asked. Fall back to `Makefile` if present.
- TypeScript: use `just` targets; if none exist, confirm with the user before running `npm` or `pnpm` scripts.
- Python: use `just` targets; if absent, run `uv run` commands from `pyproject.toml`.
- Read `.github/workflows` to understand how CI runs tests. It should behave the same locally.
- For any file search or grep in the current git-indexed directory, use `fff` tools.
- If a command hangs past 5 minutes, stop it and check with the user.

## Picking the right models for workflows and subagents

Rankings, higher = better. Cost reflects value-per-limits on my plan, not list price. Intelligence is how hard a problem you can hand the model unsupervised. Taste covers UI/UX, code quality, API design, and copy.

| model    | cost | intelligence | taste |
|----------|------|--------------|-------|
| sonnet-5 | 5    | 5            | 7     |
| opus-4.8 | 4    | 7            | 8     |
| fable-5  | 2    | 9            | 9     |

How to apply:
- **These are defaults, not limits.** You have standing permission to override them: if a cheaper model's output doesn't meet the bar, rerun or redo the work with a smarter model without asking. Judge the output, not the price tag. Escalating costs less than shipping mediocre work.
- **Cost is a tie-breaker only.** When axes conflict for anything that ships, intelligence > taste > cost.
- **Bulk/mechanical work** (clear-spec implementation, data analysis, migrations): sonnet-5. A tight spec doesn't need Fable's intelligence, and Sonnet is the cheapest per unit of work.
- **Anything user-facing** (UI, copy, API design) needs taste ≥ 7: opus-4.8 or fable-5.
- **Hardest unsupervised problems** (ambiguous specs, gnarly debugging, architecture): fable-5.
- **Reviews of plans/implementations**: fable-5 or opus-4.8. For high-stakes work run both as independent perspectives; two lenses catch more than one.
- **Never use Haiku** for anything that ships.
- **Fable is token-hungry, so meter it.** Run Fable on `high` effort by default. Reserve `xhigh` for genuinely hard problems; skip `max`/`extra` (a furnace, and worse outputs than lower effort in practice).
- **Don't burn Fable context on grunt work.** Token-heavy chores (computer use, broad codebase analysis, log trawling) go to a cheaper model or a subagent that reports results back, not to Fable directly.
- **Mechanics**: Claude models run via the Agent/Workflow `model` parameter (`fable`, `opus`, `sonnet`, `haiku`), with `effort` set per the rules above.

## Testing

- No mocks. Unit tests or e2e tests, nothing in between.
- Test everything. Tests must be rigorous enough that a new contributor cannot silently break things.
- Run only the tests you added or modified unless asked otherwise.
- Test files live alongside the code they test (same package, `_test.go` suffix). Use table-driven tests where they make the code clearer.

## Language Guidance

### TypeScript

- Never use `any`.
- Never use `as`. Model the real shapes with proper types.
- Model states so the compiler rejects the illegal ones: discriminated unions with a tag, not booleans-and-optionals soup. Lean on the type system as a correctness tool, not just style. Run the typechecker after edits and treat its errors as the feedback loop.
- Assume modern browsers unless told otherwise, skip polyfills.

### Python

- We use `uv` and `pyproject.toml`. No `pip` venvs, Poetry, or `requirements.txt` unless asked.
- Type hints everywhere. Explicit models, not loose dicts or strings.

### KCL

- Assume you have access to the Zoo MCP server. If you don't, tell the user.
- Use the multi-view snapshot tool to verify the model looks right.
- Do not use the text-to-cad tool. Write code yourself.
- Write math into the model, don't use external tools to compute and inject raw values.
- Write parametric models that won't break when a parameter changes.
- Don't trust other KCL files on the host system. Look up KCL docs via web search instead.
- Build models incrementally: base shape, snapshot, verify, add feature, snapshot, verify. Step by step.

## Dependencies

- Before adding a dependency, web search for the most maintained, widely-used option. Confirm with the user before adding.

## Communication

- Dry, concise humor. If uncertain a joke will land, don't attempt it. No forced memes, no flattery.
- Skip em dashes. Use commas, parentheses, or periods.
- Cursing in code comments is allowed. Jokes in comments are fine if used sparingly.
- If I sound angry, it's at the code, not at you.

## Final Handoff

Before finishing a task:

1. Confirm all touched tests or commands were run and passed.
1. Summarize changes with file and line references.
1. Call out any TODOs, follow-up work, or uncertainties.
