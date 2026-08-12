# StyleX UI Guidelines

Use this when designing or building UI with the top-level `stylex-ui` skill, or when a
workflow tells you to load design guidance before editing StyleX UI code.

## Load Contract

- Before writing UI code, read [StyleX Authoring](./guidelines/stylex-authoring.md). It is
  always in scope — every rule file below assumes it.
- Then scan the rule-file index and load every rule file that could apply.
- Err on the side of loading too many rule files rather than too few.
- Treat rules as applicable even when indirect: heading group rules apply to hero sections;
  landing page rules apply to individual page sections; surface rules apply to dashboard
  cards and list items.
- Load reference modules only when the request needs that reference material.
- Before hand-writing CSS behavior, check the primitive table in
  [StyleX Authoring](./guidelines/stylex-authoring.md). Overlays, animations, view
  transitions, and themeable values each have a StyleX primitive, and the rule files above
  assume you are using it rather than reimplementing it.

## Token Layer

Every numeric value in these rules refers to a token in [tokens/](./tokens/), which mirrors
Tailwind's default theme. `space[3]` is the `0.75rem` Tailwind computes for `p-3`.

Most tokens are `defineConsts` and inline at build time. `tokens/theme.stylex.ts` holds the
small `defineVars` group for values that must animate or be overridden at runtime; see
[Theming](./guidelines/theming.md).

Confirm the project has a token layer before writing styles. If it does not, scaffold from
[tokens/README.md](./tokens/README.md). Never hand-write a value a token already holds.

## General Design Principles

- Every layout must adapt from mobile to desktop — see
  [Responsive Design](./guidelines/responsive-design.md)
- Body text, controls, and icons are larger on mobile and scale down at `media.sm`. Headings
  are the exception
- Reach for the lightest surface treatment that works: whitespace, then dividers, then cards

## Rule Files

- [Anchoring & Overlays](./guidelines/anchoring.md) — popovers, dropdowns, menus, tooltips, and anchor positioning with `stylex.positionTry`
- [Animation](./guidelines/animation.md) — keyframe animations, entrance and exit motion, easing, and reduced-motion handling
- [Atoms](./guidelines/atoms.md) — `@stylexjs/atoms` for one-off inline styles, and when a named style is better
- [Avatars](./guidelines/avatars.md) — profile photos, user thumbnails, and people images in testimonials, team sections, comments
- [Badges](./guidelines/badges.md) — badges, tags, pills, status indicators, labels, and chips with or without icons
- [Border Radius](./guidelines/border-radius.md) — rounding cards, containers, buttons, images, screenshots, and concentric nested radii
- [Buttons](./guidelines/buttons.md) — primary and secondary buttons, CTAs, icon buttons, destructive actions, and touch targets
- [Colors](./guidelines/colors.md) — brand colors, accent colors, palette selection, and default color families
- [Component API](./guidelines/component-api.md) — how components accept, restrict, and merge caller styles; `StyleXStyles<>` contracts and `props` vs `attrs`
- [Copywriting](./guidelines/copywriting.md) — punctuation, headings, taglines, subtitles, descriptions, and list items
- [Custom Fonts](./guidelines/custom-fonts.md) — loading fonts, registering font tokens, feature and variation settings
- [Dark Mode](./guidelines/dark-mode.md) — dark theming, contrast, the media-condition vs `createTheme` decision, cards, shadows, images, and SVGs
- [Dashboards](./guidelines/dashboards.md) — dashboard layouts, stat grids, KPI cards, metric cards, admin panels, and analytics views
- [Description Lists](./guidelines/description-lists.md) — `<dl>`/`<dt>`/`<dd>` styling, term/detail contrast and weight hierarchy
- [Feature Lists](./guidelines/feature-lists.md) — feature grids, benefit lists, and sections listing features with titles and descriptions
- [Flexbox Layout](./guidelines/flexbox-layout.md) — flex containers, `minWidth: 0` shrinking, `flexShrink: 0` on icons, sidebar + content patterns
- [Footers](./guidelines/footers.md) — page footers, footer logos, footer links, and social media icons
- [Form Controls](./guidelines/form-controls.md) — inputs, selects, checkboxes, radios, toggles, search bars, auth and checkout forms
- [Headers](./guidelines/headers.md) — site headers, navigation bars, logos, mobile menus, and hamburger menus
- [Heading Groups](./guidelines/heading-groups.md) — headline, subheadline, and eyebrow at the top of marketing sections; per-size measure table
- [Icons](./guidelines/icons.md) — SVG icons, sizing, alignment with text, filled vs stroked, and inline list icons
- [Images](./guidelines/images.md) — photos, thumbnails, screenshots, app mockups, and image edges
- [Interactivity](./guidelines/interactivity.md) — hover states, transitions, animation, and reduced motion
- [Landing Pages](./guidelines/landing-pages.md) — full-page consistency across buttons, fonts, containers, radii, and column gaps
- [Login Pages](./guidelines/login-pages.md) — login, sign-in, sign-up, and authentication page backgrounds and layout
- [Logo Clouds](./guidelines/logo-clouds.md) — logo grids, client logo rows, partner logos, and trust bars
- [Navigation](./guidelines/navigation.md) — sidebar nav, header nav, mobile menus, tabs, active states, and current-page indicators
- [Pagination](./guidelines/pagination.md) — page number links, previous/next buttons, and paged navigation
- [Placeholder Content](./guidelines/placeholder-content.md) — dummy logos, avatars, screenshots, wallpapers, and the assets API
- [Pricing Cards](./guidelines/pricing-cards.md) — pricing tiers, plan cards, emphasized plans, and button alignment across columns
- [Prose Content](./guidelines/prose-content.md) — styling raw HTML from markdown or a CMS, where StyleX cannot reach individual elements
- [Responsive Design](./guidelines/responsive-design.md) — breakpoints, container queries, and mobile-to-desktop adaptation
- [Section Layout](./guidelines/section-layout.md) — left-aligned vs centered sections, width constraints, and aligning stacked sections
- [Shadows](./guidelines/shadows.md) — shadows on cards, modals, popovers, and the ring-composition rule
- [Surfaces](./guidelines/surfaces.md) — cards, wells, borders, dividers, and whitespace; choosing the lightest separation that works
- [SVG](./guidelines/svg.md) — inline SVG, `fill`/`stroke` styling, and SVG markup conventions
- [Tables](./guidelines/tables.md) — data tables, headings, row dividers, and horizontally scrolling table containers
- [Team Sections](./guidelines/team-sections.md) — team grids, member cards, staff listings, and people galleries
- [Testimonials](./guidelines/testimonials.md) — customer quotes, social proof, hanging punctuation, and attribution layout
- [Theming](./guidelines/theming.md) — runtime themes, typed animatable variables, `createTheme`, and when a value must be a var not a const
- [Typography](./guidelines/typography.md) — sizes, paired line heights, weights, tracking, measure, and text wrapping
- [View Transitions](./guidelines/view-transitions.md) — route transitions, shared-element morphs, and `stylex.viewTransitionClass`

## Always In Scope

- [StyleX Authoring](./guidelines/stylex-authoring.md) — `stylex.create`, composition,
  conditional values, media queries, `stylex.when.*`, dynamic styles, and the token layer.
  Read before writing any StyleX.

## Reference Modules

Load these only when the request needs the reference:

- [Translation](./guidelines/translation.md) — Tailwind class to StyleX lookup table. Load when porting a Tailwind UI, or when another rule cites a class you need to express
- [Assets API](./guidelines/assets-api.md) — placeholder asset URLs, query parameters, and examples
- [Font Recommendations](./guidelines/font-recommendations.md) — font suggestions, sourcing notes, and feature settings

## Design Conflicts

When a rule says **⚠️ ask-user**, the user's input conflicts with a design guideline. Do not
silently override the user, and do not silently follow their request. Instead:

1. Use the `AskUserQuestion` tool to flag the conflict
2. Explain what the guideline recommends and why the input doesn't fit
3. Offer a concrete alternative (a rewritten version of their copy, a different layout)
4. Wait for the user to choose before proceeding

Never skip this, even if it feels minor.
