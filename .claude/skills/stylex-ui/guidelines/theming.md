# Theming

Covers: runtime themes, brand overrides, typed variables, and when a value must be a variable rather than a constant.

The token layer is `defineConsts` by default — inlined, zero runtime cost. This file covers
the cases where that is not enough. See [tokens/README.md](../tokens/README.md) for why consts
are the default.

## Choosing Between Consts and Vars

Reach for `defineVars` only when one of these is true:

- The value changes at runtime — a user-selected brand color, a tenant palette, a density setting
- The value must be **animatable or transitionable**. Consts are inlined text; there is
  nothing for the browser to interpolate
- The value is overridden per-subtree with `createTheme`

Everything else stays a const. Converting the whole palette to vars trades a real memory cost
for a capability that four values needed.

## Typed Variables

`stylex.types.*` inside `defineVars` or `createTheme` emits a real `@property` rule with the
right `syntax`. This is what makes a variable animatable — an untyped custom property is a
string to the browser and will not interpolate.

Available: `angle`, `color`, `url`, `image`, `integer`, `lengthPercentage`, `length`,
`percentage`, `number`, `resolution`, `time`, `transformFunction`, `transformList`.

- Type any variable you intend to animate or transition. An untyped one fails silently — the
  value jumps at the end instead of easing, with no error anywhere
- Typed variables also get real fallback behavior for invalid values instead of inheriting garbage

```ts
// theme.stylex.ts
import * as stylex from '@stylexjs/stylex';

export const brand = stylex.defineVars({
  accent: stylex.types.color({
    default: 'oklch(54.6% 0.245 262.881)',
    '@media (prefers-color-scheme: dark)': 'oklch(70.7% 0.165 254.624)',
  }),
  radius: stylex.types.length('0.75rem'),
});
```

## createTheme

`createTheme` produces an override for an existing `VarGroup`, applied by spreading it onto a
subtree. Themes for the same group are mutually exclusive and do not merge — applying a second
replaces the first rather than layering on it. Any variable not explicitly overridden keeps
its default.

```ts
export const highContrast = stylex.createTheme(brand, {
  accent: stylex.types.color({ default: 'oklch(35% 0.25 262)' }),
});

<section {...stylex.props(highContrast)}>{/* inherits the override */}</section>;
```

- Define themes for a shared base with an `env` function rather than repeating the full token
  set in every theme
- Keep the number of themes small. Each is a real CSS rule set, and mutually-exclusive themes
  are hard to reason about once they nest

## Dark Mode

Dark mode is a media condition by default, not a theme. See [Dark Mode](./dark-mode.md) for the
decision and the rule against doing both.
