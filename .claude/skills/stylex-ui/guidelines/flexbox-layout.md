# Flexbox Layout

Covers: flex containers, flexible children, fixed-size icons/images, truncation, sidebars, and layouts using `flex: 1`.

- Always set `minWidth: 0` on a flex child that needs to shrink below its content size.
  Flex items default to `min-width: auto` and will not shrink past their content without
  it. This applies at every scale, from a fluid content area beside a fixed sidebar down to
  a truncated label in a row. It is the single most common cause of a layout that overflows
  its container with no obvious culprit
- Always set `flexShrink: 0` on flex children that must never shrink — icons, SVGs, images,
  logos, avatars, and anything that would distort under compression
- Use `gap` on the parent for spacing between flex and grid children, never margins on the children

```ts
const styles = stylex.create({
  row: { display: 'flex', alignItems: 'center', gap: space[3] },
  icon: { flexShrink: 0, width: space[4], height: space[4] },
  label: { minWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' },
});
```
