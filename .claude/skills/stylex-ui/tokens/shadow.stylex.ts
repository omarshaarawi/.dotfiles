// Shadows
// Generated from Tailwind CSS's default theme (packages/tailwindcss/theme.css).
// Source of truth for every numeric value in the stylex-ui guidelines.
// Regenerate rather than hand-edit; see tokens/README.md.
import * as stylex from '@stylexjs/stylex';

// Box shadows. `shadow.sm` is `shadow-sm`.
// Pair with a ring, never a solid gray border -- see guidelines/shadows.md.
export const shadow = stylex.defineConsts({
  '2xs': '0 1px rgb(0 0 0 / 0.05)',
  xs: '0 1px 2px 0 rgb(0 0 0 / 0.05)',
  sm: '0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1)',
  md: '0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)',
  lg: '0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)',
  xl: '0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)',
  '2xl': '0 25px 50px -12px rgb(0 0 0 / 0.25)',
  inner: 'inset 0 2px 4px 0 rgb(0 0 0 / 0.05)',
});

// Inset shadows, for wells and recessed panels.
export const insetShadow = stylex.defineConsts({
  '2xs': 'inset 0 1px rgb(0 0 0 / 0.05)',
  xs: 'inset 0 1px 1px rgb(0 0 0 / 0.05)',
  sm: 'inset 0 2px 4px rgb(0 0 0 / 0.05)',
});

// Drop shadows, for filter: drop-shadow().
export const dropShadow = stylex.defineConsts({
  xs: '0 1px 1px rgb(0 0 0 / 0.05)',
  sm: '0 1px 2px rgb(0 0 0 / 0.15)',
  md: '0 3px 3px rgb(0 0 0 / 0.12)',
  lg: '0 4px 4px rgb(0 0 0 / 0.15)',
  xl: '0 9px 7px rgb(0 0 0 / 0.1)',
  '2xl': '0 25px 25px rgb(0 0 0 / 0.15)',
});

// Text shadows.
export const textShadow = stylex.defineConsts({
  '2xs': '0px 1px 0px rgb(0 0 0 / 0.15)',
  xs: '0px 1px 1px rgb(0 0 0 / 0.2)',
  sm: '0px 1px 0px rgb(0 0 0 / 0.075), 0px 1px 1px rgb(0 0 0 / 0.075), 0px 2px 2px rgb(0 0 0 / 0.075)',
  md: '0px 1px 1px rgb(0 0 0 / 0.1), 0px 1px 2px rgb(0 0 0 / 0.1), 0px 2px 4px rgb(0 0 0 / 0.1)',
  lg: '0px 1px 2px rgb(0 0 0 / 0.1), 0px 3px 2px rgb(0 0 0 / 0.1), 0px 4px 8px rgb(0 0 0 / 0.1)',
});
