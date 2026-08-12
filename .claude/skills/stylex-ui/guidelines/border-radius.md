# Border Radius

Covers: rounded cards, panels, buttons, images, screenshots, nested surfaces, and any UI element where radius consistency matters.

- Use concentric border radii on closely nested rounded elements — the inner radius is the
  outer radius minus the padding between them. StyleX has no `calc()` on tokens at author
  time, so express the relationship in a `calc()` string so the math stays visible and
  survives a token change
- Use `min()` with a viewport unit for image and screenshot radii rather than a fixed step —
  `min(1vw, 12px)` hits the intended value at full desktop width and scales down proportionally
  as the screen shrinks

```ts
const OUTER_RADIUS = radius['2xl'];
const CARD_PADDING = space[2];

const styles = stylex.create({
  frame: { borderRadius: OUTER_RADIUS, padding: CARD_PADDING },
  inner: { borderRadius: `calc(${OUTER_RADIUS} - ${CARD_PADDING})` },
  screenshot: { borderRadius: 'min(1vw, 12px)' },
});
```
