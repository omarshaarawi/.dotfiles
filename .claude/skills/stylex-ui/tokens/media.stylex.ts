// Media queries
// Generated from Tailwind CSS's default theme (packages/tailwindcss/theme.css).
// Source of truth for every numeric value in the stylex-ui guidelines.
// Regenerate rather than hand-edit; see tokens/README.md.
import * as stylex from '@stylexjs/stylex';

// Shareable media queries. `defineConsts` is built for exactly this: the strings are
// inlined into the stylesheet at build time instead of becoming CSS variables.
//
// Usage -- the direct translation of `p-4 md:p-6`:
//   padding: { default: space[4], [media.md]: space[6] }
//
// Requires a real StyleX bundler pass (@stylexjs/unplugin or the webpack/rollup
// plugin). A bare single-file babel transform does not resolve consts across
// files and will emit `var(--x…){…}` instead of `@media …`.
export const media = stylex.defineConsts({
  sm: '@media (min-width: 40rem)',
  md: '@media (min-width: 48rem)',
  lg: '@media (min-width: 64rem)',
  xl: '@media (min-width: 80rem)',
  _2xl: '@media (min-width: 96rem)',
  dark: '@media (prefers-color-scheme: dark)',
  light: '@media (prefers-color-scheme: light)',
  motionSafe: '@media (prefers-reduced-motion: no-preference)',
  motionReduce: '@media (prefers-reduced-motion: reduce)',
  hover: '@media (hover: hover)',
  pointerFine: '@media (pointer: fine)',
  pointerCoarse: '@media (pointer: coarse)',
  forcedColors: '@media (forced-colors: active)',
  print: '@media print',
});

// Max-width counterparts, for the rare rule that must cap rather than raise.
// Prefer mobile-first `media.*` above; see guidelines/responsive-design.md.
export const mediaMax = stylex.defineConsts({
  sm: '@media (max-width: 39.999rem)',
  md: '@media (max-width: 47.999rem)',
  lg: '@media (max-width: 63.999rem)',
  xl: '@media (max-width: 79.999rem)',
  _2xl: '@media (max-width: 95.999rem)',
});
