# Form Controls

Covers: inputs, selects, textareas, checkboxes, radio buttons, toggles, search bars, checkout forms, auth forms, and input/button combos.

## Design Rules

- Never pair a shadow with a solid gray border on any control. Use a ring —
  `0 0 0 1px color-mix(in oklab, ${zinc[950]} 10%, transparent)` — composed into the same
  `boxShadow` string as the elevation
- Use `container.xs` for compact single-purpose forms (login, sign-up, a single field).
  `container.sm` and wider is too spacious for focused UI
- If an input's font size is below 16px, bump it to `text.base` on mobile. iOS zooms the
  viewport on focus for anything smaller, which reads as a layout bug
- Never use a positive `outlineOffset` on a focus ring for `<input>` or `<textarea>`. Use
  `0`, or inset it with `-1px` when the ring is 2px so it doesn't extend past the element
- Never use the conjoined input + button pattern where the two share a border. Use a gap,
  or nest the button visually inside the input

## Coding Rules

- Always include a `name` on `<input>`, `<select>`, and `<textarea>`
- Every control needs either a `<label>` associated via `id`/`htmlFor`, or an `aria-label`
- Always set an explicit `type` on `<button>` — `submit` inside forms, `button` otherwise
- For checkout and ecommerce forms where a field's purpose is obvious from context, use
  `placeholder` plus `aria-label` instead of a visible label, but keep section headings
  ("Shipping address", "Payment") to group fields
- **Never toggle classes from JavaScript to reflect input state.** Every state below is
  expressed in CSS through `:checked`, `:indeterminate`, `:disabled`, and `stylex.when.*`

## Native Controls

Style native `<input type="checkbox">` and `<input type="radio">` rather than rebuilding
them — they carry keyboard behavior, form participation, and forced-colors support for free.

The pattern: `appearance: 'none'` on the input, the input and its indicator both placed in
a single grid cell so they stack, and the indicator's visibility driven by the input's state
via `stylex.when.siblingBefore(':checked')`.

- Controls should be larger on mobile: `space[5]` by default, `space[4]` at `media.sm`
- To center a control against adjacent text, put `height: '1lh'` and `alignItems: 'center'`
  on a wrapper at the matching font size — never a top margin
- Add `forcedColorAdjust: 'auto'` so Windows high contrast mode renders the real control

```ts
const styles = stylex.create({
  wrapper: { display: 'inline-grid', gridTemplateColumns: '1fr', height: '1lh', alignItems: 'center' },
  input: {
    gridArea: '1 / 1',
    appearance: 'none',
    width: { default: space[5], [media.sm]: space[4] },
    height: { default: space[5], [media.sm]: space[4] },
    borderRadius: radius.sm,
    borderWidth: '1px',
    borderStyle: 'solid',
    borderColor: {
      default: zinc[300],
      ':checked': blue[600],
      ':indeterminate': blue[600],
      ':disabled': zinc[200],
    },
    backgroundColor: {
      default: base.white,
      ':checked': blue[600],
      ':indeterminate': blue[600],
      ':disabled': zinc[100],
    },
    outlineWidth: { default: 0, ':focus-visible': '2px' },
    outlineStyle: 'solid',
    outlineColor: blue[600],
    outlineOffset: '2px',
    forcedColorAdjust: 'auto',
  },
  checkmark: {
    gridArea: '1 / 1',
    pointerEvents: 'none',
    placeSelf: 'center',
    stroke: base.white,
    opacity: { default: 0, [stylex.when.siblingBefore(':checked')]: 1 },
  },
});
```

Render the input first so `siblingBefore` can observe it, and mark it:

```tsx
<span {...stylex.props(styles.wrapper)}>
  <input type="checkbox" name="terms" {...stylex.props(styles.input, stylex.defaultMarker())} />
  <svg viewBox="0 0 14 14" fill="none" {...stylex.props(styles.checkmark)}>
    <path d="M3 8L6 11L11 3.5" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
  </svg>
</span>
```

Radios use the same structure with `borderRadius: radius.full` and a filled dot instead of
a checkmark. Toggles use the same structure with the knob translated on `:checked`.

## Selects

Use a custom chevron so the control looks the same across browsers. Put the `<select>` and
the chevron in one grid cell, give the select `appearance: 'none'` and trailing padding for
the chevron, and set `pointerEvents: 'none'` on the icon. Wrap only the select and chevron —
never the label.
