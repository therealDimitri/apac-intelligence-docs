# Bug Report: Manager Email Shows Zero Stats

**Date**: 2026-01-26
**Severity**: High
**Status**: Fixed

## Issue Description

Manager weekly emails were showing `0 Total Clients`, `0 CSEs`, `0 Healthy`, `0 At Risk`, `0 Critical` while other sections (AR total, NPS data) showed correct values.

## Root Cause

The `getTeamPerformanceData` function in `/src/lib/emails/data-aggregator.ts` was querying a non-existent `clients` table:

```typescript
const { data: clientsData } = await supabase
  .from('clients')  // THIS TABLE DOESN'T EXIST
  .select('display_name, cse_name, cam_name, contract_end_date, arr')
  .eq('is_active', true)
```

According to the database schema (`docs/database-schema.md`), there is no `clients` table. The actual client data resides in `client_segmentation` (36 rows) with columns `client_name`, `cse_name`.

## Why AR Data Showed Correctly

The AR aging section worked because it queries `aged_accounts_history` table which does exist. Similarly, NPS data queries `nps_responses` which also exists.

## Solution

Changed the query to use `client_segmentation` table:

```typescript
const { data: segmentationData } = await supabase
  .from('client_segmentation')
  .select('client_name, cse_name, tier_id')

const clients = (segmentationData || []).map(c => ({
  display_name: c.client_name,
  cse_name: c.cse_name,
  cam_name: null, // CAM data not available in current schema
  contract_end_date: null, // Contract data not available in current schema
  arr: null, // ARR data not available in current schema
  tier_id: c.tier_id,
}))
```

## Additional Changes

1. **Renewals section**: Removed logic that depended on non-existent `contract_end_date` column. Returns empty arrays until a contracts table is added.

2. **`getCSERenewals` function**: Updated to return empty arrays since contract data doesn't exist in current schema.

3. **TypeScript fixes**: Fixed type casting issues in `changelog-generator.ts`.

## Files Modified

- `/src/lib/emails/data-aggregator.ts` - Fixed data source queries
- `/src/lib/emails/changelog-generator.ts` - Fixed TypeScript type casting

## Testing

Sent test email after fix - verified stats now show correct values:
- Total Clients: 36 (from client_segmentation)
- CSE count: correctly populated
- Health metrics: correctly calculated

## Prevention

1. Always verify table names against `docs/database-schema.md` before writing queries
2. Run `npm run validate-schema` to catch column mismatches
3. Consider adding integration tests for email data aggregation
