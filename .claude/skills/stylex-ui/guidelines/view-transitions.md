# View Transitions

Covers: page and route transitions, shared-element morphs, list reordering, and cross-fade behavior.

`stylex.viewTransitionClass` styles the `::view-transition-*` pseudo-elements without writing
a global stylesheet. It returns a class name you attach to the transitioning element.

## Rules

- Use view transitions for changes the user should be able to follow — a card expanding into
  a detail view, a list item promoting to a header. Not for every route change
- The four options map to the pseudo-elements: `group` (the container), `imagePair`,
  `old` (the outgoing snapshot), `new` (the incoming one). Style only the ones you need
- `viewTransitionClass` does **not** support media queries. Reduced-motion cannot be handled
  inside it, so gate the transition at the call site instead — check
  `matchMedia('(prefers-reduced-motion: reduce)')` and skip starting the transition
- Compose with `stylex.keyframes` for anything beyond a duration change
- Keep durations short. A shared-element morph over 200–300ms reads as responsive; over 600ms
  it reads as slow
- Give each shared element a unique `viewTransitionName`. Two elements sharing a name in one
  transition makes the browser drop the animation silently

```ts
const fadeInUp = stylex.keyframes({
  from: { opacity: 0, transform: 'translateY(-30px)' },
  to: { opacity: 1, transform: 'translateY(0)' },
});

const cardTransition = stylex.viewTransitionClass({
  group: { animationDuration: '250ms' },
  old: { animationDuration: '150ms' },
  new: { animationName: fadeInUp, animationDuration: '250ms' },
});

// Attach the returned class name directly.
<div className={cardTransition} />;
```

Gate it where the transition starts, since the class itself cannot:

```ts
const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
if (reduced || !document.startViewTransition) {
  applyChange();
} else {
  document.startViewTransition(applyChange);
}
```
