# Landing Pages

Covers: landing pages, marketing pages, stacked page sections, heroes, CTAs, pricing sections, feature sections, and full-page consistency.

These are consistency rules. In StyleX they are easier to hold than in Tailwind, because the
shared value can be a module constant rather than a class string repeated across files —
define it once and import it.

- Reuse the same primary/secondary button styling across the entire page. If the hero uses a
  link-style secondary, every other section's secondary action must match
- Reuse the same font treatment (size, weight, color) whenever the same idea appears again.
  Match the existing instance exactly
- Use the same container style across the page. Once established (outline, tinted), every
  subsequent container matches
- Use the same border radius for all containers at the same level
- Use the same column `gap` across all multi-column sections. Check what existing sections
  use before adding a new one
- Never place a centered layout directly below a left-aligned one, unless the section above
  ends with full-width containers, a background color change separates them, or a visible
  divider sits between
- Never have more centered heading groups than left-aligned ones. Centered works for heroes,
  CTAs, and sections with symmetrical content beneath. Default to left-aligned for feature
  grids, split layouts, and content-heavy sections
