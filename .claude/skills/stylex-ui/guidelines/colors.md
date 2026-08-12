# Colors

Covers: brand colors, accent colors, neutral palettes, text colors, and default color families.

- Never default to indigo as the brand/accent color — only use indigo if the project already
  uses it or the user explicitly requests it
- Never default to `gray` or `slate` for neutral/text colors — only use them if the project
  already uses them or the user explicitly requests it; prefer `zinc` or `neutral` instead
- Import ramps from `tokens/palette.stylex.ts`. Never hand-write a hex or `oklch()` that a
  ramp step already holds
- Pick the brand ramp once and alias it at the top of the module rather than repeating the
  family name at every use site — swapping brands should be one edit

```ts
import { zinc, blue } from '@/tokens/palette.stylex';

const brand = blue;   // one edit to reskin
```
