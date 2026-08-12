# Atoms

Covers: `@stylexjs/atoms`, inline one-off styles, and when a named style is the better answer.

Added in StyleX 0.19. `@stylexjs/atoms` compiles to the same output as `stylex.create`, so it
costs nothing extra — the question is only readability.

## Rules

- Reach for atoms for genuine one-offs at a call site: a single alignment fix, a one-property
  override. Anything reused, or anything carrying design intent, belongs in a named
  `stylex.create` namespace where it can be found and changed once
- Never build a component's whole appearance out of atoms. That is Tailwind's model, and it
  loses the thing StyleX is for — a named, typed, mergeable style object
- Atoms must be compiled by `@stylexjs/babel-plugin`. They throw at runtime if accessed
  uncompiled, so a missing build step fails loudly rather than silently
- They compose with everything: `stylex.props(styles.root, x.color.blue)`

## Syntax

- Static values by property access: `x.display.flex`, `x.flexDirection.column`
- Dynamic values by call: `x.color(value)`, `x.marginInlineStart(offset)`
- Values starting with a digit take a leading underscore, which the compiler strips:
  `x.padding._16px`, `x.fontSize._1rem`
- Values with spaces or punctuation use computed syntax: `x.opacity['0.5']`,
  `x.width['calc(100% - 20px)']`

```tsx
import * as stylex from '@stylexjs/stylex';
import x from '@stylexjs/atoms';

<div {...stylex.props(styles.row, x.alignItems.baseline)} />;
```

Prefer the token layer over atom literals. `x.padding._16px` hardcodes a value that
`space[4]` already holds, and the hardcoded one will not move when the scale does.
