# Component API

Covers: how components accept, restrict, and merge styles from callers.

This has no Tailwind analogue. In Tailwind a component takes a `className` string and hopes
for the best. StyleX makes the style contract a type, so a component can state exactly what
a caller may override.

## Rules

- A component that accepts styling takes a `style` prop typed `StyleXStyles<>` and applies it
  **last**, so the caller always wins:
  `<div {...stylex.props(styles.base, style)} />`
- Never accept a `className` or a `style` object of raw CSS. Passing class name strings
  between components defeats the merge order that makes StyleX deterministic
- Use `StyleXStylesWithout<{…}>` to lock properties the caller must not touch. This is how a
  layout primitive keeps ownership of its own positioning, and it fails at the type level
  rather than in a rendered bug:
  `style?: StyleXStylesWithout<{ position: unknown; inset: unknown }>`
- Use `StaticStyles<>` when a prop must be a static style object with no dynamic functions
- Type a theme parameter as `Theme<typeof vars>` and a variable group as `VarGroup<…>` when
  passing them through props
- Use `stylex.props` for React. Use `stylex.attrs` when you need a plain attributes object —
  a string `class` and `style` — for non-React renderers, template engines, or SSR that
  writes attributes directly
- Never spread a caller's arbitrary props over the styled element after `props`. It silently
  clobbers the generated `className`

```tsx
import * as stylex from '@stylexjs/stylex';
import type { StyleXStylesWithout } from '@stylexjs/stylex';

type CardProps = {
  children: React.ReactNode;
  // callers may restyle the surface, but not take over layout
  style?: StyleXStylesWithout<{ position: unknown; inset: unknown }>;
};

const styles = stylex.create({
  base: { position: 'relative', padding: space[4], borderRadius: radius.xl },
});

export function Card({ children, style }: CardProps) {
  return <div {...stylex.props(styles.base, style)}>{children}</div>;
}
```
