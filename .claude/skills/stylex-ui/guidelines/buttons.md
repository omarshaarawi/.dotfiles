# Buttons

Covers: primary buttons, secondary buttons, CTAs, icon buttons, destructive actions, form actions, and touch targets.

## Design Rules

- Follow [Shadows](./shadows.md) when adding a shadow — never pair one with a solid gray
  border; use a ring composed into the same `boxShadow` string
- A primary button's ring must be a solid color matching its background, never a
  reduced-opacity black. A `blue[600]` button gets a `blue[600]` ring
- Dangerous actions like "Delete" use a secondary/muted style by default. Only make one
  primary when it is the primary action on that page or dialog (a confirm-delete dialog)
- Only one primary button per page. Scan the whole page: every other button must be
  secondary — soft, outline, or ghost. Treat a dialog as its own page
- Never make a secondary button higher contrast than the primary
- Any button that is not the page's primary submit action is an inline form action — change
  avatar, upload file, generate password, resend code. These always use the smaller size and
  a secondary style, and must never match the height of the form's submit button

## Sizing

- Use less horizontal padding than feels natural — `paddingInline: space[3]` with
  `paddingBlock: space[2]`, not `space[4]`
- Application UIs use `text.sm` with compact padding, never `text.base`. Total rendered
  height, including any ring, stays within 28–38px
- Maximum two button sizes per application UI, and they must differ by at least 6px
- Buttons with a leading or trailing icon never use symmetric inline padding. Set the icon
  side equal to the vertical padding: `paddingBlock: space[2]`, then
  `paddingInlineStart: space[2], paddingInlineEnd: space[3]` for a leading icon

## Focus

- Solid buttons need an explicit focus ring: `outlineWidth: '2px'` and
  `outlineOffset: '2px'` under `':focus-visible'`. Default to `blue[500]` when the project
  has no established focus color

## Touch Targets

Small and icon-only buttons must still hit 48×48px. StyleX has no `::after` sizing utility
worth the bundle cost here, so give the button `position: 'relative'` and render a real
`<span aria-hidden>` child that expands the hit area on coarse pointers only.

```ts
const styles = stylex.create({
  base: {
    display: 'inline-flex',
    alignItems: 'center',
    gap: space[2],
    paddingBlock: space[2],
    paddingInline: space[3],
    borderRadius: radius.md,
    fontSize: text.sm,
    lineHeight: leadingFor.sm,
    fontWeight: fontWeight.medium,
    outlineWidth: { default: 0, ':focus-visible': '2px' },
    outlineStyle: 'solid',
    outlineColor: blue[500],
    outlineOffset: '2px',
  },
  primary: {
    backgroundColor: { default: blue[600], ':hover': blue[700] },
    color: base.white,
    boxShadow: `${shadow.xs}, 0 0 0 1px ${blue[600]}`,
  },
  secondary: {
    backgroundColor: { default: base.white, ':hover': zinc[50] },
    color: zinc[900],
    boxShadow: `${shadow.xs}, 0 0 0 1px color-mix(in oklab, ${zinc[950]} 10%, transparent)`,
  },
  hitArea: {
    position: 'absolute',
    insetInlineStart: '50%',
    insetBlockStart: '50%',
    width: 'max(100%, 3rem)',
    height: 'max(100%, 3rem)',
    transform: 'translate(-50%, -50%)',
    display: { default: 'block', [media.pointerFine]: 'none' },
  },
});
```
