# pstack model configuration

Use these role overrides with the pstack plugin. Native Claude Code model families come from the existing model guidance in CLAUDE.md. Runtime tool and model availability takes precedence over a name in this sheet.

feature, refactoring: opus
bug-fix: fable
perf-issue: fable
hillclimb: fable
judgment and prose: opus
strongest judgment: fable
how explorer: sonnet
how explainer: opus
why investigators: sonnet
why synthesizer: opus
reflect tooling: sonnet
reflect judgment, divergent, synthesizer: opus
arena runners: opus, fable, sonnet
arena cross-judge pool: opus, fable, sonnet
swarm workers: sonnet
architect runners: opus, fable, sonnet
interrogate reviewers: opus, fable, sonnet

default effort: high
session hook: on

Use xhigh for genuinely hard architecture or debugging work. Do not use max. Keep Haiku out of work that ships.

## T3 Code

When T3 orchestration tools are available, read orchestrator_capabilities before selecting models. The live provider catalog decides which model IDs and providers can run. Native Claude family aliases such as fable may not be exposed in T3. Choose the strongest available Claude model for an unavailable strongest-judgment alias and report the substitution. Use supported Claude and Codex models for cross-provider design and review panels when possible.

Use native subagent tools only when they support the selected model and provider. Otherwise use delegate_task with the providerInstanceId and model ID from the catalog. Keep the returned taskId for status and cancellation. Start a fresh delegate_task for each new review round, including the full brief and unresolved findings. Top-level thread launch tools create separate conversations and are not subagent substitutes.

Prefer T3 preview_* tools for browser verification and device_* tools for simulator or emulator verification. Use the exact agent-device launcher returned by device_open. Use watch_pull_request for PR monitoring when available, and register PRs with link_pull_request. Host instructions and the user's repository rules take precedence over pstack tool recipes.
