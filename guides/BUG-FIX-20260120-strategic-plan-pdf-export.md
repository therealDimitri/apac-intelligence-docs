# Bug Fix Report: Strategic Account Plan PDF Export

**Date**: 2026-01-20
**Type**: Bug Fix
**Status**: Resolved
**Commit**: `5cb217f1`

## Summary

Fixed an issue where the Strategic Account Plan page was unable to export to PDF. The Export button was missing from the page, and when attempting to export through other means, the legacy PDF format was being used instead of the enhanced Altera-branded PDF.

## Problem Statement

1. **Missing Export Button**: The Strategic Account Plan page (`/planning/strategic/new`) did not have an Export button, making it impossible for users to download their plans as PDF.

2. **Wrong PDF Version**: Even when the export was triggered through other means, the old legacy PDF format was being generated instead of the new enhanced PDF with Altera branding (implemented in Enhancement 20260120).

3. **404 Error on Export**: Initial fix attempt resulted in 404 errors because the export API was looking in the wrong database table (`account_plans` instead of `strategic_plans`).

## Root Cause Analysis

1. **ExportModal Interface**: The `ExportModal` component only accepted `planType: 'territory' | 'account'`, not `'strategic'`.

2. **Missing UI Integration**: The Strategic Plan page never had the ExportModal component integrated.

3. **Export API Logic**: The export route checked for `planType === 'account'` to use the enhanced PDF generator, but strategic plans were not included in this check.

## Solution Implemented

### Files Changed

1. **`src/app/(dashboard)/planning/strategic/new/page.tsx`**
   - Added `Download` icon import from lucide-react
   - Added `ExportModal` component import
   - Added `showExportModal` state variable
   - Added Export button next to Save Draft button
   - Added ExportModal component with `planType="strategic"`

2. **`src/components/planning/ExportModal.tsx`**
   - Updated interface to accept `planType: 'territory' | 'account' | 'strategic'`
   - Updated enhanced flag logic: `enhanced: planType === 'account' || planType === 'strategic'`

3. **`src/app/api/planning/export/route.ts`**
   - Updated enhanced PDF condition to include strategic plans:
     ```typescript
     const useEnhanced = enhanced ||
       ((planType === 'account' || planType === 'strategic') && enhanced !== false)
     ```
   - Fixed ESLint errors with proper eslint-disable comments

### Technical Details

- Export button is disabled until the plan is saved (requires a valid `planId`)
- The export uses the `strategic_plans` database table (already configured in the route)
- Enhanced PDF generator with Altera branding (Montserrat font, purple/coral colours) is now used for strategic plans
- Export title format: `{CSE Name} Account Plan 2026`

## Testing

1. Navigated to saved Strategic Account Plan (`/planning/strategic/new?id=...`)
2. Clicked Export button
3. Selected PDF format with default sections
4. Clicked Export

**Results:**
- Server logs confirmed: `[PDF Export] planType: strategic enhanced: true`
- Server logs confirmed: `[PDF Export] Generating ENHANCED PDF with Altera branding`
- PDF downloaded successfully with Altera branding

## Related Changes

- This fix completes the integration of the Enhanced PDF Export feature (Enhancement 20260120) with the Strategic Account Plan workflow
- The Export button is now consistently available across all plan types

## Verification Steps

1. Navigate to `/planning/strategic/new?id={plan-id}` with a saved plan
2. Verify Export button is visible and enabled
3. Click Export and select PDF format
4. Confirm PDF downloads with Altera branding (purple headers, Montserrat font)
5. Check server logs for `ENHANCED PDF` confirmation
