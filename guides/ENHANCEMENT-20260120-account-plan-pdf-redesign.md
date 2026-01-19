# Enhancement Report: Account Plan PDF Export Redesign

**Date**: 2026-01-20
**Type**: Enhancement
**Status**: Implemented
**Commits**: `c1f8ad4f`, `9ea77034`

## Summary

Implemented a comprehensive redesign of the Account Plan PDF export to transform it from a sparse, data-dump style report into a compelling, executive-ready strategic document with Altera Digital Health branding.

## Problem Statement

The previous PDF export for Account Plans was:
- Sparse with minimal content (only actions table)
- No visual hierarchy or data visualisation
- Missing financial plan, methodology scores, stakeholder map
- No narrative structure connecting insights to strategy
- Lacked executive summary and KPI dashboard
- Did not use Altera corporate branding

## Solution Implemented

### New Features

1. **Altera Branding Integration**
   - Official colours from logo files: Purple (#393391), Coral (#f46e7b)
   - Montserrat font embedded for consistent typography
   - Professional cover page with branding elements

2. **Enhanced PDF Structure (up to 10 pages)**
   - Cover page with KPI badges (Health Score, ARR, NPS)
   - Executive summary dashboard with progress bars
   - Account profile with product footprint
   - Stakeholder intelligence map
   - Financial plan with revenue breakdown
   - Gap Selling analysis (current/future state)
   - MEDDPICC qualification scorecard
   - Risk assessment with accusation audits
   - StoryBrand narrative framework
   - Action plan with priority actions

3. **Visual Elements**
   - KPI badge cards with colour-coded status
   - Progress bars for revenue targets
   - Colour-coded MEDDPICC element scores
   - Risk severity indicators
   - Status indicators throughout

### Files Changed

**New Files:**
- `src/lib/pdf/altera-branding.ts` - Altera brand constants, colours, typography
- `src/lib/pdf/account-plan-pdf.ts` - Enhanced PDF generator class
- `src/lib/pdf/index.ts` - Module exports
- `public/fonts/Montserrat-*.ttf` - Font files (Regular, Medium, SemiBold, Bold)
- `public/images/Altera_logo_rgb_logomark*.png` - Logo files
- `docs/designs/ACCOUNT_PLAN_PDF_REPORT_DESIGN.md` - Design specification

**Modified Files:**
- `src/app/api/planning/export/route.ts` - Added enhanced PDF generator integration

### API Changes

The export API now accepts an optional `enhanced` parameter:

```typescript
POST /api/planning/export
{
  planType: 'account',
  planId: 'uuid',
  format: 'pdf',
  sections: ['all'],
  includeBranding: true,
  enhanced: true  // NEW: Defaults to true for account plans
}
```

- `enhanced: true` (default for account plans) - Uses new comprehensive layout
- `enhanced: false` - Uses legacy PDF format

## Technical Details

### Brand Colours (from official Altera logo SVG)

| Colour | Hex | Usage |
|--------|-----|-------|
| Altera Purple (Primary) | #393391 | Headers, section titles |
| Altera Purple Light | #4c47c3 | Secondary headers, gradients |
| Altera Coral (Accent) | #f46e7b | Call to action, highlights |
| Altera Navy (Dark) | #151744 | Dark backgrounds, footer |

### Typography

All text uses Montserrat font family:
- H1: 24pt Bold
- H2: 18pt SemiBold
- H3: 14pt Medium
- Body: 10pt Regular
- Table: 9pt Regular
- Caption: 8pt Regular

### Implementation Notes

1. The enhanced PDF generator transforms existing plan data structures to a normalised format
2. Sections are conditionally rendered based on available data
3. All TypeScript types are properly handled with explicit any casts where needed
4. The generator uses jsPDF with autoTable plugin for tables

## Testing

- Build: ✓ Passed
- Pre-commit checks: ✓ Passed (ESLint, TypeScript, Prettier)
- Deployment: Automatically deployed via Netlify

## Future Enhancements

1. Add radar chart for MEDDPICC scores
2. Add Gantt timeline for action plan
3. Embed Altera logo image in cover page
4. Add risk heat map visualisation
5. Add quarterly financial forecast table
