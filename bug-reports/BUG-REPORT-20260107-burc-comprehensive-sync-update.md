# Bug Report: BURC Comprehensive Sync Update - All 2026 Data from APAC BURC Sheet

**Date:** 2026-01-07
**Status:** Resolved
**Priority:** High
**Component:** BURC Sync Script

---

## Issue Summary

The BURC sync script was using multiple different worksheets for 2026 financial data, causing inconsistent data extraction and incorrect values. The user directive was clear:

> "ALWAYS use the APAC BURC worksheet for 2026 data. Only use the comparison sheet for 2025 data."
> "Always use the APAC BURC sheet for EBITA, OPEX, Gross Revenue, Net Revenue, COGS, Headcount and OPEX % data."

---

## Root Cause

Multiple sync functions were using incorrect worksheets:

| Function | Before (Incorrect) | After (Correct) |
|----------|-------------------|-----------------|
| `syncEbitaData()` | "APAC BURC - Monthly EBITA" sheet | **APAC BURC** sheet, Rows 100-101 |
| `syncQuarterlyComparison()` | "26 vs 25 Q Comparison" sheet | **APAC BURC** sheet, Rows 28-36 |
| `syncRevenueStreams()` | "26 vs 25 Q Comparison" sheet | **APAC BURC** sheet, Rows 28-36 |
| `syncAnnualFinancials()` | Iteration-based extraction | **Direct cell references** (U36, W36, P14) |

---

## Solution Implemented

### 1. Single Source of Truth

All 2026 financial data now comes from the **APAC BURC** worksheet only:
- FY2026 Forecast: Cell U36 ($31.170M)
- FY2026 Target: Cell W36 ($30.906M)

FY2025 data comes from **26 vs 25 Q Comparison** worksheet:
- FY2025 Actual: Cell P14 ($26.345M)

### 2. Direct Cell References

Changed from array iteration (unreliable) to direct cell references:

```javascript
// Before (unreliable - row numbers would shift)
for (let i = 0; i < apacData.length; i++) {
  if (apacData[i]?.[0]?.includes('Gross Revenue')) {
    fy2026Total = apacData[i][20];  // Could be wrong row!
  }
}

// After (reliable - exact cell address)
const cellU36 = sheet['U36']?.v;  // Always $31.170M
```

### 3. Updated Sync Functions

| Function | APAC BURC Rows | Data Extracted |
|----------|----------------|----------------|
| `syncEbitaData()` | Row 100, 101 | EBITA values, EBITA % of Net Revenue |
| `syncOpexData()` | Rows 71, 76, 82, 88, 95, 98 | CS, R&D, PS, Sales, G&A, Total OPEX |
| `syncCogsData()` | Rows 38, 40, 44, 47, 56 | License, PS, Maint, HW, Total COGS |
| `syncNetRevenueData()` | Rows 58-66 | Net Revenue by type |
| `syncGrossRevenueMonthly()` | Rows 28-36 | Monthly Gross Revenue |
| `syncQuarterlyComparison()` | Rows 28-36 | Quarterly revenue by stream |
| `syncRevenueStreams()` | Rows 28-36 | Annual revenue streams |
| `syncCSIRatios()` | Rows 122-126 | CSI ratio metrics |

### 4. Column Mapping

```javascript
// Monthly data columns
const monthCols = ['C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N'];
//                  Jan  Feb  Mar  Apr  May  Jun  Jul  Aug  Sep  Oct  Nov  Dec

// Quarterly groupings
Q1 = ['C', 'D', 'E']  // Jan, Feb, Mar
Q2 = ['F', 'G', 'H']  // Apr, May, Jun
Q3 = ['I', 'J', 'K']  // Jul, Aug, Sep
Q4 = ['L', 'M', 'N']  // Oct, Nov, Dec

// Annual totals
Column U = FY2026 Forecast
Column W = FY2026 Target/Budget
```

---

## Values Verified After Fix

### Annual Financials
| Fiscal Year | Gross Revenue | Source |
|-------------|---------------|--------|
| FY2026 | $31.170M | APAC BURC Cell U36 |
| FY2025 | $26.345M | 26 vs 25 Q Comparison Cell P14 |
| FY2024 | $29.352M | 2024 APAC Performance.xlsx |

### YoY Growth
| Metric | Before (Broken) | After (Fixed) |
|--------|-----------------|---------------|
| FY2026 YoY Growth | 786.2% | **18.3%** |

### CSI Ratios (Jan 2026 Sample)
| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Maintenance (CS) | 460.5% | >400% | Green |
| Professional Services | 192.8% | >200% | Amber |
| Sales & Marketing | 0.0% | >100% | Red |
| R&D | 25.8% | >100% | Red |
| G&A | 22.1% | <=20% | Red |

---

## Files Modified

| File | Changes |
|------|---------|
| `scripts/sync-burc-data-supabase.mjs` | Comprehensive update - all functions now use APAC BURC for 2026 |
| `src/app/api/analytics/burc/historical/route.ts` | Changed to use `burc_annual_financials` as primary source |

---

## New Sync Functions Added

1. **`syncOpexData()`** - OPEX by category from APAC BURC
2. **`syncCogsData()`** - COGS by type from APAC BURC
3. **`syncNetRevenueData()`** - Net Revenue from APAC BURC
4. **`syncGrossRevenueMonthly()`** - Monthly Gross Revenue from APAC BURC

Note: These new functions require database tables that don't exist yet:
- `burc_opex_monthly`
- `burc_cogs_monthly`
- `burc_net_revenue_monthly`
- `burc_gross_revenue_monthly`

---

## Testing Verification

- [x] FY2026 Forecast: $31.170M matches Excel Cell U36
- [x] FY2025 Actual: $26.345M matches Excel Cell P14
- [x] YoY Growth: 18.3% (was 786.2%)
- [x] CSI Ratios synced correctly from APAC BURC
- [x] Revenue Streams synced from APAC BURC
- [x] Quarterly data synced from APAC BURC
- [x] All sync functions use direct cell references

---

## Key Rules Established

1. **2026 Data Source**: ALWAYS use APAC BURC worksheet
2. **2025 Data Source**: ONLY use 26 vs 25 Q Comparison worksheet
3. **Cell References**: Use direct cell addresses (e.g., `sheet['U36']?.v`) not array iteration
4. **Source File**: `2026 APAC Performance.xlsx` on SharePoint is the single source of truth

---

## Related Files

- `scripts/sync-burc-data-supabase.mjs` - BURC sync script
- `src/app/api/analytics/burc/historical/route.ts` - Revenue Trend API
- Source: `/APAC Leadership Team/Performance/Financials/BURC/2026/2026 APAC Performance.xlsx`

---

## Lessons Learned

1. **Single source of truth**: Always use one authoritative worksheet for each fiscal year
2. **Direct cell references**: Array iteration is unreliable when row positions can shift
3. **Document cell mappings**: Explicitly document which cells contain which data
4. **Verify with user values**: Always confirm synced values match user expectations

