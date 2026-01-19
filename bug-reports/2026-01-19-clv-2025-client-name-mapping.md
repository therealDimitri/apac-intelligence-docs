# Bug Fix: CLV Table FY2025 Data Not Displaying Due to Client Name Mismatch

**Date**: 2026-01-19
**Type**: Data Fix + Code Enhancement
**Component**: Historical Revenue - Client Lifetime Value Table
**Status**: Resolved

## Description

The Client Lifetime Value (CLV) table in the Historical Revenue section was showing $0 for all clients in the 2025 column, despite FY2025 data existing in the database. The issue was twofold:
1. FY2025 data needed to be imported from the November 2025 BURC file
2. Client name mapping was case-sensitive and missing key mappings

## Root Cause

### Data Import Issue
The `burc_historical_revenue_detail` table had only 4 FY2025 records (APAC Total aggregates). The actual client-level FY2025 data from the monthly BURC file had not been imported.

### Client Name Mapping Issue
After importing 450 FY2025 records, the CLV table still showed $0 for clients because:

1. **Case-sensitive mapping**: The `CLIENT_PARENT_MAP` used exact case matching
   - Map had: `'Minister for Health AKA South Australia Health'` (uppercase AKA)
   - Database had: `'Minister for Health aka South Australia Health'` (lowercase aka)

2. **Missing mappings**: Several FY2025 client names were not in the consolidation map
   - SingHealth subsidiaries: Changi General Hospital, Sengkang General Hospital, National Cancer Centre, National Heart Centre
   - Aggregation rows not being excluded: APAC Total, Total, Baseline, profit share entries

### Original Code (Line 428-462)

```tsx
const CLIENT_PARENT_MAP: Record<string, string> = {
  'Minister for Health AKA South Australia Health': 'SA Health',  // Wrong case
  // Missing SingHealth subsidiaries
  // Missing exclusion for aggregation rows
}

function getConsolidatedClientName(clientName: string): string {
  return CLIENT_PARENT_MAP[clientName] || clientName  // Case-sensitive
}
```

## Solution

### 1. Data Import
Ran the FY2025 BURC import script to load 450 records from the November 2025 BURC file:
```bash
node scripts/import-2025-monthly-burc.mjs
```

### 2. Code Fix - Case-Insensitive Mapping

Updated the client name mapping to:
1. Use lowercase keys for case-insensitive matching
2. Add missing SingHealth subsidiary mappings
3. Add exclusion markers for aggregation rows (APAC Total, etc.)

### Fixed Code

```tsx
const CLIENT_PARENT_MAP: Record<string, string> = {
  // SA Health family (lowercase keys)
  'minister for health aka south australia health': 'SA Health',
  'south australia health': 'SA Health',

  // SingHealth family (added subsidiaries)
  'singapore health services pte ltd': 'SingHealth',
  'singapore general hospital pte ltd': 'SingHealth',
  'changi general hospital': 'SingHealth',
  'sengkang general hospital pte. ltd.': 'SingHealth',
  // ... more subsidiaries

  // Exclusions (aggregation rows)
  'apac total': '__EXCLUDE__',
  'total': '__EXCLUDE__',
  'baseline': '__EXCLUDE__',
}

function getConsolidatedClientName(clientName: string): string | null {
  const normalised = clientName.toLowerCase().trim()
  const mapped = CLIENT_PARENT_MAP[normalised]
  if (mapped === '__EXCLUDE__') return null  // Filter out aggregation rows
  return mapped || clientName
}
```

## Files Modified

1. `src/app/api/analytics/burc/historical/route.ts`
   - Lines 428-483: Updated `CLIENT_PARENT_MAP` with lowercase keys and new mappings
   - Lines 485-494: Updated `getConsolidatedClientName()` for case-insensitive matching
   - Line 540: Added null check to skip excluded rows

## Testing

### Before Fix
- CLV 2025 column: All clients showed $0
- Only "APAC Total" had data due to aggregation rows

### After Fix
- CLV 2025 column shows actual values:
  - SA Health: $8.82M (mapped from "Minister for Health aka South Australia Health")
  - SingHealth: $7.62M (aggregated from subsidiaries)
  - WA Health: $0.26M (mapped from "Western Australia Department Of Health")
  - 17 total clients with FY2025 data

## Verification Steps

1. Navigate to `/` (Command Centre)
2. Click on "Historical Revenue" tab
3. Scroll to "Client Lifetime Value" table
4. Verify 2025 column shows actual revenue values (not $0)
5. Check that SA Health shows ~$8.8M for 2025

## Additional Notes

- The monthly BURC file uses different client naming conventions than the historical data
- The mapping now handles both exact matches and subsidiary consolidation
- Aggregation rows (APAC Total, etc.) are now filtered out to avoid double-counting

## Related Files

- `scripts/import-2025-monthly-burc.mjs` - FY2025 data import script
- `scripts/verify-clv-mapping.mjs` - Verification script for client name mapping (can be deleted after)
