# Pricing Cards

Covers: pricing tiers, pricing cards, pricing tables, plan comparisons, emphasized plans, and popular/recommended plans.

## Design Rules

- Emphasize a card through button styling and optional "Popular" text. Never give the
  emphasized card a different background color
- Feature list checkmarks follow [Icons](./icons.md) — 16px with `height: '1lh'`

## Coding Rules

- Never isolate the emphasized card from its siblings. It is a grid sibling, not a
  standalone section
- Align buttons across cards: `display: 'flex', flexDirection: 'column',
  justifyContent: 'space-between'` on each card, with all content above the button wrapped
  in a single element so the button is pushed to the bottom
- If the emphasized card is taller than its siblings, use explicit grid rows — never
  negative margins or relative positioning. The gap rows define how far it pokes out,
  normal cards sit in the middle row, and the emphasized card spans all rows

```ts
const styles = stylex.create({
  grid: {
    display: 'grid',
    gridTemplateColumns: { default: '1fr', [media.lg]: 'repeat(3, minmax(0, 1fr))' },
    gridTemplateRows: { default: null, [media.lg]: `${space[6]} 1fr ${space[6]}` },
    gap: space[6],
  },
  card: { display: 'flex', flexDirection: 'column', justifyContent: 'space-between' },
  normal: { gridRowStart: { default: 'auto', [media.lg]: 2 } },
  emphasized: { gridRow: { default: 'auto', [media.lg]: '1 / -1' } },
});
```
