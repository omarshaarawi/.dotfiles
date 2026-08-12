# Shadows

Covers: shadows on cards, modals, popovers, dropdowns, buttons, elevated surfaces, and shadow/border pairings.

- Never pair a shadow with a solid gray border. Use a ring — a `0 0 0 1px` box shadow at
  5–10% of your neutral's `950` step (or black)
- A ring and an elevation shadow are both `box-shadow`, so they must be a single composed
  string. Two `boxShadow` declarations in one namespace means the second erases the first
- Never make an elevated element (a card, modal, or popover carrying a shadow) darker than
  its canvas — use white or the lightest neutral, not `zinc[50]`/`zinc[100]`. Darker fills
  are correct for inset panels and wells, which have no outer shadow
- Remove shadows in dark mode; see [Dark Mode](./dark-mode.md)
- Popovers, dropdowns, and tooltips are elevated surfaces and follow these rules; position
  them with CSS anchor positioning, see [Anchoring & Overlays](./anchoring.md)

```ts
const RING = `0 0 0 1px color-mix(in oklab, ${zinc[950]} 5%, transparent)`;

const styles = stylex.create({
  card: {
    backgroundColor: { default: base.white, [media.dark]: zinc[900] },
    boxShadow: {
      default: `${shadow.sm}, ${RING}`,
      [media.dark]: `inset 0 0 0 1px color-mix(in oklab, ${base.white} 5%, transparent)`,
    },
  },
});
```
