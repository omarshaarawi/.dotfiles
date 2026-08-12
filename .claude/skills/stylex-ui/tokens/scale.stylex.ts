// Sizing scales
// Generated from Tailwind CSS's default theme (packages/tailwindcss/theme.css).
// Source of truth for every numeric value in the stylex-ui guidelines.
// Regenerate rather than hand-edit; see tokens/README.md.
import * as stylex from '@stylexjs/stylex';

// Spacing scale: Tailwind computes `p-3` as calc(var(--spacing) * 3) where
// --spacing is 0.25rem. These are those products, precomputed.
// `space[3]` is the direct translation of `p-3`.
export const space = stylex.defineConsts({
  px: '1px',
  '0': '0',
  '0.5': '0.125rem',
  '1': '0.25rem',
  '1.5': '0.375rem',
  '2': '0.5rem',
  '2.5': '0.625rem',
  '3': '0.75rem',
  '3.5': '0.875rem',
  '4': '1rem',
  '5': '1.25rem',
  '6': '1.5rem',
  '7': '1.75rem',
  '8': '2rem',
  '9': '2.25rem',
  '10': '2.5rem',
  '11': '2.75rem',
  '12': '3rem',
  '14': '3.5rem',
  '16': '4rem',
  '20': '5rem',
  '24': '6rem',
  '28': '7rem',
  '32': '8rem',
  '36': '9rem',
  '40': '10rem',
  '44': '11rem',
  '48': '12rem',
  '52': '13rem',
  '56': '14rem',
  '60': '15rem',
  '64': '16rem',
  '72': '18rem',
  '80': '20rem',
  '96': '24rem',
});

// Border radius. `radius.xl` is `rounded-xl`.
export const radius = stylex.defineConsts({
  xs: '0.125rem',
  sm: '0.25rem',
  md: '0.375rem',
  lg: '0.5rem',
  xl: '0.75rem',
  '2xl': '1rem',
  '3xl': '1.5rem',
  '4xl': '2rem',
  none: '0',
  full: 'calc(infinity * 1px)',
});

// Font sizes. `text.sm` is `text-sm`.
export const text = stylex.defineConsts({
  xs: '0.75rem',
  sm: '0.875rem',
  base: '1rem',
  lg: '1.125rem',
  xl: '1.25rem',
  '2xl': '1.5rem',
  '3xl': '1.875rem',
  '4xl': '2.25rem',
  '5xl': '3rem',
  '6xl': '3.75rem',
  '7xl': '4.5rem',
  '8xl': '6rem',
  '9xl': '8rem',
});

// Tailwind's paired default line-height for each font size. `text-sm` implies both
// `text.sm` and `leadingFor.sm` -- always set them together (see typography.md).
export const leadingFor = stylex.defineConsts({
  xs: 'calc(1 / 0.75)',
  sm: 'calc(1.25 / 0.875)',
  base: 'calc(1.5 / 1)',
  lg: 'calc(1.75 / 1.125)',
  xl: 'calc(1.75 / 1.25)',
  '2xl': 'calc(2 / 1.5)',
  '3xl': 'calc(2.25 / 1.875)',
  '4xl': 'calc(2.5 / 2.25)',
  '5xl': '1',
  '6xl': '1',
  '7xl': '1',
  '8xl': '1',
  '9xl': '1',
});

// Font weights.
export const fontWeight = stylex.defineConsts({
  thin: '100',
  extralight: '200',
  light: '300',
  normal: '400',
  medium: '500',
  semibold: '600',
  bold: '700',
  extrabold: '800',
  black: '900',
});

// Letter spacing.
export const tracking = stylex.defineConsts({
  tighter: '-0.05em',
  tight: '-0.025em',
  normal: '0em',
  wide: '0.025em',
  wider: '0.05em',
  widest: '0.1em',
});

// Named line heights. Guidelines forbid these on headings; see typography.md.
export const leading = stylex.defineConsts({
  tight: '1.25',
  snug: '1.375',
  normal: '1.5',
  relaxed: '1.625',
  loose: '2',
});

// Container widths, for max-width constraints. `container.xs` is `max-w-xs`.
export const container = stylex.defineConsts({
  '3xs': '16rem',
  '2xs': '18rem',
  xs: '20rem',
  sm: '24rem',
  md: '28rem',
  lg: '32rem',
  xl: '36rem',
  '2xl': '42rem',
  '3xl': '48rem',
  '4xl': '56rem',
  '5xl': '64rem',
  '6xl': '72rem',
  '7xl': '80rem',
});

// Blur radii.
export const blur = stylex.defineConsts({
  xs: '4px',
  sm: '8px',
  md: '12px',
  lg: '16px',
  xl: '24px',
  '2xl': '40px',
  '3xl': '64px',
});

// Easing curves.
export const ease = stylex.defineConsts({
  in: 'cubic-bezier(0.4, 0, 1, 1)',
  out: 'cubic-bezier(0, 0, 0.2, 1)',
  'in-out': 'cubic-bezier(0.4, 0, 0.2, 1)',
});

// Default font stacks.
export const font = stylex.defineConsts({
  sans: "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', 'Noto Sans', Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji'",
  serif: "ui-serif, Georgia, Cambria, 'Times New Roman', Times, serif",
  mono: "ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', 'Courier New', monospace",
});
