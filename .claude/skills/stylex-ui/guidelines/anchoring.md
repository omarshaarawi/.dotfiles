# Anchoring & Overlays

Covers: popovers, dropdowns, menus, tooltips, comboboxes, and any element positioned relative to a trigger.

ui.sh has no rules here because Tailwind has no anchor-positioning primitive. StyleX compiles
CSS anchor positioning directly, so an overlay can place and re-place itself with no JS
positioning library and no measurement on scroll.

## Design Rules

- Overlays are elevated surfaces. They follow [Shadows](./shadows.md) — a composed shadow plus
  ring, never a solid gray border, and never darker than the canvas beneath them
- Match the overlay's radius to the trigger's radius family; see [Border Radius](./border-radius.md)
- Give an overlay a small offset from its trigger (`space[2]`), never zero. A flush overlay
  reads as part of the trigger rather than above it
- Constrain overlay width and let the fallbacks handle the edges. An overlay wider than a phone
  viewport is the most common way this pattern breaks
- Use the native `popover` attribute and the top layer where possible. It gives you light
  dismiss, focus handling, and stacking for free, and avoids the z-index escalation that
  otherwise creeps across a codebase

## Coding Rules

- Name the anchor with `anchorName` on the trigger and bind with `positionAnchor` on the
  overlay. Use a `--kebab-case` custom ident, kept in a module constant so the two sides
  cannot drift
- Place with `positionArea`. It is far more legible than four inset properties, and it is what
  the fallback keywords operate on
- Always set `positionTryFallbacks`. An overlay with no fallback clips off-screen near a
  viewport edge — invisible in development, obvious to users. `'flip-block, flip-inline'`
  covers the common cases
- Add `positionVisibility: 'anchors-visible'` so the overlay hides when its trigger scrolls
  out of view, instead of floating detached

```ts
const ANCHOR = '--trigger';

const styles = stylex.create({
  trigger: { anchorName: ANCHOR },
  popover: {
    position: 'absolute',
    positionAnchor: ANCHOR,
    positionArea: 'bottom span-end',
    positionTryFallbacks: 'flip-block, flip-inline',
    positionVisibility: 'anchors-visible',
    marginBlockStart: space[2],
    maxWidth: container.xs,
    borderRadius: radius.lg,
    backgroundColor: { default: base.white, [media.dark]: zinc[900] },
    boxShadow: `${shadow.lg}, 0 0 0 1px color-mix(in oklab, ${zinc[950]} 5%, transparent)`,
  },
});
```

## Do Not Use `stylex.positionTry` (0.19.0)

**`stylex.positionTry` is broken in StyleX 0.19.0, the current release.** It generates a
malformed `@position-try` rule that repeats each property name as its own value:

```
@position-try --x19xfkd6 {position-anchor:position-anchor;position-anchor:--x;top:top;top:0;}
```

The bundler's CSS parser then fails outright — `SyntaxError: Unexpected token
SquareBracketBlock` — so the whole build dies rather than emitting bad CSS quietly. This
reproduces with the shape given in StyleX's own documentation, including the minimal
`stylex.positionTry({ top: '0' })`.

Use the built-in `position-try-fallbacks` keywords above instead. They need no `@position-try`
rule at all, and `flip-block`/`flip-inline` handle the cases a custom fallback would. Reach for
custom fallback rules only when the built-ins genuinely cannot express the placement, and
re-test `stylex.positionTry` when upgrading past 0.19.0.

## Fallback Support

Anchor positioning is not universal. When the project supports browsers without it, keep the
overlay usable rather than perfectly placed: give it sane static positioning as the base and
layer the anchor properties behind `@supports (anchor-name: --x)`. A tooltip that lands in the
wrong place still communicates; one pinned to `0,0` does not.
