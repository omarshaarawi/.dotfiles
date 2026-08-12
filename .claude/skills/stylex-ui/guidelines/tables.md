# Tables

Covers: data tables, comparison tables, table headings, row dividers, horizontal scrolling tables, and table containers.

## Design Rules

- Never uppercase table headings — sentence case
- Never let a table heading wrap. `whiteSpace: 'nowrap'` on `<th>`
- Never put a table in a container or card. Place it directly on the background
- Only horizontal lines between rows. No vertical lines, no outer border
- Always `width: '100%'` so the table fills its container
- Hide headings with the screen-reader-only pattern when the column content is
  self-explanatory — typically 2–3 column tables where headings add nothing

## Responsive Tables

When the columns won't fit, wrap the table in two elements. The outer scrolls and carries
negative inline margins that cancel the page container's padding, so the scroll region runs
edge to edge. The inner restores that padding. Match the negative margins to the actual
container padding in use.

```ts
const styles = stylex.create({
  scroller: {
    overflowX: 'auto',
    whiteSpace: 'nowrap',
    marginInline: { default: `calc(${space[4]} * -1)`, [media.sm]: `calc(${space[6]} * -1)` },
    marginBlock: `calc(${space[2]} * -1)`,
  },
  inner: {
    display: 'inline-block',
    minWidth: '100%',
    verticalAlign: 'middle',
    paddingInline: { default: space[4], [media.sm]: space[6] },
    paddingBlock: space[2],
  },
  row: {
    borderTopWidth: { default: 0, ':not(:first-child)': '1px' },
    borderTopStyle: 'solid',
    borderTopColor: `color-mix(in oklab, ${zinc[950]} 5%, transparent)`,
  },
});
```
