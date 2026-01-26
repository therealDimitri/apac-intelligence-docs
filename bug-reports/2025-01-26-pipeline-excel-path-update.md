# Bug Report: Pipeline Data Source Path Update

## Issue
The pipeline API was reading from an older version of the Sales Budget Excel file located in OneDrive. User requested the data source be updated to reflect the latest file.

## Date
2025-01-26

## Context
Two versions of the same Excel file existed:
- **OneDrive version**: Modified 21 Jan 23:43 (395,698 bytes)
- **Desktop version**: Modified 22 Jan 12:37 (395,637 bytes)

The Desktop version is the more recent copy with updated pipeline data.

## Files Affected
- `src/app/api/pipeline/2026/route.ts` - Pipeline API endpoint

## Changes Made

### File Path Update (line 6-7)
```typescript
// Before:
const SALES_BUDGET_PATH =
  '/Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth/Documents/Client Success/Sales Planning & Targets/Sales Targets/2026/APAC 2026 Sales Budget 14Jan2026 v0.1.xlsx'

// After:
const SALES_BUDGET_PATH =
  '/Users/jimmy.leimonitis/Desktop/APAC 2026 Sales Budget 14Jan2026 v0.1.xlsx'
```

## Pipeline Totals (from 'APAC Pipeline by Qtr (RECON)' sheet)
- **Total Rows**: 87 opportunities
- **Total ACV**: $17,917,984.53
- **Total Weighted ACV**: $8,343,469.94

## Testing
- Build passes with zero TypeScript errors
- File read verification confirms correct parsing of:
  - Header row detection
  - ACV column (index 13)
  - Weighted ACV column (index 16)
  - All 87 opportunity rows

## Notes
- The CSE Summary sheet shows slightly different totals ($8,358,549.35 Weighted ACV) due to different reconciliation/filtering logic
- The API uses the 'APAC Pipeline by Qtr (RECON)' sheet which applies its own reconciliation rules
- BURC cross-reference file path remains unchanged (still points to OneDrive)

## Status
RESOLVED
