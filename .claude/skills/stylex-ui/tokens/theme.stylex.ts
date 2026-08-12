// Runtime theme variables
// The only tokens that are `defineVars` rather than `defineConsts`.
//
// Consts are inlined text and cannot be animated, transitioned, or overridden per subtree.
// These four can. Keep this file small: every entry here is a live CSS custom property,
// and the reason the palette ramps are consts is to avoid hundreds of them.
//
// `stylex.types.*` emits a real @property rule with the correct syntax, which is what makes
// a variable interpolate. An untyped custom property is an opaque string to the browser --
// it will jump at the end of a transition instead of easing, with no error anywhere.
//
// See guidelines/theming.md.
import * as stylex from '@stylexjs/stylex';

export const brand = stylex.defineVars({
  // blue-600 / blue-400, matching the palette ramps
  accent: stylex.types.color({
    default: 'oklch(54.6% 0.245 262.881)',
    '@media (prefers-color-scheme: dark)': 'oklch(70.7% 0.165 254.624)',
  }),
  accentContrast: stylex.types.color({
    default: '#fff',
    '@media (prefers-color-scheme: dark)': '#fff',
  }),
  // Overridable per subtree via createTheme, e.g. a compact density.
  radius: stylex.types.length('0.75rem'),
  // Animatable progress/scale driver for indeterminate and measured states.
  progress: stylex.types.percentage('0%'),
});
