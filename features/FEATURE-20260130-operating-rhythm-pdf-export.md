# Feature: Operating Rhythm PDF Export

**Date:** 30 January 2026
**Status:** Implemented (v3 - Altera Branding)
**Location:** `/operating-rhythm` page → "Full Doc" button

---

## Overview

Added PDF export functionality to the 2026 Operating Rhythm page. The "Full Doc" button now generates and downloads a professionally branded PDF document instead of linking to the raw markdown file.

**v3 Update:** Applied official Altera branding guidelines with logo and colour palette from `altera-branding.ts`.

**v2 Update:** Rebuilt with `@react-pdf/renderer` for modern, Stripe/Linear-inspired styling with SVG gradients, custom fonts, and refined visual design.

---

## Implementation Details

### Files Created

| File | Purpose |
|------|---------|
| `src/lib/pdf/operating-rhythm-react-pdf.tsx` | React-PDF document (v2 - current) |
| `src/lib/pdf/operating-rhythm-pdf.ts` | Original jsPDF generator (v1 - deprecated) |
| `src/app/api/operating-rhythm/export/route.ts` | API endpoint to serve PDF |

### Files Modified

| File | Change |
|------|--------|
| `src/app/(dashboard)/operating-rhythm/page.tsx` | Updated "Full Doc" button to download PDF |
| `package.json` | Added `@react-pdf/renderer` dependency |

---

## PDF Structure

The generated PDF includes:

1. **Cover Page** - Gradient header, Altera branding, document title, metric cards
2. **Strategic Context** - Purpose statement, business imperatives table, strategic priorities
3. **Annual Calendar Overview** - Four quarter boxes with event summaries
4. **Quarter Detail Pages (Q1-Q4)** - Event cards with:
   - Gradient accent bar at top
   - Event name and dates
   - Participants
   - Objective (italicised)
   - Deliverables (bulleted)
   - Key milestones (when applicable)
   - Colour-coded per quarter
5. **Segmentation Framework** - Segment definitions and activity register tables
6. **Tools & Resources** - Dashboard modules and key contacts

---

## Technical Notes

### PDF Generation (v3)

- Uses `@react-pdf/renderer` for declarative React components
- SVG-based gradient headers via `<Svg>`, `<LinearGradient>`, `<Stop>`
- Custom Montserrat font embedded from Google Fonts CDN (v31)
  - Registered weights: 400, 400 italic, 500, 600, 700
  - Italic variant required for objective text styling
- Flexbox layout for responsive card designs
- Official Altera colour palette from `altera-branding.ts`
- Altera logo embedded via `<Image>` component (URL reference)

### API Endpoint

```typescript
GET /api/operating-rhythm/export
Response: application/pdf (binary)
Auth: Required (middleware protected)
```

### Button Implementation

```tsx
<a
  href="/api/operating-rhythm/export"
  download="2026-CS-Operating-Rhythm.pdf"
  className="..."
>
  <Download className="w-4 h-4 inline mr-1.5" />
  Full Doc
</a>
```

---

## Design System (v3 - Altera Branding)

### Colour Palette (Official Altera Brand)

| Category | Colour | Hex | Source |
|----------|--------|-----|--------|
| Primary Deep | Altera Dark Purple | `#151744` | `AlteraBrand.purple.dark` |
| Primary Main | Altera Purple | `#393391` | `AlteraBrand.purple.primary` |
| Primary Light | Altera Light Purple | `#4c47c3` | `AlteraBrand.purple.light` |
| Primary Gradient | Altera Gradient Purple | `#707cf1` | `AlteraBrand.purple.gradient` |
| Accent | Altera Coral | `#f46e7b` | `AlteraBrand.coral.primary` |
| Q1 | Blue-500 | `#3b82f6` | Quarter accent |
| Q2 | Amber-500 | `#f59e0b` | Quarter accent |
| Q3 | Violet-500 | `#8b5cf6` | Quarter accent |
| Q4 | Pink-500 | `#ec4899` | Quarter accent |

### Cover Page Logo

- **Logo:** Altera logomark (reversed/white version)
- **URL:** `https://apac-cs-dashboards.com/images/Altera_logo_rgb_logomark_rev.png`
- **Size:** 140×50px, centered in gradient header

### Typography

- **Font:** Montserrat (400, 400 italic, 500, 600, 700 weights)
- **Cover Title:** 36pt bold
- **Cover Year:** 72pt bold, light purple
- **Page Headers:** 20pt bold, deep purple
- **Section Titles:** 12pt semibold, main purple
- **Body Text:** 9pt regular, slate-700

### Design Inspirations

- **Stripe:** Clean metric cards, generous whitespace
- **Linear:** Minimal borders, gradient accents, refined typography
- **Notion:** Subtle table styling, soft alternating rows

---

## Design Decisions

1. **React-PDF over jsPDF** - Better SVG support for gradients, cleaner component architecture
2. **Montserrat font** - Altera brand typeface, embedded from Google Fonts v31
3. **SVG Gradient Headers** - Modern, polished appearance for cover and quarter pages
4. **Slate Neutrals** - Less harsh than pure grays, better readability
5. **Coral Accent** - Official Altera coral (`#f46e7b`) for warm contrast
6. **Generous Whitespace** - Executive-friendly, scannable layout
7. **Official Altera Logo** - Reversed logomark on gradient header for brand consistency
8. **Brand Colour Import** - Colours sourced from `altera-branding.ts` for consistency across all PDF exports

---

## Testing

### v3 (Altera Branding)
- Build: Passed (`npm run build`)
- TypeScript: Passed (no errors)
- Deployment: Netlify deploy successful (commit b857b120)
- PDF size: 116,983 bytes
- PDF validated: Valid %PDF-1.3 header
- Logo: Altera logomark renders correctly on cover page
- Colours: Official Altera purple palette applied

### v2 (React-PDF)
- Build: Passed (`npm run build`)
- TypeScript: Passed (no errors)
- Deployment: Netlify deploy successful (commit dddceb91)
- Endpoint: Responds with 307 redirect for unauthenticated requests (correct behaviour)

### v1 (jsPDF - deprecated)
- Build: Passed (commit 7deb20f9)

---

## Related Files

- Design spec: `docs/plans/2026-CS-OPERATING-RHYTHM-VISUAL-DESIGN.md`
- Source document: `docs/2026-CS-OPERATING-RHYTHM.md`
- Branding utilities: `src/lib/pdf/altera-branding.ts`
