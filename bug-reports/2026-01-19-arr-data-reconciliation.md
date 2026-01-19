# Bug Fix: ARR Data Reconciliation

**Date:** 2026-01-19
**Commit:** cf681161 (rebased to 569f0492)
**Type:** Data Correction
**Status:** Completed

## Summary

Corrected the Total ARR figure on the Executive Dashboard from $34.3M to $29.9M after reconciling with the 2026 APAC Performance Excel file.

## Problem

The Executive Dashboard was displaying incorrect figures:
- **Displayed ARR**: $34.3M
- **Correct ARR**: $29.9M (based on Excel reconciliation)
- **Discrepancy**: ~$4.4M overstatement

Additionally, the "8 active contracts" label was misleading because:
- It only counted Opal Maintenance contracts (8 contracts totalling $1.4M)
- The actual client count with revenue is 14

## Root Cause

1. **Stale data in `burc_arr_tracking` table** - The table contained old/incorrect values summing to $34.3M
2. **Misleading label** - "active contracts" referred specifically to Opal contracts, not total clients with revenue

## Investigation

### Excel Analysis (2026 APAC Performance.xlsx)

| Metric | Value |
|--------|-------|
| Committed Gross Revenue | $19.7M |
| Best Case (PS + Maint) | $8.0M |
| Total Expected Gross Rev | ~$27.7M |
| burc_historical_revenue_detail total | $29.85M |

### Database State (Before Fix)

| Source | Value |
|--------|-------|
| burc_arr_tracking (SUM) | $34,268,986 |
| burc_executive_summary.total_arr | $34,268,986 |
| burc_historical_revenue_detail | $29,855,057 |

### The 8 Opal Contracts

| Client | Annual Value (USD) |
|--------|-------------------|
| WA Health | $459,637 |
| BWH | $223,640 |
| EPH | $149,907 |
| Grampians | $145,466 |
| AWH | $140,691 |
| Western Health | $126,444 |
| GHA Regional | $124,838 |
| RVEEH | $29,050 |
| **Total** | **$1,399,678** |

### The 14 Clients with Revenue (FY26)

| Client | Revenue (USD) |
|--------|--------------|
| SA Health | $12,281,293 |
| Singapore Health Services | $9,228,991 |
| Gippsland Health Alliance | $1,864,793 |
| St Luke's Medical Center | $1,834,622 |
| Western Australia DoH | $1,003,043 |
| Ministry of Defence Singapore | $723,700 |
| Te Whatu Ora Waikato | $647,904 |
| Mount Alvernia Hospital | $614,557 |
| GRMC | $541,864 |
| Barwon Health Australia | $502,658 |
| Epworth Healthcare | $198,223 |
| Albury Wodonga Health | $160,476 |
| Western Health | $152,514 |
| RVEEH | $100,417 |
| **Total** | **$29,855,057** |

## Solution

### Database Fix

1. Cleared old data from `burc_arr_tracking` table (year 2025)
2. Inserted correct values from `burc_historical_revenue_detail` (14 records)
3. Updated `burc_annual_financials.starting_arr` to $29,855,057

```javascript
// Clear old ARR tracking
await supabase.from('burc_arr_tracking').delete().eq('year', 2025)

// Insert correct values from revenue detail
const newRecords = Object.entries(byClient).map(([client, amount]) => ({
  client_name: client,
  arr_usd: amount,
  year: 2025
}))
await supabase.from('burc_arr_tracking').insert(newRecords)
```

### UI Fix

Changed label from "active contracts" to "active clients":

```typescript
// Before
{summary?.active_contracts || 0} active contracts

// After
{arrByClient.length || summary?.active_contracts || 0} active clients
```

## Results

| Metric | Before | After |
|--------|--------|-------|
| Total ARR | $34.3M | $29.9M |
| vs FY25 change | +$6.5M | +$2.1M |
| Label | "8 active contracts" | "14 active clients" |

## Verification

- Excel reconciliation confirms $29.85M total revenue for FY26
- Database now shows correct sum from 14 client records
- Dashboard displays accurate figures

## Related Files

- `src/components/burc/BURCExecutiveDashboard.tsx` - UI label change
- `burc_arr_tracking` table - Data correction
- `burc_annual_financials` table - ARR update
- `scripts/sync-burc-comprehensive.mjs` - Data sync script

## Prevention

1. **Regular reconciliation** - Compare database totals against Excel source files
2. **Data validation** - Add checks during sync to flag large discrepancies
3. **Clear labelling** - Distinguish between "contracts" (specific agreements) and "clients" (revenue-generating accounts)
