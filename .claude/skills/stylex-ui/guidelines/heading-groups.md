# Heading Groups

Covers: headline, subheadline, and optional eyebrow groups at the top of marketing or landing page sections.

A heading group is a headline and subheadline (and optional eyebrow) at the top of a
marketing or landing page section — the title and description above a feature grid, team
grid, pricing table, testimonial section, CTA, or hero. These rules apply to promotional
sections only, not to blog posts, articles, documentation, or editorial content.

- Never constrain the width of the heading group *wrapper*. Constrain each text element
  individually with a `ch` max-width on the element itself. A wrapper max-width makes the
  headline and subheadline share one measure, which is wrong for both

| Size | Max width |
|---|---|
| `text.base` | `56ch` |
| `text.lg` | `48ch` |
| `text.xl` | `40ch` |
| `text['2xl']`–`text['3xl']` | `40ch` |
| `text['4xl']` | `35ch` |
| `text['5xl']` | `30ch` |
| `text['6xl']` | `24ch` |
| `text['7xl']` | `20ch` |

- Always use a left-aligned layout when the subheadline exceeds ~120 characters (~3 lines
  when centered)
  - **⚠️ ask-user** if a centered layout is requested but the subheadline exceeds ~120
    characters. Offer a rewritten shorter version; only center if the user accepts it

```ts
const styles = stylex.create({
  group: {},                                    // never a max-width here
  headline: {
    marginInline: 'auto',
    maxWidth: '35ch',
    fontSize: text['4xl'],
    lineHeight: leadingFor['4xl'],
    fontWeight: fontWeight.semibold,
    letterSpacing: tracking.tight,
    textWrap: 'balance',
  },
  sub: {
    marginInline: 'auto',
    marginBlockStart: space[6],
    maxWidth: '48ch',
    fontSize: text.lg,
    lineHeight: leadingFor.lg,
    textWrap: 'pretty',
    color: zinc[600],
  },
});
```
