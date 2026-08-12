# Dark Mode

Covers: dark-mode styling, light-to-dark conversion, dark-mode contrast audits, dark-mode images, and dark-mode SVGs.

## Design Rules

- Dark mode is about preserving the same contrast ratios as light mode, not inverting colors
- Dark mode does not need to preserve every detail of the light design — it needs to look good
- Default to following the OS setting via `media.dark`. Only add a manual toggle when the
  user explicitly asks for one
- Remove all shadows in dark mode. Replace elevation with a hairline inset ring at ~5% white,
  since a shadow against a dark canvas reads as mud
- On dark-mode-only sites, set `colorScheme: 'dark'` on the root element so native scrollbars
  and form controls render dark

## Implementation

There are two ways to express dark mode in StyleX, and the choice is architectural.

**Media conditions at the use site** — the default. Mirrors Tailwind's `dark:` variant, needs
no provider, and works with the const-based token layer:

```ts
backgroundColor: { default: base.white, [media.dark]: zinc[900] },
```

**A `defineVars` theme** — only when the project needs a manual toggle or runtime theming.
Define semantic variables with dark values built in, then swap with `createTheme`. Do not
convert the whole palette; define only the handful of semantic slots that actually flip:

```ts
// theme.stylex.ts
export const surface = stylex.defineVars({
  bg:   { default: '#fff',    '@media (prefers-color-scheme: dark)': '#18181b' },
  text: { default: '#18181b', '@media (prefers-color-scheme: dark)': '#f4f4f5' },
});
```

See [Theming](./theming.md) for typed variables and `createTheme`. Pick one and use it consistently. A codebase doing both has two sources of truth for what
"dark" means, and they drift.

## Component Rules

- Never keep a large branded or colored panel in dark mode. Use the same background as the
  page and separate sections with a light divider instead
- Style cards only slightly lighter than the page background (`zinc[900]` on a `zinc[950]`
  page), and add an inset ring at ~5% white for definition
- Make decorative quote marks in testimonials very faint — white at ~5%
- Never use multiple heading colors in dark mode. One light color for all headings

## Raster Image Rules

- When adding or improving dark mode, audit the page for rasterized images needing dark
  variants: photos, screenshots, product mockups, decorative backgrounds, textures, illustrations
- Never ship a CSS filter (`invert`, `brightness`, `contrast`, `opacity`) as the final
  dark-mode treatment for a raster image. Create real dark-mode files

## SVG Rules

- For inline `<svg>`, switch `fill`/`stroke` with a `media.dark` condition
- For external SVGs referenced via `<img>`, ship a real dark variant alongside the original
  (`logo.svg` and `logo-dark.svg`). Never substitute a filter or an opacity change
