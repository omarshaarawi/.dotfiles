# Surfaces

Covers: cards, wells, borders, dividers, white space, recessed backgrounds, and other content grouping treatments.

## Design Rules

- Don't default to white cards on gray backgrounds — prefer content directly on a white
  background, or white cards with just a border on a white background
- Choose the treatment from the information hierarchy: white space alone for tightly related
  items; subtle borders or dividers for sibling content needing separation; wells (recessed
  backgrounds) for secondary or nested content; cards with borders or shadows for standalone,
  interactive, or highly distinct items
- Use the lightest separation that still works — whitespace first, then subtle borders and
  dividers, then cards. Never jump straight to cards
- Reserve cards for content that is independently interactive (clickable to navigate) or
  contains fundamentally different content types
- Use subtle top borders or vertical dividers for sibling items in a shared context — stat
  grids, metric rows, dashboard KPIs
- Whitespace alone is enough when content has inherent contrast (large numbers against small
  labels, bold headings against body text)
- Never use a solid color for a divider. Use an opacity-mixed neutral —
  `color-mix(in oklab, ${zinc[950]} 5%, transparent)`, not `zinc[200]`

## Dividers

StyleX has no `divide-*`. Put the border on the children under `':not(:first-child)'`,
which compiles correctly.

- Divider-separated items get equal padding on both sides of the divider, except at the
  ends: the first item in a row gets no leading padding, the last gets no trailing padding
- Dividers must be reconfigured at every breakpoint where the column count changes. Target
  the items that are no longer in the first column with `:nth-child()` — a 2-column grid
  uses `':nth-child(2n)'`, a 4-column grid uses `':not(:nth-child(4n+1))'`
- When the grid collapses to a single column, drop the vertical dividers and use horizontal
  ones between rows instead

```ts
const DIVIDER = `color-mix(in oklab, ${zinc[950]} 5%, transparent)`;

const styles = stylex.create({
  // 1 column on mobile: horizontal rules. 4 columns at lg: vertical rules.
  cell: {
    paddingInline: space[4],
    borderTopWidth: { default: '1px', [media.lg]: 0 },
    borderTopStyle: 'solid',
    borderTopColor: DIVIDER,
    borderInlineStartWidth: {
      default: 0,
      [media.lg]: { default: '1px', ':nth-child(4n+1)': 0 },
    },
    borderInlineStartStyle: 'solid',
    borderInlineStartColor: DIVIDER,
  },
  firstCell: { borderTopWidth: 0 },
});
```
