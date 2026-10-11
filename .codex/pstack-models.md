# pstack model configuration

These overrides use the Codex models exposed by the live T3 catalog at installation. Re-run setup-pstack when available models change. The model rows and default effort are also present in ~/.codex/AGENTS.md, because Codex does not support Claude's @ include syntax.

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
session hook: on

Use xhigh for genuinely hard architecture or debugging work. Do not use max or ultra. Cross-provider T3 routing is described in ~/.codex/AGENTS.md; native Codex model rows remain valid without T3.
