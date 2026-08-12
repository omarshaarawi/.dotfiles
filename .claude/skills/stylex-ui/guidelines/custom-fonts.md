# Custom Fonts

Covers: loading custom fonts, registering font tokens, and applying display/body font stacks.

- Always load a custom font before using it. Add `<link>` tags in the document `<head>`;
  fall back to `@import url('…')` at the top of a CSS file only when no `<head>` is reachable
- Register font stacks as consts in the token layer next to `font.sans`, so a font swap is
  one edit rather than a search across components
- Keep body and display fonts as separate tokens — `font.sans` for body and UI, a
  `font.display` for headline-only faces. Apply the display stack on headings and let the
  body stack cascade everywhere else
- Set `fontFeatureSettings` and `fontVariationSettings` alongside the stack when the face
  needs tuning. For Inter, enable `cv02`, `cv03`, `cv04`, `cv11`, `ss01`, `ss03`
- Always use `font-display: swap` in the `@font-face` rule so text renders before the font
  arrives

```ts
// tokens/scale.stylex.ts
export const font = stylex.defineConsts({
  sans: "'InterVariable', -apple-system, BlinkMacSystemFont, sans-serif",
  display: "'Oswald', 'InterVariable', sans-serif",
});
```
