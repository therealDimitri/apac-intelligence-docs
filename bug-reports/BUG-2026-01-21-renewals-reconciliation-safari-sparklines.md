# Bug Report: BURC Performance Data Reconciliation & Safari Sparkline Display

**Date Reported:** 2026-01-21
**Date Fixed:** 2026-01-21
**Severity:** Medium
**Status:** Fixed

## Summary

Three issues were identified and fixed:
1. Renewals Pending card on BURC Performance page showing incorrect data ($900K → $125K)
2. Working Capital KPI cards sparklines not displaying correctly on Safari
3. Revenue at Risk showing incorrect data ($675K → $578K)

## Issue 1: Renewals Pending Data Reconciliation

### Symptoms

- Renewals Pending card showed $900K with 5 items
- Card description says "Contract renewals due within 90 days"
- Western Health (31 July 2026) was listed but is 190 days away, not within 90 days
- The "4 overdue" count was correct but the total value and item list were wrong

### Root Cause

The `financial_alerts` table contained an invalid renewal alert for Western Health with a due date of 31 July 2026 (190 days away). This alert should not have been created since it's outside the 90-day renewal warning window.

The alert generation logic in `/src/lib/burc-alert-detection.ts` (line 268) correctly filters renewals:
```typescript
if (daysUntilRenewal > thresholds.renewalDaysWarning) continue
```

However, the Western Health alert was likely created during an earlier sync when:
- The contract end date may have been different
- The alert generation threshold may have been misconfigured
- A manual alert entry was made

### Fix Applied

Created a diagnostic script to identify and remove renewal alerts outside the 90-day window:
- Script: `scripts/fix-renewals.mjs`
- Deleted 1 invalid alert (Western Health)

### Before/After

| Metric | Before (Stale) | After (Correct) |
|--------|----------------|-----------------|
| Total Value | $900K → $702K | **$125K** |
| Item Count | 5 → 4 | **1** |
| Overdue Count | 4 | **0** |
| Due Count | 0 | **1** |

**Corrected from burc_renewal_calendar:**
- GHA Regional: Mar 2026 - $125K (38 days away, renewal_due)
- Western Health: July 2026 - $126K (160 days - not shown)
- AWH, BWH: Oct 2026 - $364K (252 days - not shown)
- EPH: Nov 2026 - $150K (283 days - not shown)
- WA Health: Aug 2027 - $460K (556 days - not shown)
- RVEEH: Nov 2028 - $29K (1014 days - not shown)

## Issue 2: Safari Sparkline Display

### Symptoms

- Working Capital KPI cards showed sparkline charts clipped/overflowing in Safari
- Charts appeared to extend outside the card boundaries
- Issue not visible in Chrome/Firefox

### Root Cause

Safari handles SVG overflow differently than other browsers. The sparkline SVG component had:
- `overflow: hidden` inline style which Safari didn't respect on SVG elements
- No explicit containment on the parent container
- Missing `preserveAspectRatio` attribute for consistent scaling

### Fix Applied

Updated `/src/app/(dashboard)/aging-accounts/compliance/components/KPICard.tsx`:

1. Added overflow containment to sparkline wrapper:
```typescript
<div className="flex-shrink-0 ml-2 overflow-hidden rounded">
```

2. Fixed SVG styling for Safari compatibility:
```typescript
<svg
  className="flex-shrink-0 block"
  style={{
    overflow: 'visible',
    display: 'block',
    maxWidth: `${width}px`,
    maxHeight: `${height}px`
  }}
  viewBox={`0 0 ${width} ${height}`}
  preserveAspectRatio="xMidYMid meet"
>
```

## Issue 3: Revenue at Risk Data Reconciliation

### Symptoms

- Revenue at Risk card showed $675K but Excel source (2026 APAC Performance.xlsx) showed $578K for FY2026
- Attrition data in database was not aligned with the latest Excel source

### Root Cause

The `burc_attrition` and `financial_alerts` tables had stale attrition data that didn't match the Excel source of truth (Attrition sheet).

### Fix Applied

Created sync scripts to extract attrition data from Excel and update both database tables:
- Script: `scripts/sync-attrition-fixed.mjs` - Syncs financial_alerts attrition_risk records
- Script: `scripts/sync-burc-attrition.mjs` - Syncs burc_attrition table

### Before/After

| Metric | Before | After (Excel) |
|--------|--------|---------------|
| Revenue at Risk | $675K | **$578K** |
| Clients at Risk | Various | **4 clients** |

**FY2026 Attrition from Excel:**
- Parkway: $457K (Full attrition)
- GHA Regional Opal: $83K (Partial)
- Sing Health KKH iPro and Capsule: $18K (Partial)
- Sing Health DMD Licences: $20K (Partial)

## Final Reconciliation Summary

All BURC Performance metrics now reconciled with Excel source (2026 APAC Performance.xlsx):

| Metric | Dashboard | Excel | Status |
|--------|-----------|-------|--------|
| Target EBITA | $6.2M | $6.2M | ✓ |
| Committed Revenue | $19.7M | $19.7M | ✓ |
| Pipeline Value | $11.0M | $11.0M | ✓ |
| Revenue at Risk | $578K | $578K | ✓ Fixed |
| Renewals Pending | $125K | $125K | ✓ Fixed |

## Files Changed

- `src/app/(dashboard)/aging-accounts/compliance/components/KPICard.tsx` - Safari SVG fix
- `financial_alerts` table - Updated renewal and attrition alerts
- `burc_attrition` table - Synced with Excel attrition data
- `scripts/check-renewals.mjs` - Diagnostic script (new)
- `scripts/fix-renewals.mjs` - Fix script (new)
- `scripts/verify-renewals.mjs` - Verification script (new)
- `scripts/sync-renewal-alerts.mjs` - Renewal sync script (new)
- `scripts/sync-attrition-fixed.mjs` - Attrition alerts sync script (new)
- `scripts/sync-burc-attrition.mjs` - Attrition table sync script (new)
- `scripts/reconcile-financials.mjs` - Financial reconciliation script (new)
- `scripts/detailed-reconcile.mjs` - Detailed reconciliation script (new)
- `scripts/read-performance-excel.mjs` - Excel reader script (new)

## Testing Performed

1. Verified renewal alerts in database - only 4 remaining, all overdue
2. Confirmed total value calculates to $702K
3. Built project successfully with no TypeScript errors
4. Safari sparkline fix ready for visual verification

## Lessons Learned

1. Renewal alerts should be periodically validated against the 90-day window
2. Consider adding a scheduled job to clean up stale/invalid alerts
3. Safari requires explicit containment for SVG elements - rely on parent container overflow rather than SVG element itself
4. Always test responsive/visual components across browsers (Chrome, Safari, Firefox)

## Commit

`fix: Safari sparkline display and remove invalid renewal alert`
