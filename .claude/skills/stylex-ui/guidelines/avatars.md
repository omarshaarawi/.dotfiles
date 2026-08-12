# Avatars

Covers: profile photos, user thumbnails, testimonial people, comments, team members, and overlapping avatar groups.

- See [Assets API](./assets-api.md) for avatar URLs and query parameters
- Prefer extension-suffixed avatar URLs such as `/avatars/1.webp`
- Give avatars a hairline edge rather than a border — on light surfaces use a `1px` outline
  at 5–10% black with a `-1px` offset so it sits inside the image; on dark surfaces use white at 10%
- Give stacked/overlapping avatar groups a 2px ring that matches the background color, so
  each avatar cuts a clean hole in the one behind it

```ts
const styles = stylex.create({
  avatar: {
    borderRadius: radius.full,
    outlineWidth: '1px',
    outlineStyle: 'solid',
    outlineOffset: '-1px',
    outlineColor: {
      default: `color-mix(in oklab, ${base.black} 5%, transparent)`,
      [media.dark]: `color-mix(in oklab, ${base.white} 10%, transparent)`,
    },
  },
  stacked: {
    boxShadow: { default: `0 0 0 2px ${base.white}`, [media.dark]: `0 0 0 2px ${zinc[900]}` },
    marginInlineStart: `calc(${space[2]} * -1)`,
  },
});
```
