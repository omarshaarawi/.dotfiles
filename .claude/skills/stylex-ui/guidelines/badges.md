# Badges

Covers: badges, tags, pills, labels, chips, status indicators, and compact metadata with icons.

- Badges with a leading or trailing icon must not use symmetric inline padding. Set the
  icon side's padding equal to the vertical padding so the icon isn't stranded in whitespace:
  `paddingBlock: space[1]`, then `paddingInlineStart: space[1], paddingInlineEnd: space[2]`
  for a leading icon, and the reverse for a trailing one

```ts
const styles = stylex.create({
  badge: {
    display: 'inline-flex',
    alignItems: 'center',
    gap: space[1],
    paddingBlock: space[1],
    paddingInline: space[2],
    borderRadius: radius.md,
    fontSize: text.xs,
    lineHeight: leadingFor.xs,
  },
  withLeadingIcon: { paddingInlineStart: space[1] },
  withTrailingIcon: { paddingInlineEnd: space[1] },
});
```
