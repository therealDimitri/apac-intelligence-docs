# Bug Report: BURC Active Clients Count Shows 4 Instead of 18

**Date:** 31 January 2026
**Severity:** Medium
**Status:** Fixed
**Commit:** 66311ba1

## Summary

The "active clients" count in the Total ARR card on the BURC Executive Dashboard was displaying "4 active clients" when there are actually 18 clients in the portfolio.

## Root Cause

The count was sourced from the wrong data:

```typescript
// Before - using burc_contracts data
{arrByClient.length || summary?.active_contracts || 0} active clients
```

The fallback `summary?.active_contracts` came from `burc_executive_summary.active_contracts` which counts records in `burc_contracts` where `status='active'`. This table only contains **maintenance contracts** synced from the "Opal Maint Contracts and Value" Excel sheet - not the full client portfolio.

| Data Source | Count | What It Contains |
|-------------|-------|------------------|
| `burc_contracts` (active) | 4 | Maintenance contracts with active status |
| `burc_contracts` (all) | 8 | All maintenance contracts (incl. expired) |
| `nps_clients` | 18 | Actual client portfolio |
| `client_segmentation` | 18 | Client segmentation data |

## Fix Applied

Changed to use `portfolioClients` from the `ClientPortfolioContext`, which already loads the full client list:

```typescript
// After - using portfolio clients
{portfolioClients.filter(c => c.name !== 'Internal').length || summary?.active_contracts || 0} active clients
```

## Files Changed

- `src/components/burc/BURCExecutiveDashboard.tsx` (line 1491)

## Testing

1. Navigated to `/burc` page
2. Verified Total ARR card now shows "18 active clients"
3. Confirmed this matches the "Client Health: 18 total" section on the same page

## Prevention

When displaying client counts, always use `portfolioClients` from `useClientPortfolio()` context rather than BURC-specific contract tables, which may contain subset data.

## Related

- The `burc_contracts` table was populated by `scripts/sync-burc-contracts.mjs` from the maintenance contracts sheet
- The `burc_historical_revenue_detail` table for FY26 also lacks client-level breakdown (only has "APAC Total" summary rows)
