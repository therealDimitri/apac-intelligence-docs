# Feature: Operating Rhythm PDF Export

**Date:** 30 January 2026
**Status:** Implemented
**Location:** `/operating-rhythm` page → "Full Doc" button

---

## Overview

Added PDF export functionality to the 2026 Operating Rhythm page. The "Full Doc" button now generates and downloads a professionally branded PDF document instead of linking to the raw markdown file.

---

## Implementation Details

### Files Created

| File | Purpose |
|------|---------|
| `src/lib/pdf/operating-rhythm-pdf.ts` | PDF generator class (1060+ lines) |
| `src/app/api/operating-rhythm/export/route.ts` | API endpoint to serve PDF |

### Files Modified

| File | Change |
|------|--------|
| `src/app/(dashboard)/operating-rhythm/page.tsx` | Updated "Full Doc" button to download PDF |
| `src/lib/pdf/index.ts` | Added export for operating-rhythm-pdf |

---

## PDF Structure

The generated PDF includes:

1. **Cover Page** - Altera branding, document title, version info, strategic metrics preview
2. **Strategic Context** - Purpose statement, business imperatives table, strategic priorities
3. **Annual Calendar Overview** - Four quarter boxes with event summaries
4. **Quarter Detail Pages (Q1-Q4)** - Event cards with:
   - Event name and dates
   - Participants
   - Objective (italicised)
   - Deliverables (bulleted)
   - Key milestones (when applicable)
   - Colour-coded accent bars per quarter
5. **Segmentation Framework** - Segment definitions and activity register tables
6. **Tools & Resources** - Dashboard modules and key contacts

---

## Technical Notes

### PDF Generation

- Uses `jsPDF` with `jspdf-autotable` for table layouts
- Follows established Altera branding pattern from `altera-branding.ts`
- Consistent with other PDF exports (Account Plans, ChaSen Reports)

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

## Design Decisions

1. **PDF over Markdown** - Executives prefer formatted documents over raw markdown
2. **Event Card Layout** - Structured, scannable format for busy readers
3. **Colour-coded Quarters** - Q1 Blue, Q2 Amber, Q3 Purple, Q4 Pink for visual navigation
4. **Altera Branding** - Consistent with other executive materials
5. **Page Numbers** - Professional formatting for multi-page documents

---

## Testing

- Build: Passed (`npm run build`)
- ESLint: Passed (all warnings resolved)
- Deployment: Netlify deploy successful (commit 7deb20f9)
- Endpoint: Responds with 307 redirect for unauthenticated requests (correct behaviour)

---

## Related Files

- Design spec: `docs/plans/2026-CS-OPERATING-RHYTHM-VISUAL-DESIGN.md`
- Source document: `docs/2026-CS-OPERATING-RHYTHM.md`
- Branding utilities: `src/lib/pdf/altera-branding.ts`
