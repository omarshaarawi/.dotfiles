# Responsive Design

Covers: mobile, tablet, desktop, breakpoints, container queries, overflow, wrapping, and cramped viewports.

## Design Rules

- Every layout must adapt from mobile to desktop. Adjust grid columns, spacing, font sizes,
  and visibility across breakpoints
- Multi-column desktop layouts (sidebars, secondary nav, filter panels) must collapse to a
  single column on small screens — use a mobile menu or disclosure, never just squeeze the columns
- Body text, subheadings, form controls, and icons should be **larger on mobile** and scale
  down at `media.sm`. Write the larger mobile value as `default` and the smaller desktop
  value under `media.sm`. This applies to body text, subheadings, stat values, form labels,
  badges, buttons, input padding, and icons — but **not** to h1s, which stay the same size
  or get smaller on mobile, never bigger
- Body text must be at least 16px (`text.base`) on mobile. `text.sm` is only acceptable at
  `media.sm` and above

## Coding Rules

- Import breakpoints from `tokens/media.stylex.ts`. Never inline a raw media query string
- Mobile-first: `default` is the mobile value, `media.sm` and up override it. Reach for
  `mediaMax` only when a style genuinely must cap rather than raise
- Use container queries for component-level responsiveness — anything whose layout depends
  on the space available rather than the viewport (dashboard widgets, feature cards, pricing
  tiers, testimonial grids)
- Place the container as close to the responsive content as possible — a direct wrapper
  around the items, never a page-level element
- `@container` conditions compile correctly in StyleX (verified on 0.19.0) even though they
  are undocumented. Keep shared container queries in `media.stylex.ts` next to the breakpoints

```ts
const styles = stylex.create({
  // larger on mobile, smaller at sm -- the direction most people get backwards
  body: {
    fontSize: { default: text.base, [media.sm]: text.sm },
    lineHeight: { default: leadingFor.base, [media.sm]: leadingFor.sm },
  },
  widget: { containerType: 'inline-size' },
  widgetGrid: {
    display: 'grid',
    gap: space[6],
    gridTemplateColumns: {
      default: '1fr',
      '@container (min-width: 32rem)': 'repeat(2, minmax(0, 1fr))',
    },
  },
});
```
