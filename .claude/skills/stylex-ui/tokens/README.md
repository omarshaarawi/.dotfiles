# Token Layer

Four `.stylex.ts` files that mirror Tailwind's default theme. They exist so every numeric
rule in the guidelines has a referent: when a rule says "use `px-3 py-2`, not `px-4 py-2`",
`space[3]` and `space[2]` are the same `0.75rem` and `0.5rem` Tailwind computes.

| File | Exports |
|---|---|
| `palette.stylex.ts` | 26 color ramps (`zinc`, `blue`, `neutral`, …) plus `base` (black, white, transparent, current) |
| `scale.stylex.ts` | `space`, `radius`, `text`, `leadingFor`, `fontWeight`, `tracking`, `leading`, `container`, `blur`, `ease`, `font` |
| `shadow.stylex.ts` | `shadow`, `insetShadow`, `dropShadow`, `textShadow` |
| `media.stylex.ts` | `media` (breakpoints, dark, motion, hover, pointer, forced-colors, print) and `mediaMax` |
| `theme.stylex.ts` | `brand` — the small `defineVars` group for runtime-themeable and animatable values |

## Installing

Copy the four files into the project's token directory (commonly `src/tokens/` or
`app/tokens/`) and import from there. They are plain StyleX — no dependency on this skill
at runtime.

Requires `@stylexjs/stylex` and a bundler plugin. `@stylexjs/unplugin` is the least-friction
option and works with vite, webpack, rollup, and esbuild.

```ts
import { zinc, base } from '@/tokens/palette.stylex';
import { space, radius, text, leadingFor } from '@/tokens/scale.stylex';
import { media } from '@/tokens/media.stylex';
```

## Why `defineConsts` and not `defineVars`

Both files use `defineConsts`, which inlines values into the stylesheet at build time.
`defineVars` would emit a live CSS custom property for each of the ~290 palette entries,
which is the memory pressure `defineConsts` was introduced to avoid.

The tradeoff is that consts cannot be swapped at runtime. That matches Tailwind, which has
no runtime theming either — dark mode is a media query, not a variable swap, and these
tokens follow the same model:

```ts
color: { default: zinc[900], [media.dark]: zinc[100] }   // text-zinc-900 dark:text-zinc-100
```

`theme.stylex.ts` is that exception, already scaffolded: four typed `defineVars` entries for
the values that genuinely need to change or animate at runtime. `stylex.types.*` gives each
one a real `@property` rule, which is what lets it interpolate — an untyped custom property
jumps at the end of a transition instead of easing. Add to it sparingly; leave the ramps as
consts and never convert the whole palette.

## Gotcha

`defineConsts` is resolved by a cross-file compiler pass. Under a bare single-file babel
transform the media query constants compile to `var(--x…){…}` — structurally invalid CSS
that raises no error. If `@media` blocks are missing from the output, the bundler plugin
is not wired up correctly.

## Regenerating

The values are generated from Tailwind's `packages/tailwindcss/theme.css`, not typed by
hand. `space` is precomputed from Tailwind's `--spacing: 0.25rem` base, so `space[3]` is
the product `calc(var(--spacing) * 3)` resolves to. To pick up a new Tailwind release,
re-derive from that file rather than editing these by hand.
