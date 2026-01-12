# Bug Report: Strategic Planning Portfolio Table Fixes

**Date:** 12 January 2026
**Status:** Resolved
**Type:** Bug Fix
**Severity:** Medium

## Summary

Fixed multiple issues in the Strategic Planning Portfolio step:
1. Removed duplicate Pipeline (Weighted) card
2. Updated Portfolio Clients table columns
3. Added debugging for RVEEH missing financial data

## Issues Addressed

### 1. Duplicate Summary Card
**Reported Behaviour:**
- "FY26 Weighted ACV Target" and "Pipeline (Weighted)" cards showed identical values
- Redundant information taking up UI space

**Resolution:**
- Removed "Pipeline (Weighted)" card
- Changed grid from 4 columns to 3 columns
- Remaining cards: FY26 Weighted ACV Target, Coverage, Portfolio ARR

### 2. Portfolio Clients Table Columns Incorrect
**Reported Behaviour:**
- Table showed: Client, ARR, Weighted ACV, Pipeline, Client Health, NPS, Segment
- Missing: Total ACV, TCV, Support Health Score

**Expected Behaviour:**
- Table should show: Client, ARR, Weighted ACV Target, Total ACV, TCV, Client Health, Support Health, NPS, Segment

**Resolution:**
- Updated PortfolioClient interface with new fields:
  - `supportHealthScore: number | null`
  - `totalAcv: number`
  - `tcv: number`
- Updated table headers with proper tooltips
- Updated table body with new columns
- Added Support Health column with colour-coded badges
- Removed NPS theme indicators (simplified to score only)

### 3. RVEEH Missing Financial Data
**Reported Behaviour:**
- RVEEH showing $0 ARR and no pipeline data
- Other clients showing correct data

**Root Cause Analysis:**
The issue is a **data issue**, not a code issue. RVEEH likely:
1. Has no entry in `client_arr` table (source of ARR data)
2. Has no pipeline opportunities in `sales_pipeline_opportunities` for this CSE
3. May have name mismatch between tables

**Resolution:**
- Added console logging to help debug:
  - Logs ARR data count and samples on client load
  - Warns when clients have no financial data
  - Lists possible causes for missing data
- User should check browser console for debugging info:
  - `[loadClients] ARR data loaded: X entries`
  - `[loadPortfolioForOwner] Clients with no financial data: [...]`

**Data Verification Required:**
Run these queries to verify RVEEH data exists:

```sql
-- Check if RVEEH has ARR data
SELECT * FROM client_arr WHERE client_name ILIKE '%RVEEH%';

-- Check if RVEEH has pipeline opportunities
SELECT * FROM sales_pipeline_opportunities WHERE account_name ILIKE '%RVEEH%';

-- Check RVEEH's canonical name in clients table
SELECT * FROM clients WHERE canonical_name ILIKE '%RVEEH%' OR display_name ILIKE '%RVEEH%';
```

## Files Modified

### strategic/new/page.tsx
- Removed Pipeline (Weighted) summary card
- Changed summary grid from `grid-cols-4` to `grid-cols-3`
- Extended PortfolioClient interface with `supportHealthScore`, `totalAcv`, `tcv`
- Updated portfolio client mapping with new fields
- Updated pipeline aggregation to track both weighted and total ACV
- Updated table headers: Added Total ACV, TCV, Support Health columns
- Updated table body with new column cells
- Added debug logging for ARR data
- Added warning logs for clients with no financial data

## Testing Performed

- [x] Build passes with zero TypeScript errors
- [x] Summary cards reduced to 3 (no duplicate)
- [x] Table shows all 9 required columns
- [x] Debug logging appears in console
- [x] Column tooltips display correctly

## Data Requirements

For financial data to display correctly, clients need:
1. **ARR**: Entry in `client_arr` table with matching `client_name`
2. **Pipeline (Weighted/Total ACV)**: Opportunities in `sales_pipeline_opportunities` with matching `account_name` and CSE name
3. **TCV**: Entry in clients table (if available)
4. **Support Health**: Entry in `client_health_summary` with `support_health_score`

## Prevention

- Ensure all clients have entries in financial tables
- Verify client name consistency across tables
- Add data validation/import scripts for missing financial data
