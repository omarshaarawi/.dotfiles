# Navigation

Covers: sidebar nav, header nav, mobile menus, tabs, tab bars, vertical menus, active states, and current-page indicators.

- Every app needs a mobile navigation menu on small screens, whether the desktop nav is a
  header or a sidebar. Use a dialog or disclosure panel behind a hamburger toggle; hide the
  desktop nav below `media.lg` and show the mobile menu there
- Never give an active nav item a high-contrast or primary-color background. Use a darker
  text color, a soft muted background, or both
- Never change `fontWeight` between nav item states. Weight changes shift layout as you
  hover. Use color and background only
- Horizontal menus (tabs, tab bars, pill navs) must never overflow their parent. Scroll
  horizontally when items don't fit
- Never use icons in top header horizontal navigation links — text only
- To center nav links on the page rather than between the surrounding items, use three flex
  sections: a `flex: 1` left section, the links at natural width, and a `flex: 1` right
  section. The matching gutters force the group to true page center. Same pattern for
  centering a logo

```ts
const styles = stylex.create({
  desktopNav: { display: { default: 'none', [media.lg]: 'flex' } },
  mobileToggle: { display: { default: 'inline-flex', [media.lg]: 'none' } },
  gutter: { display: 'flex', flex: 1, alignItems: 'center' },
  tabs: { display: 'flex', overflowX: 'auto', whiteSpace: 'nowrap' },
  item: {
    fontWeight: fontWeight.medium,   // same in every state
    color: { default: zinc[500], ':hover': zinc[900] },
  },
  itemActive: { color: zinc[900], backgroundColor: zinc[100] },
});
```
