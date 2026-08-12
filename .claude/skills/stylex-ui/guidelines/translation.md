# Tailwind to StyleX Translation

Reference module. Load when porting Tailwind markup to StyleX, or when a rule in another
guideline file cites a Tailwind class you need to express.

The token layer mirrors Tailwind's scales exactly, so most classes translate by lookup
rather than by judgement. `p-3` is `padding: space[3]` because `space[3]` holds the same
`0.75rem` Tailwind computes for it.

## Scales

| Tailwind | StyleX |
|---|---|
| `p-3` | `padding: space[3]` |
| `px-3 py-2` | `paddingInline: space[3], paddingBlock: space[2]` |
| `p-1.5` | `padding: space[1.5]` |
| `gap-x-6` | `columnGap: space[6]` |
| `size-4` | `width: space[4], height: space[4]` |
| `rounded-xl` | `borderRadius: radius.xl` |
| `rounded-full` | `borderRadius: radius.full` |
| `text-sm` | `fontSize: text.sm, lineHeight: leadingFor.sm` |
| `text-sm/6` | `fontSize: text.sm, lineHeight: space[6]` |
| `font-semibold` | `fontWeight: fontWeight.semibold` |
| `tracking-tight` | `letterSpacing: tracking.tight` |
| `max-w-xs` | `maxWidth: container.xs` |
| `shadow-sm` | `boxShadow: shadow.sm` |
| `bg-zinc-900` | `backgroundColor: zinc[900]` |
| `text-white` | `color: base.white` |

Always set `fontSize` and `lineHeight` together. Tailwind's `text-sm` carries a paired
line height; `text.sm` alone silently inherits whatever the parent had.

## Variants

| Tailwind | StyleX |
|---|---|
| `sm:p-6` | `padding: { default: …, [media.sm]: space[6] }` |
| `dark:bg-zinc-900` | `backgroundColor: { default: …, [media.dark]: zinc[900] }` |
| `hover:bg-blue-700` | `backgroundColor: { default: …, ':hover': blue[700] }` |
| `focus-visible:outline-2` | `outlineWidth: { default: …, ':focus-visible': '2px' }` |
| `disabled:opacity-50` | `opacity: { default: 1, ':disabled': 0.5 }` |
| `group-hover:opacity-100` | `opacity: { default: …, [stylex.when.ancestor(':hover')]: 1 }` |
| `peer-checked:*` | `{ [stylex.when.siblingBefore(':checked')]: … }` |
| `has-checked:*` | `{ [stylex.when.descendant(':checked')]: … }` |
| `forced-colors:*` | `{ [media.forcedColors]: … }` |
| `motion-reduce:*` | `{ [media.motionReduce]: … }` |
| `[&:nth-child(2n)]:border-l` | `borderInlineStartWidth: { default: 0, ':nth-child(2n)': '1px' }` |

Contextual variants need `stylex.defaultMarker()` on the observed element. See
[StyleX Authoring](./stylex-authoring.md).

## Utilities With No Direct Equivalent

| Tailwind | StyleX |
|---|---|
| `truncate` | `overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap'` |
| `sr-only` | see the block in [StyleX Authoring](./stylex-authoring.md) |
| `antialiased` | `WebkitFontSmoothing: 'antialiased', MozOsxFontSmoothing: 'grayscale'` |
| `tabular-nums` | `fontVariantNumeric: 'tabular-nums'` |
| `text-balance` | `textWrap: 'balance'` |
| `text-pretty` | `textWrap: 'pretty'` |
| `h-lh` | `height: '1lh'` |
| `isolate` | `isolation: 'isolate'` |
| `shrink-0` | `flexShrink: 0` |
| `min-w-0` | `minWidth: 0` |
| `whitespace-nowrap` | `whiteSpace: 'nowrap'` |
| `appearance-none` | `appearance: 'none'` |
| `pointer-events-none` | `pointerEvents: 'none'` |
| `@container` | `containerType: 'inline-size'` on the wrapper |

## Rings, Outlines, and Opacity

Tailwind's `ring-*` is a box shadow. Its `/opacity` modifier is a `color-mix`.

| Tailwind | StyleX |
|---|---|
| `ring-1 ring-black/5` | `boxShadow: \`0 0 0 1px color-mix(in oklab, ${base.black} 5%, transparent)\`` |
| `inset-ring-1 inset-ring-white/10` | `boxShadow: \`inset 0 0 0 1px color-mix(in oklab, ${base.white} 10%, transparent)\`` |
| `shadow-sm ring-1 ring-black/5` | one composed string: `` `${shadow.sm}, 0 0 0 1px color-mix(in oklab, ${base.black} 5%, transparent)` `` |
| `outline-1 -outline-offset-1 outline-black/5` | `outlineWidth: '1px', outlineOffset: '-1px', outlineColor: \`color-mix(in oklab, ${base.black} 5%, transparent)\`` |
| `bg-zinc-950/5` | `` backgroundColor: `color-mix(in oklab, ${zinc[950]} 5%, transparent)` `` |

A ring and a shadow both compile to `box-shadow`, so they must be one string. Two separate
`boxShadow` declarations means the second silently erases the first.

## Structural Patterns

- `space-y-*` and `divide-*` have no equivalent. Use `gap` on the parent for spacing, and
  `':not(:first-child)'` borders on the children for dividers
- Tailwind's arbitrary values (`w-[13px]`) become plain values. Keep `rem` for anything
  type- or spacing-related; `px` is fine for borders and outlines
- `!important` has no place in StyleX. Ordering the arguments to `props` decides the winner

## No Tailwind Equivalent

These have no class to translate from. They are the reason a StyleX codebase can do things a
Tailwind one cannot, and they are easy to miss when porting rule-for-rule.

| Capability | StyleX | Rules |
|---|---|---|
| Anchor-positioned overlays with fallbacks | `anchorName` / `positionArea` / `positionTryFallbacks` | [Anchoring & Overlays](./anchoring.md) |
| Scoped view transition styling | `stylex.viewTransitionClass` | [View Transitions](./view-transitions.md) |
| Animatable, typed CSS variables | `stylex.types.*` | [Theming](./theming.md) |
| Per-subtree theme override | `stylex.createTheme` | [Theming](./theming.md) |
| Typed component style contracts | `StyleXStylesWithout<>` | [Component API](./component-api.md) |
| Multiple independent contextual groups | `stylex.defineMarker` | [StyleX Authoring](./stylex-authoring.md) |

Porting a Tailwind UI is not finished when every class has an equivalent. Check whether the
original worked around a missing primitive — a JS positioning library, a global keyframes
stylesheet, a `className` string threaded through props — and replace the workaround too.
