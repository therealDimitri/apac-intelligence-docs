# Bug Fix Report: BURC Historical Analytics Data Display Issues

**Date:** 3 January 2026
**Type:** Bug Fix
**Severity:** Critical
**Status:** ✅ Resolved
**Components Affected:** Historical Analytics API, Data Sync Script

---

## Summary

The "Historical Analytics (2019-2025)" tab on the Financials page was displaying incorrect data due to two root causes:
1. **Accounting sign convention** - Source Excel file uses negative values for revenue (credits)
2. **Supabase pagination limit** - API queries only returned 1,000 records instead of 84,900

---

## Symptoms Observed

| Metric | Before Fix | After Fix |
|--------|------------|-----------|
| Total Revenue | $-371,791 (negative!) | **$164.7M** |
| Total Clients | 6 | **20** |
| Top 10 Revenue | $-371,790 | **$162.2M** |
| NRR/GRR | 0% (Unhealthy) | Realistic values |
| Client lifetime values | All negative | All positive |

---

## Root Causes

### 1. Accounting Sign Convention (Data Sync)

The source Excel file (`APAC Revenue 2019 - 2024.xlsx`) uses accounting convention where:
- **Revenue (credits) = Negative values**
- **Expenses/adjustments (debits) = Positive values**

The sync script was storing values as-is, resulting in negative revenue totals.

**Fix:** Negate amounts when inserting into database:
```javascript
// Before
amount_usd: isNaN(amountUsd) ? 0 : amountUsd

// After
amount_usd: isNaN(rawAmountUsd) ? 0 : -rawAmountUsd  // Negate for positive revenue
```

### 2. Supabase 1,000 Row Default Limit (API)

Supabase returns a maximum of 1,000 rows by default. The historical table contains **84,900 records**, so queries were only returning ~1.2% of the data.

**Fix:** Added pagination helper function to fetch all records:
```typescript
async function fetchAllRecords<T>(
  tableName: string,
  selectColumns: string,
  filters?: { gte?: {...}; lte?: {...} }
): Promise<T[]> {
  const allRecords: T[] = []
  const pageSize = 1000
  let page = 0
  let hasMore = true

  while (hasMore) {
    const { data } = await supabase
      .from(tableName)
      .select(selectColumns)
      .range(page * pageSize, (page + 1) * pageSize - 1)
    // ... pagination logic
  }
  return allRecords
}
```

---

## Files Modified

### 1. `scripts/resync-burc-historical-complete.mjs`
- Added comment explaining accounting convention
- Changed `amount_usd` and `amount_aud` to negate values on insert

### 2. `src/app/api/analytics/burc/historical/route.ts`
- Added `fetchAllRecords<T>()` helper function for pagination
- Updated `getRevenueTrend()` to use pagination
- Updated `getRevenueMix()` to use pagination
- Updated `getClientLifetimeValue()` to use pagination
- Updated `getRevenueConcentration()` to use pagination
- Updated `getHistoricalNRR()` to use pagination

---

## Database Stats After Fix

| Table | Records | Notes |
|-------|---------|-------|
| `burc_historical_revenue_detail` | 84,900 | Full 2019-2024 data |
| `burc_critical_suppliers` | 357 | Vendor list (no spend data) |

**Revenue by Year (USD):**
- 2019: $25.53M
- 2020: $27.49M
- 2021: $29.63M
- 2022: $26.64M
- 2023: $30.83M
- 2024: $33.09M
- **Total: $173.21M**

---

## Verification Steps

1. Navigate to Financials → Historical (2019-2025) tab
2. Verify Total Revenue shows ~$164-173M
3. Verify Client Lifetime Value table shows 20 clients
4. Verify top client (Minister for Health) shows ~$52M lifetime value
5. Verify charts display data across all years 2019-2024

---

## Known Limitations

1. **Critical Suppliers spend data** - The source Excel file only contains vendor names and criticality (Y/N), not spend amounts. All supplier spend shows $0.

2. ~~**2025 data** - No 2025 revenue data exists~~ **RESOLVED** - 2025 data now synced ($32.47M total). See [2025 Revenue Sync](./ENHANCEMENT-20260103-2025-revenue-data-sync.md).

3. **Some negative 2024 values** - A few clients show negative 2024 revenue (e.g., St Luke's: -$742K) which may be credits/adjustments in the source data.

---

## Related Documentation

- [BURC Historical Dashboard Enhancement](./ENHANCEMENT-20260102-burc-historical-dashboard.md)
- [Database Schema](../database-schema.md)
