---
name: prompting-primitives
description: Design subsystems, APIs, config surfaces, and processes so AI agents can build on them without doing dumb shit ("primitives that enable prompting", dax/opencode v2). Use when designing or reviewing a new subsystem, plugin/extension API, config format, tool surface, keybinding/theme/registry system, event schema, or when writing specs/plans that agents will implement from. Trigger phrases: "make this agent-friendly", "primitive that enables prompting", "design this so an agent can extend it", "write a spec/plan for an agent", "why does the agent keep breaking this".
---

# Prompting Primitives

The insight (dax, opencode/opentui): invest heavily in a small number of deep subsystems, designed to handle every scenario, so an agent can use them without the human thinking hard. "It's harder for the agent to do dumb shit." No agent-specific mechanism needed. It's just engineering rigorous enough that the cheapest path is the correct one.

Extracted from the opencode v2 codebase (schema/protocol/core/tui/plugin/codemode layers plus its specs, plans, and agent tooling). Detailed per-primitive file anchors: `references/opencode-v2-primitives.md`. Copy-pasteable implementations of the process primitives (ast-grep lint setup, /learn, /rmslop, hypothesis ledger, plan template, spec conventions): `references/recipes.md`.

An agent takes the path of least resistance. A primitive enables prompting when the least-resistance path is the correct path, and the wrong paths either don't compile, throw at registration, or visibly fail a test.

## Part 1: Design rules for the primitive itself

### 1. Declare, don't wire

Every extension point is a fill-in-the-shape declaration, never an imperative wiring sequence. The runtime supplies the mechanism.

- opencode keybindings: consumers declare `{id, title, group, run}` in a layer. They never touch key events, never manage focus, never register/deregister listeners. Registration returns a disposer and auto-cleans on unmount.
- Tools: `Tool.make({description, input, output, execute})` is literally an identity function over a validated shape. No base class, no registry-owned executor.
- Events: `Event.durable({type, durable: {aggregate, version}, schema})` in one call.
- Config sections: one `Schema.Class` per concern, copy-the-pattern mechanical.

Test: can a new instance of the thing be added by writing one declarative object in one file? If adding it requires touching N places, agents will forget N-1 of them.

### 2. One canonical schema per concern, metadata co-located

The declaration carries everything derived surfaces need, so those surfaces are generated, never authored.

- Every opencode keybinding lives in ONE `Definitions` object, each entry holding its default key AND its help text. The command palette, which-key overlay, help dialog, and slash completion all render from the same command objects. There is no second place to forget.
- Tool schemas ARE the model-facing contract AND the validation boundary AND the docs.
- Config fields carry `.annotate({description})` which feeds a generated JSON Schema, so editors autocomplete and validate.

Test: if the agent adds a command/tool/config field, do help text, docs, completion, and validation update automatically? If any derived surface is hand-maintained, it will drift.

### 3. Closed vocabularies, illegal states unrepresentable

Enumerate every legal shape; let the type system or schema reject the rest.

- Theme tokens: hue names, 100-900 steps, action states are `Schema.Literals`. An agent cannot invent an off-palette color.
- Branded prefixed IDs (`ses_`, `msg_`, `evt_`) with `create()` attached to the schema. A raw string can't fill a `Session.ID` slot.
- Durable vs ephemeral events are distinct types (`durable?: never` on ephemeral), so envelope presence is compiler-checked.
- Result/error taxonomies are closed unions (codemode has exactly 9 diagnostic kinds), not stringly-typed errors.
- No ambiguous unions like `string | string[]` without a discriminant. Two ergonomic input forms are fine ONLY if they normalize to one canonical decoded shape at the boundary (opencode's model selection accepts `"provider/model"` string or a struct, but decodes both to the struct).

### 4. Fail fast on authoring mistakes, degrade gracefully on user/runtime error

Two different failure regimes, deliberately asymmetric:

- Authoring mistakes throw at registration: empty command ID, palette command without an ID, unknown config keys (hard error, not silently dropped), duplicate instruction keys, ambiguous codegen input (the generator throws rather than guesses).
- User/runtime problems degrade: bad theme falls back to default, malformed plugin becomes a no-op with a logged error, plugin failure can't prevent the app from starting, `set()` returns `false` instead of throwing.

The agent's mistakes surface immediately and loudly at the moment it writes the code. The user's mistakes never crash the product.

### 5. Defaults so the minimal declaration is complete

The smallest legal declaration should produce a fully working, discoverable feature. opencode: a named command auto-binds to its configured default key, description auto-fills from the registry, permission name defaults to the tool name, codemode exposure defaults to on. Every default is overridable, but the agent writing the 5-line version ships something correct.

### 6. Narrow, uniform verbs

Keep the extension vocabulary tiny so there's nothing to misremember:

- opencode's entire plugin API is two verbs: `transform` (replayable contribution to buildable state) and `hook` (live interceptor). Every domain uses the same two.
- One permission function: ordered `{action, resource, effect}` rules, last-match-wins, default ask, missing config fails closed (deny-all).
- One uniform return contract for keymap handlers: falsy = consumed, `false` = fall through. One rule everywhere.
- Registration always returns a disposer. Lifecycle is the same everywhere.

When you're about to add a third verb or a special case, that's the moment to redesign, and opencode writes the refusal down: "Do not add a second executable entry type, registry-owned executor, authorization callback, or output-path callback."

### 7. Durable state is minimal irreducible facts; everything derived is rebuildable

Event-source the state that matters. Record only irreducible new facts; projections, caches, and folds rebuild from the ordered log. Then an agent (or a crash, or a retry) cannot corrupt state, because derived state is disposable and replay is idempotent and byte-verified. Content-hash values (canonical sorted-key JSON) so identical values are identical bytes and diffs are cheap.

### 8. Default-deny by construction, not by sandbox

codemode's move: instead of sandboxing arbitrary JS, implement a small interpreter where capabilities that aren't implemented simply don't exist. No fetch, no timers, no fs, no ambient authority, nothing to escape. Generalize: prefer designs where the dangerous operation has no representation, over designs that represent it and then guard it.

## Part 2: The contract layer (single source of truth end to end)

For anything with a wire format or generated consumers:

1. **One schema value, many projections.** The same schema object (reference identity, not a copy) is the validation, the API contract, the OpenAPI docs, and the input to client codegen. opencode tests this with `expect(Client.Session).toBe(Session)`, no schema forks allowed.
2. **Errors are typed and status-annotated at the source.** `httpApiStatus: 404` on the error class drives the server response, the endpoint's declared error set, and the generated client's `declaredStatuses`. One annotation, three surfaces.
3. **Codegen refuses ambiguity.** Throw on multiple success schemas, unguessable transforms. Never emit a guess. Track emitted files in a manifest so regeneration GCs stale output.
4. **Drift is a CI failure, not a review hope.** `generate && git diff --exit-code` on committed generated code. Layering rules ("client never imports core/server") are enforced by a test that bundles each entrypoint and asserts on the real import graph.

## Part 3: Process primitives (the repo as a promptable surface)

The codebase-level counterparts. These make the REPO itself a primitive that enables prompting:

1. **Authority routing.** One table stating which artifact owns each kind of truth (wire shapes: schema package; runtime behavior: core; vocabulary: CONTEXT.md; regression guardrails: AGENTS.md). The agent never guesses where a change belongs.
2. **Controlled vocabulary.** Load-bearing terms are capitalized, defined once, and policed ("one Step is one logical LLM call; do not write 'provider turn'"). Ambiguous words in specs become ambiguous implementations.
3. **Specs with invariants as headings, non-goals inline, lifecycle tags.** Section titles are assertable laws ("Prompt Admission Precedes Execution"). Docs are tagged implemented / proposed / historical so agents don't build on obsolete prose.
4. **Plans that end in Verification Laws and Rejected Alternatives.** The single best template found: Decision, target architecture (ASCII diagram), numbered commit-sized stages each with a testable checkpoint, falsifiable "laws" that convert directly into tests, and a list of tempting-but-wrong approaches pre-emptively closed off ("Rejected First Implementations"). Hand an agent one stage and it knows exactly what done looks like.
5. **Negative constraints are load-bearing.** The most valuable AGENTS.md lines are prohibitions: "there is no instruction registry", "do not add a generic permission policy", "do not edit src/generated". Write down the wrong turns; agents are drawn to them.
6. **Deterministic feedback at every layer.** Record/replay cassettes for network (record once locally, replay hermetically, CI fails on missing cassettes, no overwrite mode so refreshes are reviewable). A scripted fake-LLM + headless-UI harness so agent behavior itself is testable ("script the model's exact output, assert on the rendered screen"). House style as machine-checked lint rules (ast-grep), with the lint rules themselves tested.
7. **Guardrails in tooling, not just prose.** If the rule is "don't run tests from root", make the root test script `exit 1` with a message. Prose rules get skimmed; failing commands get obeyed.
8. **Self-correcting context.** A `/learn`-style loop that writes non-obvious discoveries into the nearest-scope AGENTS.md (hidden relationships, execution paths that differ from appearance; NOT obvious facts). Plus an append-only hypothesis ledger for optimization work (Hypothesis | Before | After | Decision, with a Dead Ends table) so agents don't retry rejected approaches.

## Review checklist

When reviewing a design or subsystem against this skill, ask:

- [ ] Is adding an instance one declarative object in one file?
- [ ] Are all derived surfaces (docs, help, completion, clients) generated from that declaration?
- [ ] Is every enumerable thing a closed union? Any `string | string[]`-style ambiguity left?
- [ ] Do authoring mistakes throw immediately? Do user mistakes degrade gracefully?
- [ ] Does the minimal declaration ship complete and discoverable?
- [ ] Could the extension vocabulary be fewer verbs?
- [ ] Is derived state rebuildable from minimal durable facts?
- [ ] Are the forbidden wrong turns written down as negative constraints?
- [ ] Is there a deterministic feedback loop (test, lint, replay) that catches misuse of this primitive, so the agent finds out before the human does?
- [ ] Where does authority for this concern live, and is that written down?
