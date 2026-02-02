# Bug Report: BURC Backlog Category Sync Incorrect

**Date:** 2 February 2026
**Status:** Fixed
**Severity:** High
**Affected Components:** BURC Pipeline Sync Scripts, burc_pipeline_detail, burc_business_cases

## Summary

The BURC sync scripts were incorrectly handling "Backlog" items, causing:
1. Dial 2 Backlog items (like "SA Health TQEH AIMS") to be categorised as "Pipeline"
2. Maintenance run-rate renewals from Maint/SW/PS/HW sheets to be imported as "Backlog" (43 erroneous items totaling $30.59M)

## Root Causes

### 1. Missing Backlog handling in normaliseForecast()

**File:** `scripts/sync-pipeline-and-attrition.mjs` (line 454-460)

```javascript
// BEFORE: Backlog fell through to default "Pipeline"
function normaliseForecast(fcast) {
  const f = fcast.toLowerCase()
  if (f.includes('best')) return 'Best Case'
  if (f.includes('bus')) return 'Business Case'
  if (f.includes('lost') || f.includes('closed')) return 'EXCLUDE'
  return 'Pipeline'  // ← Backlog defaulted here!
}
```

### 2. Maintenance run-rates imported as Backlog

**File:** `scripts/sync-burc-comprehensive.mjs` (line 416-423)

The script reads from Maint/SW/PS/HW sheets where "Status = Backlog" means **maintenance run-rate renewals** (e.g., "Run Rate 25/26", "CPI - 5%"), not Dial 2 pipeline deals. These were incorrectly imported to `burc_business_cases` with `forecast_category = 'Backlog'`.

## Two Different "Backlog" Meanings

| Sheet | "Backlog" Meaning | Correct Destination |
|-------|-------------------|---------------------|
| Maint/SW/PS/HW sheets | Maintenance run-rate renewals | Should NOT be imported as pipeline |
| Dial 2 Risk Profile Summary | Committed deals in forecast | `burc_pipeline_detail` |

## Resolution

### Fix 1: Add Backlog handling to normaliseForecast()

```javascript
function normaliseForecast(fcast) {
  const f = fcast.toLowerCase()
  if (f.includes('backlog')) return 'Backlog'  // ADD THIS
  if (f.includes('best')) return 'Best Case'
  if (f.includes('bus')) return 'Business Case'
  if (f.includes('lost') || f.includes('closed')) return 'EXCLUDE'
  return 'Pipeline'
}
```

### Fix 2: Skip Backlog status from revenue sheets

```javascript
// Skip empty rows, backlog headers, lost opportunities, or maintenance run-rates
if (!clientName || clientName === 'Backlog' || status === 'Lost' || status === 'Backlog') continue
```

### Fix 3: Update section color mapping

```javascript
const sectionColor = category === 'Backlog' ? 'green' :
                     category === 'Best Case' ? 'green' :
                     category === 'Business Case' ? 'yellow' : 'pipeline'
```

### Data Cleanup

Deleted 43 erroneous "Backlog" items from `burc_business_cases` that were actually maintenance run-rates.

## Verification

After fix:
- ✅ "SA Health TQEH AIMS": `forecast_category: Backlog`, `in_forecast: true`
- ✅ `burc_business_cases` Backlog count: 0
- ✅ `burc_pipeline_detail` FY2026 categories:
  - Backlog: 1 item (matches Excel)
  - Best Case: 24 items
  - Business Case: 9 items
  - Pipeline: 38 items

## Related Commits

- Scripts: `5dab1c3` - fix: correct Backlog category handling in BURC sync
- Parent: `a2fd7188` - chore: update scripts submodule

## Lessons Learned

1. **Same field name, different meanings**: "Backlog" in Maint sheets ≠ "Backlog" in Dial 2 sheet
2. **Always handle all known categories explicitly**: Don't rely on default fallthrough for category mapping
3. **Verify against source Excel**: Database counts should match Excel Dial 2 sheet exactly
