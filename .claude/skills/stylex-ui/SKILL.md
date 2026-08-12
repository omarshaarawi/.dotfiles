---
name: stylex-ui
description: "Use when designing or building UI in a StyleX codebase — a page, screen, section, component, or layout — or when making StyleX UI look polished. Triggers: 'design a...', 'build a page for', 'style this', 'the UI is ugly' in any project using @stylexjs/stylex, and any task touching stylex.create, defineVars, defineConsts, or .stylex.ts files."
---

# StyleX UI

The ui.sh design guideline system, ported to StyleX. Same design bar, StyleX idioms,
and a token layer that mirrors Tailwind's scales so every numeric rule keeps its receipt.

## Activation

### Use For

- designing new UI, layouts, sections, components, or pages in a StyleX project
- implementing visually polished `stylex.create` styles
- setting up or extending a StyleX token layer (`.stylex.ts` files)
- porting a Tailwind UI to StyleX

### Do Not Use For

- Tailwind projects — use the `design` skill instead
- StyleX build/bundler configuration with no design component
- component extraction or code organization only

## Load First

- Read [StyleX UI Guidelines](./stylex-guidelines.md) before writing UI code.
- Read [StyleX Authoring](./guidelines/stylex-authoring.md) before writing any `stylex.create` call.
  It is the one file that is always in scope.
- Scan the rule-file index and load every guideline file that could apply.

## Workflow

1. Confirm the project's StyleX setup: version, bundler plugin, and whether a token layer exists.
   If none exists, scaffold from [tokens/](./tokens/) — see [tokens/README.md](./tokens/README.md).
2. Load [StyleX UI Guidelines](./stylex-guidelines.md) plus every applicable rule file.
3. Implement using the project's existing components, tokens, and conventions.
4. Build and check the emitted CSS, then check responsive breakpoints and interaction states.

## Progress Updates

One-line status update before each major phase. Concrete, not verbose.

## Rules

- Treat the guideline files here as the source of truth for StyleX UI work.
- Err on the side of loading too many applicable rule files rather than too few.
- Never hand-write a token value that exists in [tokens/](./tokens/). Import it.
- Preserve user constraints unless a guideline explicitly requires asking about a conflict.

## Verify

- Run the project's build and read the generated CSS — StyleX errors are compile-time,
  so a clean build is the receipt that styles are valid.
- Check desktop and mobile layouts, and dark mode if the project supports it.
- Run the project's lint (`@stylexjs/eslint-plugin`), typecheck, and tests when available.
