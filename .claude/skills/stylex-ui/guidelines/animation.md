# Animation

Covers: keyframe animations, transitions, loading states, entrance and exit motion, and reduced-motion handling.

Use `stylex.keyframes`. Never hand-write an `@keyframes` block in a stylesheet — the compiled
name is generated, and a hand-written rule is invisible to StyleX's deduplication.

## Design Rules

- Animate transforms and opacity. Animating layout properties (`width`, `height`, `top`,
  `margin`) forces layout on every frame
- Reserve motion for elements that move or transform. Never transition a hover color or
  background change; see [Interactivity](./interactivity.md)
- Entrances can be expressive, exits should be quick. An exit animation is time between the
  user's action and the result
- Use the `ease` tokens. `ease.out` for entrances, `ease.in` for exits, `ease.inOut` for
  anything that moves and settles

## Coding Rules

- Declare keyframes in the **same file** that uses them. This is a StyleX requirement, not a
  convention. Duplicates across files dedupe in the output, so a shared animation is fine to
  repeat rather than export
- Always honour `media.motionReduce`. Set duration to `0s` rather than removing the
  declaration, so the end state still applies and the element does not get stuck mid-animation
- Never animate a `defineConsts` value. Consts are inlined text, not live variables. Animating
  a token means a typed `defineVars` entry — see [Theming](./theming.md)

```ts
const fadeInUp = stylex.keyframes({
  from: { opacity: 0, transform: 'translateY(-8px)' },
  to: { opacity: 1, transform: 'translateY(0)' },
});

const styles = stylex.create({
  panel: {
    animationName: fadeInUp,
    animationDuration: { default: '200ms', [media.motionReduce]: '0s' },
    animationTimingFunction: ease.out,
    animationFillMode: 'both',
  },
});
```
