# Bug Report: PDF Export Missing Methodology Data

**Date Reported:** 2026-01-21
**Date Fixed:** 2026-01-21
**Severity:** High
**Status:** Fixed

## Summary

PDF exports from the Account Planning page were showing "No data available" for Gap Selling Analysis (page 6), MEDDPICC Qualification (page 7), and Strategic Narrative/StoryBrand (page 9) pages, despite the data existing in the database.

## Symptoms

- Gap Selling Analysis page displayed "No data available"
- MEDDPICC Qualification page displayed "No data available"
- Strategic Narrative page displayed "No data available"
- Financial Plan page showed "No financial targets available"
- Cover page showed Health: N/A, ARR: $0, NPS: N/A

## Root Cause

The `handleExport` function in `/src/app/(dashboard)/planning/page.tsx` was constructing a `planData` object to pass to the export API, but it was **not including** the `methodology_data` field from the database query response.

The database query (`supabase.from('strategic_plans').select('*')`) correctly fetched all fields including `methodology_data`, but the `planData` object only mapped:
- `portfolio_data`
- `stakeholders_data`
- `opportunities_data`
- `risks_data`
- `actions_data`
- `summary_notes`

The critical `methodology_data` field (containing Gap Selling, MEDDPICC, StoryBrand data) was omitted.

## Debug Process

1. Created diagnostic script to verify database content - confirmed `methodology_data` exists with all required fields
2. Added debug logging to export route to trace data flow
3. Discovered that `methodology_data` was `false` (missing) in the plan object
4. Traced the issue to the frontend `handleExport` function which wasn't including the field

## Fix Applied

Updated `src/app/(dashboard)/planning/page.tsx` to include:

```typescript
const planData = {
  // ... existing fields ...

  // FIX: Include methodology_data for Gap Selling, MEDDPICC, StoryBrand
  methodology_data: data?.methodology_data || null,

  // Include additional fields for comprehensive export
  targets_data: data?.targets_data || null,
  snapshot_data: data?.snapshot_data || null,
  cse_name: (plan as TerritoryStrategy).cse_name || data?.cse_name || '',
  cam_name: data?.cam_name || '',
}
```

Also added `_data` suffix variants for backward compatibility with the export route's data transformation logic.

## Files Changed

- `src/app/(dashboard)/planning/page.tsx` - Added methodology_data and related fields to planData object

## Testing Performed

1. Exported PDF from the planning page "My Plans" section
2. Verified server logs show:
   - `Has methodology_data: true`
   - `transformedGapAnalysis: true has content`
   - `transformedMEDDPICC: true totalScore=31`
   - `transformedStoryBrand: true has content`
3. Opened exported PDF and confirmed all pages now display data correctly

## Lessons Learned

1. When fetching data from a database and passing to an export function, ensure ALL fields are mapped
2. Debug logging in the transformation pipeline helps identify where data is lost
3. The export route correctly transforms data when it receives it - the issue was upstream in the frontend

## Related Files

- `src/app/api/planning/export/route.ts` - Export API route with data transformation logic
- `src/lib/planning/export-plan.ts` - Export helper function
- `src/lib/pdf/account-plan-pdf.ts` - PDF generator

## Commit

`fix: Include methodology_data in PDF export from planning page`
