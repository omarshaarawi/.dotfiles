# Dashboards

Covers: dashboard layouts, stat grids, KPI cards, metric cards, admin panels, analytics views, and summary data.

## Design Rules

- Never let a stat or metric card title wrap. Truncate it to one line
- Never put icons in stat/metric cards — plain text labels and values only
- Prefer dividers over cards for stat grids; see [Surfaces](./surfaces.md)

## Coding Rules

- Always use container queries for responsive dashboard widgets, not media queries. A widget
  that can appear in a sidebar and in a full-width panel must respond to its own width
- Set `fontVariantNumeric: 'tabular-nums'` on any value that changes over time — counters,
  timers, prices, live stats. Without it the row reflows every time a digit changes

```ts
const styles = stylex.create({
  title: {
    overflow: 'hidden',
    textOverflow: 'ellipsis',
    whiteSpace: 'nowrap',
    fontSize: text.sm,
    lineHeight: leadingFor.sm,
    color: zinc[500],
  },
  value: {
    fontSize: text['3xl'],
    lineHeight: leadingFor['3xl'],
    fontWeight: fontWeight.semibold,
    fontVariantNumeric: 'tabular-nums',
  },
});
```
