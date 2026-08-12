# Icons

Covers: SVG icons, Heroicons, inline checkmarks, icon buttons, icon sizing, and icon alignment with text.

## Design Rules

- Never generate raw SVG icons — import from the project's icon library, or Heroicons if
  none is established
- Never wrap icons in decorative containers (colored squares, circles with backgrounds) —
  use the icon directly
- Never scale icons. A `viewBox="0 0 24 24"` icon renders at `space[6]`, `0 0 20 20` at
  `space[5]`, `0 0 16 16` at `space[4]`. If an icon looks too small, use a different icon
  set rather than sizing it up
- Use 16px icons (`space[4]`) inline with `text.sm` — checklists, feature items, comparison
  tables, inline labels. Reserve 20px for navigation list icons
- Align an icon beside a text group (label plus supporting text) to the first line with
  `alignItems: 'flex-start'` or `'baseline'`, never `'center'` on the group
- Application UIs (dashboards, settings, admin, sidebar nav, forms) use 16px icons only

## Coding Rules

- Give icons `height: '1lh'` to center them optically against adjacent text, and set the
  font size on a wrapper rather than nudging with margins
- Color icons with `fill` or `stroke` directly. Do not set a `color` and rely on
  `currentColor` unless the icon genuinely needs to inherit
- Always set `flexShrink: 0` on icons inside flex containers
