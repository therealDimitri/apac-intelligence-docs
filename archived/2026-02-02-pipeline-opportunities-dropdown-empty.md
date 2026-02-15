# Bug Report: Pipeline Opportunities Dropdown Empty in Risk & Recovery Step

**Status:** Fixed
**Date:** 2026-02-02
**Component:** Account Planning Coach - Risk & Recovery Step
**Severity:** High

## Summary

Pipeline Opportunities dropdown was empty when selecting a client in the "Add Risk" form on Step 5 (Risk & Recovery) of the Account Planning Coach.

## Root Cause

Two cascading issues in `src/app/(dashboard)/planning/strategic/new/page.tsx`:

### Issue 1: Malformed Alias Data Breaking Supabase Query

The `client_name_aliases` table contained entries where `display_name` had multiple comma-separated names (e.g., `"SA Health (iPro), SA Health (iQemo), SA Health (Sunrise)"`). When these were passed to Supabase's `.in()` filter, the resulting URL encoding caused a **400 Bad Request** error.

**Fix:** Added validation to filter out malformed alias names before querying:

```javascript
const validClientNames = expandedClientNames.filter(name => {
  if (name.includes(',')) return false
  if (name.length > 100) return false
  return true
})
```

### Issue 2: Non-Array Data Causing forEach Error

When the health data query failed with 400, `arrResult.data` was not an array, causing `TypeError: arrData?.forEach is not a function`.

**Fix:** Added `Array.isArray()` guard in two locations:

```javascript
const arrData = Array.isArray(arrResult.data)
  ? (arrResult.data as { client_name: string; arr_usd: number }[])
  : []
```

## Impact

- Portfolio clients failed to load for CSEs with affected client aliases
- Pipeline opportunities (loaded alongside portfolio) were empty
- Risk form could not be completed properly

## Files Changed

- `src/app/(dashboard)/planning/strategic/new/page.tsx` - Added alias validation and array safety checks

## Verification

After fix:
- 4 SA clients loaded successfully
- 19 pipeline opportunities displayed in dropdown for SA Health
- No console errors

## Data Cleanup Performed

Cleaned up 13 malformed entries in `client_name_aliases` table:

| Action | Count | Details |
|--------|-------|---------|
| Deleted garbage | 11 | Meeting prefixes ("CONFIRMED,", "Re,", "PLACEHOLDER,") concatenated with client names |
| Deleted redundant | 2 | Concatenated aliases where individual entries already existed |
| Added splits | 2 | "Gippsland Health Alliance (GHA)" and "SA Health (Sunrise)" |

**Before:** 88 aliases, 19 malformed
**After:** 77 aliases, 6 with legitimate commas (company names like "Dept of Health, Victoria")

## Final Verification

Tested via Playwright on localhost:3001 after data cleanup:

1. Selected Laura Messing as CSE → "4 clients loaded"
2. Navigated to Step 5 (Risk & Recovery)
3. Clicked "Add Risk" button
4. Client dropdown showed all 4 SA Health variants
5. Selected "SA Health ⚠️"
6. **Pipeline Opportunity dropdown populated with 19 opportunities:**
   - SA Health - Renal ($1500K)
   - SA Health - Sunrise renewal + Wdx 2026 ($945K)
   - SA Health - WCHN Sunrise Surgery License ($344K)
   - SA Health - 25.1 SCM and Pt Flow upgrade ($974K)
   - ...and 15 more

**Result:** Fix confirmed working end-to-end.
