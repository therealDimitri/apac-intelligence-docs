# Bug Report: PDF Export Formatting Issues and UI Modernisation

**Date Reported:** 2026-01-21
**Date Fixed:** 2026-01-21
**Severity:** Medium
**Status:** Fixed

## Summary

PDF exports from the Account Planning page had multiple formatting issues and needed UI modernisation:
1. Stakeholder Intelligence matrix showed only first names instead of full names
2. Role column showed snake_case format (e.g., `economic_buyer` instead of "Economic Buyer")
3. Status column showed snake_case format (e.g., `not_started` instead of "Not Started")
4. ARR and Health data weren't being calculated correctly from portfolio data
5. Overall UI styling needed modernisation

## Symptoms

- Power/Interest Matrix showed truncated names like "Sarah", "John", "Dr." instead of full names
- Stakeholder Directory Role column displayed `economic_buyer`, `technical_buyer`, `blocker`
- Action tables displayed `not_started` status with underscore
- Cover page showed ARR: $0 and Health: N/A despite data existing in portfolio
- Account Profile page showed $0 ARR for all products

## Root Cause

1. **Stakeholder names**: The quadrant drawing code was intentionally splitting names and only showing the first part:
   ```typescript
   const displayName = truncateText(s.name.split(' ')[0], 10)
   ```

2. **Role/Status formatting**: No formatter was applied to convert snake_case database values to display-friendly Title Case format.

3. **ARR/Health calculation**: The code only checked for `c.arr` field, but portfolio data could use different field names like `ARR`, `revenue`, `current_arr`, or `annualRecurringRevenue`.

## Fix Applied

### 1. Added formatting helper functions to `src/lib/pdf/altera-branding.ts`:

```typescript
// Convert snake_case to Title Case
export function formatSnakeCaseToTitleCase(text: string): string {
  if (!text) return ''
  return text
    .replace(/[_-]/g, ' ')
    .replace(/\b\w/g, char => char.toUpperCase())
}

// Format role values with specific mappings
export function formatRole(role: string): string {
  const roleMap = {
    'economic_buyer': 'Economic Buyer',
    'technical_buyer': 'Technical Buyer',
    // ... etc
  }
  return roleMap[role.toLowerCase()] || formatSnakeCaseToTitleCase(role)
}

// Format status values with specific mappings
export function formatStatus(status: string): string {
  const statusMap = {
    'not_started': 'Not Started',
    'in_progress': 'In Progress',
    // ... etc
  }
  return statusMap[status.toLowerCase()] || formatSnakeCaseToTitleCase(status)
}
```

### 2. Updated `src/lib/pdf/account-plan-pdf.ts`:

- Changed stakeholder quadrant to show full names (truncated at 18 chars instead of first name only)
- Applied `formatRole()` to stakeholder directory table
- Applied `formatStatus()` to action tables (Executive Summary and Action Plan pages)
- Modernised section headers with background, page number badges
- Enhanced KPI badges with shadow effects and top accent stripes
- Improved "No data available" message with info icon styling

### 3. Updated `src/app/api/planning/export/route.ts`:

- Enhanced ARR calculation to check multiple possible field names
- Added average health score calculation from portfolio clients
- Improved products transformation to handle various field name formats

## Files Changed

- `src/lib/pdf/altera-branding.ts` - Added `formatSnakeCaseToTitleCase`, `formatRole`, `formatStatus` helpers
- `src/lib/pdf/account-plan-pdf.ts` - Applied formatters, enhanced UI styling
- `src/app/api/planning/export/route.ts` - Improved data extraction for ARR/health

## Testing Performed

1. Exported PDF from the planning page "My Plans" section (VIC, WA plan at 100%)
2. Verified:
   - Cover page shows Health: 33, ARR: $3.5M (previously N/A and $0)
   - Stakeholder quadrant shows full names: "Sarah Chen", "John Smith", etc.
   - Role column shows: "Economic Buyer", "Champion", "Technical Buyer", "Blocker", "Supporter"
   - Status column shows: "Not Started" (not `not_started`)
   - All methodology pages (Gap Selling, MEDDPICC, StoryBrand) display content
   - Modernised section headers with page number badges

## UI Improvements Made

1. **Section Headers**: Added light grey background, rounded corners, page number in coloured badge
2. **KPI Badges**: Added shadow effect, top accent stripe, larger values
3. **No Data Messages**: Added info icon circle, better spacing and styling
4. **Typography**: Adjusted font sizes for better hierarchy

## Lessons Learned

1. Database values often use snake_case while UI should display Title Case - always add formatters
2. When extracting data from external sources, check multiple possible field names
3. PDF generation should include formatters at the rendering layer, not rely on data being pre-formatted

## Related Files

- `src/app/(dashboard)/planning/page.tsx` - Export handler
- `src/app/api/planning/export/route.ts` - Export API route with data transformation
- `src/lib/pdf/account-plan-pdf.ts` - PDF generator
- `src/lib/pdf/altera-branding.ts` - Brand constants and helper functions

## Commit

`fix: PDF export formatting (snake_case roles/status, full names, ARR/health, modernised UI)`
