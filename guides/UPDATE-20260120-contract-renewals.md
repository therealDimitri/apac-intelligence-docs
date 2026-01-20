# Contract Renewal Date Updates

**Date:** 2026-01-20
**Type:** Data Update
**Status:** Complete

## Summary

Updated contract renewal dates in both Supabase database and Excel source file for four clients that were previously showing as overdue.

## Updates Applied

| Client | Previous Date | New Date | Notes |
|--------|---------------|----------|-------|
| RVEEH | 2024-12-31 | 2028-11-30 | Renewed to Nov 2028 |
| GHA Regional | 2025-07-14 | 2026-03-31 | Renewed to Mar 2026 |
| Grampians | 2025-09-30 | *Cleared* | No renewal date |
| Epworth (EPH) | 2025-11-15 | 2026-11-15 | Renewed to Nov 2026 |

## Files Updated

### Database
- Table: `burc_contracts`
- Script: `scripts/update-contract-renewals.mjs`

### Excel Source
- File: `2026 APAC Performance.xlsx`
- Sheet: `Opal Maint Contracts and Value`
- Script: `scripts/update-excel-renewals.mjs`

## Final Contract State

| Client | Renewal Date | Annual Value (AUD) | Status |
|--------|--------------|-------------------|--------|
| Grampians | Not set | $227,291 | No date |
| GHA Regional | 2026-03-31 | $195,060 | Upcoming |
| Western Health | 2026-07-31 | $197,569 | Upcoming |
| BWH | 2026-10-01 | $349,439 | Upcoming |
| AWH | 2026-10-31 | $219,831 | Upcoming |
| EPH | 2026-11-15 | $234,231 | Upcoming |
| WA Health | 2027-08-04 | $718,184 | Upcoming |
| RVEEH | 2028-11-30 | $45,392 | Upcoming |

## Scripts Created

### `scripts/update-contract-renewals.mjs`
Updates renewal dates directly in Supabase `burc_contracts` table.

### `scripts/update-excel-renewals.mjs`
Updates renewal dates in the Excel source file to keep data in sync.

## Verification

Both database and Excel source file have been verified to contain the correct updated values. The "Overdue Renewals" section should now show no overdue contracts.
