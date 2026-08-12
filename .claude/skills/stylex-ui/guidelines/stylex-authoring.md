# StyleX Authoring

Covers: `stylex.create`, style composition, conditional values, media queries, contextual
selectors, dynamic styles, and the token layer. Always in scope when writing StyleX.

Verified against StyleX 0.19.0.

## Token Layer

- Never hard-code a value that exists in [tokens/](../tokens/) — import it. `space[4]`, not `'1rem'`
- Token files must be named `*.stylex.ts` and may export nothing but variable definitions —
  no components, no helpers, no types. Every `defineVars`/`defineConsts` call must be a
  named export; default exports and re-exports are rejected by the compiler
- Use `defineConsts` for values that never change at runtime — palette ramps, spacing,
  radii, media query strings. They are inlined into the stylesheet at build time and cost
  zero CSS custom properties
- Use `defineVars` only for values that must change at runtime — a themeable brand color,
  a user-set density. Every `defineVars` entry becomes a real CSS variable, so a full
  palette defined this way is hundreds of live variables for no benefit
- `defineConsts` requires a real bundler pass (`@stylexjs/unplugin`, or the webpack/rollup/
  vite plugin). A bare single-file babel transform does not resolve consts across files and
  silently emits `var(--x…){…}` where an `@media` block belongs — invalid CSS that no error
  reports. If media queries vanish from the output, check the bundler wiring first

## Writing Styles

- One `stylex.create` call per module, named `styles`, defined at module top level —
  never inside a component body, where it would be recreated per render
- Inside `create`, StyleX allows only statically analyzable values. Not allowed:
  function calls (except StyleX's own), object spreads, and imports from anything other
  than a `.stylex.*` file. Template literals interpolating consts are fine and fold at build time
- Apply styles with `stylex.props(...)` spread onto the element:
  `<div {...stylex.props(styles.card, isActive && styles.active)} />`
- The last style applied always wins — across files, and across shorthand/longhand pairs
  (`padding` vs `paddingInline`). Order the arguments, don't reach for `!important`
- Conditional styles are objects keyed on the condition, nested inside the property value —
  never at the top of the namespace. A `default` key is required; use `null` when the
  default should apply nothing
- Pseudo-elements are the exception: they are top-level keys in the namespace (`'::placeholder'`),
  not property values
- Prefer a real element over `::before`/`::after` when one will do — StyleX's own guidance,
  and it keeps the CSS bundle smaller. Decorative glyphs and quote marks are the fair exception
- Use `stylex.firstThatWorks('sticky', '-webkit-sticky', 'fixed')` for fallback chains —
  the object syntax cannot express duplicate property declarations
- Prefer logical properties (`paddingInline`, `marginBlock`, `insetInlineStart`) over physical
  ones so RTL works for free. `@stylexjs/valid-shorthands` can enforce this with `preferInline`

```ts
import * as stylex from '@stylexjs/stylex';
import { zinc, base } from '../tokens/palette.stylex';
import { space, radius } from '../tokens/scale.stylex';
import { media } from '../tokens/media.stylex';

const styles = stylex.create({
  card: {
    padding: { default: space[4], [media.sm]: space[6] },
    borderRadius: radius.xl,
    backgroundColor: { default: base.white, [media.dark]: zinc[900] },
    color: { default: zinc[900], [media.dark]: zinc[100] },
  },
});
```

## Media Queries

- Import breakpoints from `tokens/media.stylex.ts` — never inline a raw
  `'@media (min-width: 40rem)'` string. One typo'd breakpoint that matches nothing is
  invisible in review and in the compiled CSS
- Mobile-first: the `default` value is the mobile value, and `media.sm` and up override it.
  This is the direct translation of Tailwind's unprefixed-then-`sm:` order
- `@container` queries compile correctly even though they are undocumented — verified on
  0.19.0. Set `containerType: 'inline-size'` on the wrapper and use
  `'@container (min-width: 24rem)'` as a condition key. Define shared container queries in
  `media.stylex.ts` alongside the breakpoints

## Contextual Styling (replaces `group-*` / `peer-*`)

- Use `stylex.when.*` to style an element from the state of another. Mark the observed
  element with `stylex.defaultMarker()`, or `stylex.defineMarker()` when a tree needs more
  than one independent group
- `when.ancestor(sel)` — parent state, the direct replacement for `group-hover:` and friends
- `when.descendant(sel)` — child state, replaces `has-*:`
- `when.anySibling(sel)`, `when.siblingBefore(sel)`, `when.siblingAfter(sel)` — replace `peer-*`
- All of them accept attribute selectors, so `[data-state="open"]` and `[aria-expanded="true"]`
  work without a pseudo-class workaround
- `descendant`, `anySibling`, and `siblingAfter` compile to `:has()`. Check the project's
  browser support before relying on them; `ancestor` and `siblingBefore` do not
- Specificity runs low to high: `ancestor` < `descendant` < `anySibling` < `siblingBefore` <
  `siblingAfter`. When two apply to the same property, the later one in that list wins

```ts
const styles = stylex.create({
  row: { backgroundColor: { default: base.white, [stylex.when.ancestor(':hover')]: zinc[50] } },
});

<li {...stylex.props(stylex.defaultMarker())}>
  <div {...stylex.props(styles.row)} />
</li>
```

## Dynamic Styles

- Use sparingly, and only for values genuinely unknown at build time — a drag offset, a
  progress width, a user-picked color. Everything else belongs in a static namespace
- Declare them as arrow functions taking plain identifiers, and call at the use site:
  `styles.bar(progress)`. StyleX emits a CSS variable and sets it inline
- Never branch between whole namespaces to fake a dynamic value when a conditional
  property value would do

```ts
const styles = stylex.create({
  bar: (width: string) => ({ width }),
});

<div {...stylex.props(styles.bar(`${pct}%`))} />
```

## Composition Across Components

- A component that accepts styles from its parent takes a `style` prop typed
  `StyleXStyles<>` and applies it last, so callers can always override
- Use `StyleXStylesWithout<{position: unknown}>` to lock properties a caller must not touch —
  this is how a layout primitive keeps its own positioning
- Never pass class name strings between components. Pass style objects and let `props` merge them

## Utilities Tailwind Gives You For Free

StyleX has no utility layer, so these need writing out. Put them in a shared `styles`
namespace rather than repeating them.

- `truncate` → `overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap'`
- `size-{n}` → `width` and `height` both set to `space[n]`
- `antialiased` → `WebkitFontSmoothing: 'antialiased', MozOsxFontSmoothing: 'grayscale'`
- `sr-only` → `position: 'absolute', width: '1px', height: '1px', padding: 0, margin: '-1px',
  overflow: 'hidden', clip: 'rect(0,0,0,0)', whiteSpace: 'nowrap', borderWidth: 0`
- `tabular-nums` → `fontVariantNumeric: 'tabular-nums'`
- `text-balance` / `text-pretty` → `textWrap: 'balance'` / `textWrap: 'pretty'`
- `h-lh` → `height: '1lh'`
- `isolate` → `isolation: 'isolate'`
- `ring-1 ring-{color}` → `boxShadow: '0 0 0 1px {color}'`, composed into one string when
  paired with an elevation shadow (see [Shadows](./shadows.md))
- `divide-y` → `borderTopWidth` on the children under `':not(:first-child)'`, which
  compiles correctly

## Opacity-Modified Colors

Tailwind's `/opacity` modifier has no StyleX equivalent. Use `color-mix`, which is exactly
what Tailwind v4 compiles to, in a template literal:

```ts
boxShadow: `0 0 0 1px color-mix(in oklab, ${zinc[950]} 5%, transparent)`,
```

StyleX folds this to a static hex at build time (`#09090b0d`), with a `lab()` fallback —
so it costs nothing at runtime. Never approximate one of these by eyeballing a lighter
ramp step; the composited result is not the same color.

## Use the Primitives

StyleX is not a syntax for writing CSS by hand. When a task matches a primitive, use it —
these are compile-checked, deduplicated, and scoped in ways a hand-written stylesheet is not.

| Need | Primitive | Rules |
|---|---|---|
| Keyframe animation | `stylex.keyframes` | [Animation](./animation.md) |
| Popover, dropdown, tooltip placement | CSS anchor positioning (**not** `stylex.positionTry`, broken at 0.19.0) | [Anchoring & Overlays](./anchoring.md) |
| Route or shared-element transition | `stylex.viewTransitionClass` | [View Transitions](./view-transitions.md) |
| Runtime theme or animatable token | `defineVars` + `stylex.types.*` + `createTheme` | [Theming](./theming.md) |
| Ancestor/sibling/descendant state | `stylex.when.*` + `defineMarker` | this file, above |
| Component style contract | `StyleXStyles<>` / `StyleXStylesWithout<>` | [Component API](./component-api.md) |
| One-off inline style | `@stylexjs/atoms` | [Atoms](./atoms.md) |
| Property fallback chain | `stylex.firstThatWorks` | this file, above |
| Non-React attribute output | `stylex.attrs` | [Component API](./component-api.md) |

`keyframes` and `positionTry` must be declared in the same file that uses them. Duplicates
across files dedupe in the generated CSS, so repeating a shared animation is fine — exporting
the compiled name from a shared module is not.

## Verify

- A clean build is the receipt. StyleX validates styles at compile time, so a build that
  succeeds means the property names and values are valid
- Read the emitted CSS after any change to the token layer or a media query — a const that
  failed to resolve produces broken output rather than an error
- Run `@stylexjs/eslint-plugin` (`valid-styles`, `valid-shorthands`, `sort-keys`, `no-unused`)
