# Typography

Covers: text sizes, line heights, heading styles, font weights, tracking, text width, text wrapping, and eyebrow text.

## Design Rules

- Never use `text.xs` for body text, paragraph text, or general page content. The smallest
  acceptable body size is `text.sm`, and only at `media.sm` or larger — the mobile default
  must be at least `text.base` (16px)
- Never use `fontWeight.bold` for headings — use `semibold` or `medium`
- Never set a custom `lineHeight` on headings. Use the paired `leadingFor` value for the size
- Use `textWrap: 'balance'` on headings and `textWrap: 'pretty'` on paragraph text
- Add `letterSpacing: tracking.tight` to headings larger than `text.xl`, unless the font is
  a condensed headline face where tracking is already tight
- Never uppercase eyebrow text unless it is monospace; when it is, add `tracking.wide`

## Coding Rules

- Always set `fontSize` and `lineHeight` together. Tailwind's `text-sm` carries an implied
  line height; `fontSize: text.sm` alone inherits whatever the parent had, which is a silent
  regression rather than a visible one
- Constrain measure with a `ch` max-width on the element itself — see
  [Heading Groups](./heading-groups.md) for the value per size
- Never put font size or line height on an inline element (`<span>`, `<a>`, `<strong>`,
  `<em>`, `<code>`). Put them on the containing block element
- Use the official Inter variable font with `font-display: swap`, and enable its OpenType
  features via `fontFeatureSettings` (`cv02`, `cv03`, `cv04`, `cv11`, `ss01`, `ss03`).
  See [Custom Fonts](./custom-fonts.md)

```ts
const styles = stylex.create({
  h2: {
    fontSize: text['4xl'],
    lineHeight: leadingFor['4xl'],
    fontWeight: fontWeight.semibold,
    letterSpacing: tracking.tight,
    textWrap: 'balance',
    maxWidth: '35ch',
  },
  body: {
    fontSize: { default: text.base, [media.sm]: text.sm },
    lineHeight: { default: leadingFor.base, [media.sm]: leadingFor.sm },
    textWrap: 'pretty',
    maxWidth: '65ch',
  },
});
```
