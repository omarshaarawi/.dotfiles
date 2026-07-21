# opencode v2 primitive inventory (extracted 2026-07-21)

Source: github.com/anomalyco/opencode, branch `v2` (commit 9c38358). Clone it fresh if you need to verify anything; paths below are repo-relative. Layering rule (root AGENTS.md): Schema -> Core/Protocol -> Server; Client depends on Schema+Protocol only; sdk-next composes Client+Core+Server.

## Keymap system (dax's canonical example)

- `packages/tui/src/context/keymap.tsx`: Solid adapter over `@opentui/keymap`. `Keymap.createLayer(() => ({enabled, mode, target, priority, commands, bindings}))`. Throws at registration on: empty command ID, empty bind, palette/slash command without ID, inline command without bind. `createMode` = push/pop stack of mutually exclusive input modes. Pre-wired addons: `registerTimedLeader`, `registerManagedTextareaLayer` (forwards ~40 editing commands so a text input gets full readline behavior free).
- `packages/tui/src/config/v1/keybind.ts`: the `Definitions` object, ~150 entries, each `keybind("ctrl+x", "help text")`. Default key + description co-located. Key syntax: comma alternatives, `<leader>` token, `+` modifiers, `"none"`/`false` to disable. `parse()` hard-errors on unknown config keys, falls back per-key to defaults. `BindingValueSchema` = exhaustive union `false | "none" | string | KeyStroke | BindingItem[]`.
- `packages/plugin/src/v2/tui/context.ts:118-175`: public `KeymapCommand`/`KeymapLayer` interfaces (the consumer contract).
- `packages/tui/src/feature-plugins/system/which-key.tsx`: which-key overlay rendered purely from registered command metadata. Help is generated, never authored.
- `run()` return contract: falsy = consumed, `false` = fall through to next layer.

## Theming

- `packages/tui/src/theme/v2/schema.ts`: closed token vocabulary. `HueStep = Literals([100..900])`, `BaseHue`, `HueAlias = Literals(["accent","interactive","neutral"])`, `ActionState = Literals(["disabled","pressed","focused","selected","hovered"])`, hex regex-checked, `$hue.blue.500` template-literal refs.
- `packages/tui/src/context/theme.tsx`: one reactive store; bad themes fall back to `"opencode"`, `set()` returns `false` on unknown input. Discovery: drop JSON in `.opencode/themes/`, hot-reload via SIGUSR2.
- Migration pipeline: `v2/v1-migrate.ts`, `v2/resolve.ts`, `v2/fallback.ts` (incomplete/v1 themes still resolve).

## Plugin system

- `packages/plugin/src/v2/effect/`: `Plugin.define({id, effect})` receives a `Context` of domain capabilities. Exactly two registration verbs (`registration.ts`): `transform(cb)` (replayable contribution to buildable state; domains: agent, catalog, command, integration, reference, skill, tool) and `hook(name, cb)` (live interceptor, sequential, sees prior mutations). All registrations scope-owned, return `{dispose}`.
- Rebuild engine: `packages/core/src/state.ts` `State.create({initial, draft, finalize})`: base state -> replay transforms in deterministic order -> finalize -> commit -> publish. Boot batching, coalesced reloads, idempotent disposal.
- Plugins import `@opencode-ai/plugin`, never core. Builtins register through the same slot API as third-party plugins (`packages/tui/src/plugin/slots.tsx`, `feature-plugins/builtins.ts`). Malformed plugin = no-op disposer + logged `{plugin, slot, phase}`; spec invariant: "Plugin UI failures cannot prevent the base TUI from starting" (specs/tui-package.md).

## Tools

- Definition in `packages/plugin/src/v2/effect/tool.ts` (re-exported by core so plugins never import core). `Tool.make(config)` is identity over a shape: `{description, input, output, structured?, permission?, execute, toModelOutput?, toStructuredOutput?}`. `settle()` = single execution boundary: decode input, run, encode output (bad output = typed Failure, not crash). `definition()` derives model-facing JSON Schema from the same schemas. `DynamicDefinition` for MCP passthrough.
- Registry `packages/core/src/tool/registry.ts`: Location-scoped, `register(tools, {namespace, codemode})`, last-wins with shadowing restore on close. `codemode` defaults true. `materialize(permissions)` = visibility filter only; authorization happens at settlement.
- `packages/core/src/tool/AGENTS.md`: "Do not add a second executable entry type, registry-owned executor, authorization callback, or output-path callback." "Descriptions and schemas are model-visible contracts."

## Permissions

- `packages/core/src/permission.ts`: ordered `{action, resource, effect: allow|deny|ask}` rules, wildcard match, `findLast` (last match wins), default ask. Missing agent config -> `[{action:"*", resource:"*", effect:"deny"}]` (fails closed). Typed rejections: BlockedError, CorrectedError, DeclinedError. `"always"` reply persists a saved rule and re-evaluates all pending requests.

## Instructions algebra

- `packages/core/src/instructions/index.ts`: a `Source` = `{key, codec, read, render: {initial, changed, removed?}}` over canonical JSON. Operations: `make`, `combine` (rejects duplicate keys), `read` (value | unavailable | removed singletons), `diff` -> `Admission {delta, blobs}` (blocks initial sync if any source unavailable), `renderInitial`/`renderUpdate`, `hash` (sha256 of sorted-key canonical JSON).
- Storage: `session.instructions.updated` events store only changed keys + content hashes; blob values live once in `instruction_blob`; `instruction_state` is a rebuildable fold cache, never primary state (root AGENTS.md law).
- "There is no instruction registry": producers live with their domains, composed explicitly in the runner's `loadInstructions`.

## CodeMode

- `packages/codemode/`: pure interpreter for a JS subset whose only side-effect channel is host-provided tools. Default-deny by construction: no fetch/timers/fs/process/imports because they aren't implemented. `CodeMode.make({tools, limits})` -> `catalog()`, `instructions()` (token-budgeted), `execute(source)`. Closed Result union: ok {value, warnings, logs, truncated, toolCalls} or one Diagnostic from fixed taxonomy (ParseError, UnsupportedSyntax, UnknownTool, InvalidToolInput/Output, ToolCallLimitExceeded, TimeoutExceeded, ToolFailure, ExecutionFailure, Truncated). `OpenAPI.fromSpec` -> one tool per operation, unsupported ops reported in `skipped` rather than emitted broken. Public/private error split: `toolError("safe message")` with private cause. JSON-safe results, depth-limited.
- `packages/codemode/AGENTS.md`: "Do not add a speculative generic permission or approval policy. A host omits tools it does not expose."

## Contract layer / codegen

- `packages/schema`: every entity = Effect `Schema.Struct` with stable `identifier` annotation. Branded prefixed IDs via shared ULID-like generator (`identifier.ts`, ascending/descending): `ses_`, `msg_`, `evt_`, `frm_`, `sh_`, etc. `statics()` attaches `create()` to the schema. Branded scalars: AbsolutePath, RelativePath, Event.Seq, Event.Version, Money.USD.
- `packages/protocol/src/groups/*.ts`: `HttpApiEndpoint` = contract + validation + OpenAPI docs in one declaration. Errors: `Schema.TaggedErrorClass` with `httpApiStatus` annotation driving server status + declared error set + client declaredStatuses.
- Middleware: Protocol owns placement (abstract, parameterized), Server injects concrete keys (`server/src/api.ts` `makeDefaultApi({...})`), so Core identities never leak into the contract.
- `packages/httpapi-codegen/src/index.ts`: `compile(Api)` -> transport-neutral Contract; throws GenerationError on ambiguity (multiple success schemas, unguessable transforms, client-required middleware without adapter). `emitPromise` (zero-Effect fetch client) / `emitEffect*`. `write()` tracks emitted files in `.httpapi-codegen.json` for stale-file GC; rejects traversal/symlinks/dups.
- Client generates from `ClientApi` (Protocol projection with stub middleware, `protocol/src/client.ts`); a generation-equivalence test guards it against the server's real Api.
- Drift guards: `check:generated` = `generate && git diff --exit-code`; `client/test/import-boundaries.test.ts` bundles each entrypoint with `bun build --metafile` and asserts core/server absent from the real import graph; `contract-identity.test.ts` asserts `expect(Client.Session).toBe(Session)` (reference identity, no schema forks).

## Events

- `packages/schema/src/event.ts`: `Event.durable({type, durable: {aggregate, version}, schema})` / `Event.ephemeral({type, schema})`; ephemeral has `durable?: never` at the type level. Combinators: `inventory` (frozen ordered list), `latest` (highest version per type), `durableMap` (throws on dup), `versionedType(type, v)`.
- `packages/core/src/event.ts`: publish = one DB transaction (read latest seq, assign seq+1, run projectors, optional atomic `commit(seq)`, insert). Replay idempotent + byte-verified (re-insert of existing (id, seq) must be byte-equal or die). `log({aggregateID, after, follow})` emits a Synced watermark then goes live.
- `event-manifest.ts`: events classified current / shared transitional / V1-only; public `EventManifest.Server` is a curated subset of internal Definitions.
- Root AGENTS.md law: "Keep durable events minimal: record irreducible new facts and do not repeat state derivable by folding the ordered aggregate history."

## Config

- `packages/core/src/config.ts` + `src/config/*.ts`: one schema module per concern, self-export pattern (`export * as ConfigAgent from "./agent"` as first line). Every field `.annotate({description})` feeding a generated JSON Schema (`$schema` in user config files). `ConfigModel.Selection`: accepts `"provider/model#variant"` string or struct, `Schema.decodeTo`-normalizes to one canonical struct. `ConfigVariable.substitute`: declarative `{env:VAR}`/`{file:path}` interpolation with `missing: "error"|"empty"` policy.

## Service scoping

- `packages/util/src/effect/app-node.ts`, `layer-node.ts`: `makeGlobalNode`/`makeLocationNode` declare each service as `{service, layer, deps}` tagged global or location. Scope is a declared one-line fact per service. Session runner, model resolution, tool registry, permissions, filesystem = Location-scoped; storage, events = global.

## Process layer

- `specs/v2/README.md`: authority table (HTTP ops -> Protocol; domain shapes/durable payloads -> Schema; runtime behavior -> Core; vocabulary -> CONTEXT.md; regression guardrails -> AGENTS.md). Lifecycle tags on every doc: Accepted-and-implemented / Proposed-and-unimplemented / Historical. "Do not add implementation checklists here."
- `specs/v2/session.md`: invariants as section headings ("Prompt Admission Precedes Execution", "One Step Owns One Logical LLM Call"), non-goals inline. Vocabulary policed: Step, Turn (reserved), Drain, Safe Step Boundary, Physical Attempt, Location.
- `specs/tui-package.md`: layering as ASCII dependency graph + hard import prohibitions.
- `plans/session-generate.md`: THE plan template. Sections: Decision -> Why current shape resists it -> Target architecture (ASCII data flow) -> seam interfaces -> numbered Implementation Sequence (commit-sized stages, each with a testable checkpoint, including "this commit should NOT add X") -> Verification Laws (falsifiable, convert directly to tests) -> Rejected First Implementations (each named + why wrong) -> Expected Scope.
- `.opencode/`: the app configuring itself. `skills/effect/SKILL.md` ("use current effect-smol source, not memory"; pins exact test helpers). `command/learn.md` (extract non-obvious learnings into nearest AGENTS.md; strict include/exclude: hidden relationships and divergent execution paths yes, obvious facts no). `command/rmslop.md` (remove AI slop: extra comments, abnormal defensive try/catch, any-casts, emoji). `glossary/` (per-locale do-not-translate + preferred-terms tables). `opencode.jsonc` `references` map pointing at cloned source-of-truth repos.
- `packages/http-recorder`: cassette record/replay for Effect HTTP/WS. First local run records real traffic; later runs replay; `CI=true` fails on missing cassettes. No overwrite mode by design (deletion makes refreshes reviewable). Automatic secret redaction that fails the write on unsafe cassettes. Canonical JSON matching.
- `packages/simulation` + `.opencode/skills/opencode-drive`: simulated LLM provider + headless TUI renderer + semantic screen queries. `defineScript({setup, run})`: `ui.submit(...)`, `llm.send(llm.text(...))`, `ui.waitFor(...)`. Fully deterministic reproduce->fix->verify loop for agent+UI behavior with no real model.
- `script/ast-grep/`: house style as tested lint rules (no-star-import, no-import-alias, no-json-parse-cast, no-effect-die-string, no-nested-effect-service-yield, no-drizzle-column-name), wired to `lint:effect-patterns`; rules have their own `rule-tests/`.
- Root `package.json`: `"test": "echo 'do not run tests from root' && exit 1"` (guardrail in tooling, not prose). Typecheck speed itself instrumented (`typecheck:profile`).
- `perf/test-suite.md`: primary metric declared (`METRIC test_suite_seconds=<median>`), append-only Hypothesis table (Hypothesis | Change | Before | After | Decision | Notes) + Dead Ends table so rejected approaches aren't retried.
- `CONTRIBUTING.md`: issue-first policy, "No AI-Generated Walls of Text", vouch/denounce trust system targeting low-quality AI contributions.
