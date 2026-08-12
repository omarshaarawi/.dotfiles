# Testimonials

Covers: customer quotes, reviews, social proof sections, testimonial cards, quote punctuation, avatars, and attribution.

## Design Rules

- Use hanging punctuation for quotes so the opening quote mark sits outside the measure and
  the text edge stays flush. This is the fair exception to preferring real elements over
  pseudo-elements — a decorative glyph is not content
- Always bottom-align avatars and names across equal-height cards:
  `display: 'flex', flexDirection: 'column', justifyContent: 'space-between'` on each card,
  with quote and attribution in their own wrappers
- Never add whitespace inside the quote's `<p>`. Write `<p>The quote text</p>`, not
  `<p> The quote text </p>` — leading whitespace breaks the hanging punctuation
- Follow [Avatars](./avatars.md) and [Placeholder Content](./placeholder-content.md) for photos
- Use unisex names — placeholder avatars are random, so names must work for any photo

```ts
const styles = stylex.create({
  quote: {
    position: 'relative',
    '::before': { content: '"\\201C"', position: 'absolute', transform: 'translateX(-100%)' },
    '::after': { content: '"\\201D"' },
  },
  mark: { color: { default: zinc[200], [media.dark]: `color-mix(in oklab, ${base.white} 5%, transparent)` } },
});
```
