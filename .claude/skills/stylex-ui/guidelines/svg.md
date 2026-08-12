# SVG

Covers: inline SVG, SVG color styling, `fill`, `stroke`, and SVG markup conventions.

- Omit `xmlns` on inline `<svg>` elements in JSX — it is only needed in a standalone `.svg` file
- Style SVG color through StyleX (`fill`, `stroke`) rather than hardcoded attributes or
  inline ternaries. Switch colors with conditional style values or `stylex.when.*`, not by
  swapping attributes in JS
- Never set a `fill="currentColor"` attribute and a StyleX `fill` on the same element. Pick
  one: `fill: 'currentColor'` in the style to inherit text color, or a concrete token value

```ts
const styles = stylex.create({
  check: {
    width: space[4],
    height: space[4],
    flexShrink: 0,
    fill: { default: zinc[400], ':hover': zinc[600] },
  },
});
```
