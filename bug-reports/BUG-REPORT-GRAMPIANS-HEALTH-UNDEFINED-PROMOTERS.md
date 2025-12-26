# Bug Report: TypeError - Cannot read properties of undefined (reading 'promoters')

**Date:** 2025-12-03
**Severity:** High (Application Crash)
**Status:** ✅ Fixed
**Affected Component:** LeftColumn.tsx - NPS Metrics Display

---

## Problem Summary

Grampians Health client page crashed with `TypeError: Cannot read properties of undefined (reading 'promoters')` when rendering NPS metrics in the left column.

**Root Cause:** Code attempted to access `.promoters` property on `latestPeriod` without checking if it exists. When `npsTrendData` array is empty, `latestPeriod` is `undefined`.

**Visual Evidence:**
Console showed:

```
📅 [Monthly Overview] Segmentation events array: Array(0)
📅 [Monthly Overview] Segmentation events count: 0
📅 [Monthly Overview] ⚠️ NO SEGMENTATION EVENTS TO PROCESS
Uncaught TypeError: Cannot read properties of undefined (reading 'promoters')
    at M (6b938017fa8033a2.js:1:19324)
```

---

## Root Cause Analysis

### Code Issue (src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx:718-719)

**BEFORE (BROKEN):**

```typescript
const latestPeriod = npsTrendData[npsTrendData.length - 1]
const totalResponses = latestPeriod.promoters + latestPeriod.passives + latestPeriod.detractors
```

**Problem:**

- When `npsTrendData` is empty (`length === 0`), `npsTrendData[0 - 1]` returns `undefined`
- Accessing `.promoters` on `undefined` throws TypeError
- This happened for Grampians Health which has 0 segmentation events

**Ironically:** Lines 105-107 of the same file handled this correctly:

```typescript
const promoters =
  npsTrendData.length > 0 ? npsTrendData[npsTrendData.length - 1]?.promoters || 0 : 0
const passives = npsTrendData.length > 0 ? npsTrendData[npsTrendData.length - 1]?.passives || 0 : 0
const detractors =
  npsTrendData.length > 0 ? npsTrendData[npsTrendData.length - 1]?.detractors || 0 : 0
```

But lines 718-722 didn't apply the same defensive pattern.

---

## Fix Applied

**File:** `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`
**Lines:** 718-760

**Changes:**

```typescript
// Added null check before accessing properties
const latestPeriod = npsTrendData[npsTrendData.length - 1]

// Handle case where no NPS data exists
if (!latestPeriod) {
  return (
    <>
      <div className="text-center p-3 bg-gray-50 rounded-lg">
        <div className="text-2xl font-bold text-gray-400">--</div>
        <div className="text-xs text-gray-600 mt-1">NPS Score</div>
      </div>
      <div className="text-center p-3 bg-gray-50 rounded-lg">
        <div className="text-2xl font-bold text-gray-400">--</div>
        <div className="text-xs text-gray-600 mt-1">Avg Score</div>
      </div>
    </>
  )
}

// Safe to access properties now
const totalResponses = latestPeriod.promoters + latestPeriod.passives + latestPeriod.detractors
```

**Result:**

- When no NPS data exists, displays "--" placeholders instead of crashing
- Maintains consistent UI layout
- Prevents TypeError from ever occurring

---

## Affected Clients

Clients with 0 NPS responses or empty `npsTrendData`:

- **Grampians Health** (confirmed crash)
- Any other client with no NPS data

---

## Impact

**Before Fix:**

- ❌ Application crash for clients without NPS data
- ❌ White screen / error boundary
- ❌ User cannot view client page at all

**After Fix:**

- ✅ Graceful handling of missing NPS data
- ✅ Displays placeholder "--" for NPS Score and Avg Score
- ✅ Page loads successfully

---

## Testing Recommendations

1. **Test clients with no NPS data:**
   - Navigate to Grampians Health
   - Verify NPS metrics show "--" instead of crashing

2. **Test clients with NPS data:**
   - Verify metrics still display correctly
   - Ensure no regression in working functionality

3. **Edge cases:**
   - Empty npsTrendData array
   - Array with single item
   - Array with multiple items

---

## Lessons Learned

1. **Consistency:** Apply the same defensive patterns throughout the file (lines 105-107 had it right)
2. **Null Checks:** Always check if array access returns undefined before using the result
3. **Graceful Degradation:** Display placeholders instead of crashing when data is missing
4. **TypeScript:** Could have prevented this with proper typing and strict null checks

---

## Related Issues

- Previous bug: BUG-REPORT-COMPLIANCE-PERCENTAGES-NOT-RECONCILING.md
- Related to clients with incomplete data

---

## Files Modified

1. **Modified:** `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx` (lines 718-760)
   - Added null check for `latestPeriod`
   - Added fallback UI for empty NPS data

---

## Verification

✅ **Tested:** Grampians Health no longer crashes
✅ **Verified:** NPS metrics display "--" when no data exists
✅ **Confirmed:** Clients with NPS data still work correctly

---

## Status

**Fixed and Deployed:** 2025-12-03
**Next Steps:** Monitor for similar issues in other components that access array elements without null checks
