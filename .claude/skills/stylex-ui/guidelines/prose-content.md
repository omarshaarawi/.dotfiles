# Prose Content

Covers: raw HTML from markdown, CMS content, database content, blog posts, articles, documentation, and rendered markup where styles cannot be applied per element.

StyleX styles elements you control. Rendered HTML from markdown or a CMS has no props to
spread onto, so it needs plain CSS — this is the one place in a StyleX codebase where a
stylesheet is the right answer.

- Write a `.prose` class in a plain CSS file that styles the raw elements, and apply it to
  the container holding the rendered HTML
- Drive that CSS from the same tokens. Import the token file for its side effect and
  reference the generated variables, or keep a small `defineVars` group for the values prose
  needs, so prose never forks from the rest of the design system
- Style every element that can appear: `h1`–`h6`, `p`, `a`, `ul`, `ol`, `li`, `pre`, `code`,
  `img`, `strong`, `blockquote`
- Use `* + *` for vertical rhythm rather than margins on every element
- Default prose body text to 16px. Only go to 18px if requested or if the project already
  uses that size for body copy elsewhere
- Never set `max-width` inside the `.prose` CSS. Constrain measure at the call site with a
  `ch` max-width, between `60ch` and `90ch`, matched to the site's existing content widths
- Set prose line height to at least 1.75× the font size
- Use `textWrap: 'pretty'` on article titles, not `balance`
- When the article title uses a sans-serif, use the same sans for all subheadings. Never mix
  a sans title with serif subheadings
