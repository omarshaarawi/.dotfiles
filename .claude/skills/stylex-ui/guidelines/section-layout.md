# Section Layout

Covers: page sections, constrained containers, centered vs left-aligned layouts, section padding, grids, and stacked content alignment.

## Design Rules

- Left-aligned sections align to the page container edge. Never a narrow `maxWidth` plus
  `marginInline: 'auto'` — use the page-level max width and constrain inner content separately
- Align containers that occupy the same proportion across stacked sections, so their edges
  line up as you scroll. Use consistent grid definitions and gap values
- Avoid nested max-width constraints on grids and lists that fill their container. If a
  feature grid spans the full constrained width, don't add a narrower max-width — content
  should align to the page container edges, not float in the middle. Nested max-widths are
  fine for self-contained units meant to feel bounded: pricing cards, forms, comparison
  tables, centered media

## Coding Rules

Use two elements for a constrained section. The outer carries background and vertical
padding; the inner carries max width, centering, and horizontal padding. Apply the same
pattern to every section on a page so content edges align.

```ts
const styles = stylex.create({
  section: { paddingBlock: { default: space[16], [media.sm]: space[24] } },
  container: {
    maxWidth: container['7xl'],
    marginInline: 'auto',
    paddingInline: { default: space[4], [media.sm]: space[6], [media.lg]: space[8] },
  },
});
```
