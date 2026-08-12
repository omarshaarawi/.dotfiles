# Interactivity

Covers: hover states, transitions, animations, active states, and behavior on clickable and non-clickable elements.

- Never add `:hover` states to non-interactive elements — reserve them for buttons, links,
  and other clickable elements
- Never add a transition for a hover color or background change — reserve transitions for
  elements that move or transform
- Guard motion behind `media.motionReduce`, setting `transitionDuration` and
  `animationDuration` to `0s` rather than removing the declaration
- Anything beyond a simple transition belongs in [Animation](./animation.md) via
  `stylex.keyframes` — never a hand-written `@keyframes` block in a stylesheet
- Transitioning a token value requires a typed `defineVars` entry. Consts are inlined text
  and will not interpolate; see [Theming](./theming.md)

```ts
const styles = stylex.create({
  toggle: {
    transitionProperty: 'transform',
    transitionDuration: { default: '200ms', [media.motionReduce]: '0s' },
    transitionTimingFunction: ease.inOut,
  },
});
```
