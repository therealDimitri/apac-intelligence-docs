# Bug Report: BURC Annual Financials Not Syncing Correctly

**Date:** 2026-01-07
**Status:** Resolved
**Priority:** High
**Component:** BURC Sync Script / Revenue Trend API

---

## Issue Summary

The BURC sync script was not extracting annual financial totals from the source Excel file, causing:
1. Revenue Trend API to show incorrect 786.2% YoY growth instead of the correct values
2. FY2026 forecast showing $33.74M instead of the correct $31.170M

---

## Root Cause

**Two related issues:**

### Issue 1: API Using Wrong Data Source
The `getRevenueTrend` function in the historical API was using `burc_historical_revenue_detail` as the primary data source, which had almost no data. Only FY2026 was being fetched from `burc_annual_financials`.

**Result:** YoY calculation compared $33.74M to near-zero values = 786.2%

### Issue 2: Sync Script Not Updating Annual Financials
The BURC sync script (`sync-burc-data-supabase.mjs`) was syncing monthly financial data but **not** extracting the annual totals from the "APAC BURC" worksheet.

**Source File:** `2026/2026 APAC Performance.xlsx`
- Row 35: "Gross Revenue (Actual and Forecast) Includes Business Case"
- Column 20: FY2026 Total
- Column 22: FY2025 Total

---

## Solution Implemented

### Fix 1: API Route (already documented in separate bug report)
Changed `src/app/api/analytics/burc/historical/route.ts` to use `burc_annual_financials` as the primary source.

### Fix 2: Sync Script Enhancement
Added `syncAnnualFinancials()` function to `scripts/sync-burc-data-supabase.mjs`:

```javascript
async function syncAnnualFinancials(workbook) {
  console.log('💵 Extracting Annual Financials from APAC BURC sheet...');

  const sheet = workbook.Sheets['APAC BURC'];
  const data = XLSX.utils.sheet_to_json(sheet, { header: 1 });

  // Find Row 35: "Gross Revenue (Actual and Forecast) Includes Business Case"
  let grossRevenueRow = null;
  for (let i = 0; i < data.length; i++) {
    const firstCol = (data[i]?.[0] || '').toString();
    if (firstCol.includes('Gross Revenue') && firstCol.includes('Actual and Forecast')) {
      grossRevenueRow = data[i];
      break;
    }
  }

  // Extract FY2026 (col 20) and FY2025 (col 22) totals
  const fy2026Total = grossRevenueRow[20]; // $31,170,000
  const fy2025Total = grossRevenueRow[22]; // $30,906,000

  // Upsert to burc_annual_financials table
  // ...
}
```

Also added worksheet listing for visibility:
```javascript
console.log('📋 Worksheets in file:', workbook.SheetNames.join(', '));
```

---

## Values Before and After

| Fiscal Year | Before | After | Source |
|-------------|--------|-------|--------|
| FY2024 | $29.352M | $29.352M | Unchanged |
| FY2025 | $26.345M | $30.906M | APAC BURC Row 35, Col 22 |
| FY2026 | $33.74M | $31.170M | APAC BURC Row 35, Col 20 |

| Metric | Before | After |
|--------|--------|-------|
| FY2026 YoY Growth | 786.2% (broken) → 28.1% (partial fix) | 0.9% (correct) |

---

## Files Modified

| File | Changes |
|------|---------|
| `src/app/api/analytics/burc/historical/route.ts` | Changed to use `burc_annual_financials` as primary source |
| `scripts/sync-burc-data-supabase.mjs` | Added `syncAnnualFinancials()` function, added worksheet listing |

---

## Worksheets in Source File

The sync script now logs all available worksheets:
- **APAC BURC** - Main financial summary (Row 35 contains annual totals)
- Summary
- CSI (APAC)
- CSI (HFI)
- Pipeline
- FY26 Rev By Type
- FY26 Rev By Month
- (and others)

---

## Testing Verification

- [x] Sync script extracts correct values from APAC BURC sheet
- [x] FY2026: $31.170M matches user's expected value
- [x] FY2025: $30.906M extracted correctly
- [x] Database updated with correct timestamps
- [x] TypeScript compilation passes (`npx tsc --noEmit`)

---

## Database State After Fix

```
FY2024: $29.352M (updated: 2026-01-06)
FY2025: $30.906M (updated: 2026-01-07)
FY2026: $31.170M (updated: 2026-01-07)
```

---

## Lessons Learned

1. **Sync scripts must be comprehensive**: When syncing financial data, all relevant totals must be extracted, not just granular monthly data
2. **Single source of truth**: The "2026 APAC Performance.xlsx" file is the authoritative source for ALL 2026 financials including CSI ratios
3. **Log available worksheets**: Helps with debugging and ensures all data sources are visible
4. **Test with user-expected values**: Always verify synced data matches what users expect from the source file

---

## Related Files

- `scripts/sync-burc-data-supabase.mjs` - BURC sync script
- `src/app/api/analytics/burc/historical/route.ts` - Revenue Trend API
- `burc_annual_financials` table - Stores annual financial totals
- Source: `2026/2026 APAC Performance.xlsx` on SharePoint
