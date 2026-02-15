# Bug Report: Duplicate Health Score Display in Client Segmentation

## Issue Summary

Client Segmentation page displayed Health Score twice for each client:

1. As text after NPS in the header
2. As a visual progress bar below

The duplicate text display was redundant and cluttered the UI.

## Reported By

User (screenshot showing duplicate display)

## Date Discovered

2025-11-30

## Severity

**LOW** - UI inconsistency, no functional impact

---

## Problem Description

### Symptom

Each client card in the segmentation view showed Health Score in two places:

**Location 1 (Text):** `CSE: John • NPS: 85 • Health Score: 92`
**Location 2 (Visual):** Health progress bar showing score

This created visual redundancy and made the header line too crowded.

### Root Cause

The client card component (src/app/(dashboard)/segmentation/page.tsx:1006-1012) included Health Score in the text metadata line alongside CSE and NPS.

**Code Before Fix (Lines 1006-1012):**

```typescript
<div className="flex items-centre gap-4 mt-1 text-sm text-gray-600">
  <span>CSE: {client.cse_name || 'Unassigned'}</span>
  <span>•</span>
  <span>NPS: {client.nps_score !== null ? client.nps_score : 'N/A'}</span>
  <span>•</span>
  <span>Health Score: {client.health_score !== null ? Math.round(client.health_score) : 'N/A'}</span>  // ❌ Duplicate
</div>
```

Below this, at lines 1016-1034, the Health Score was already displayed as a visual progress bar with colour coding (green/yellow/red based on score).

---

## Solution Implemented

Removed the duplicate text display of Health Score from the header metadata line.

**Code After Fix (Lines 1006-1010):**

```typescript
<div className="flex items-centre gap-4 mt-1 text-sm text-gray-600">
  <span>CSE: {client.cse_name || 'Unassigned'}</span>
  <span>•</span>
  <span>NPS: {client.nps_score !== null ? client.nps_score : 'N/A'}</span>
</div>
```

The visual Health Score progress bar (lines 1016-1034) remains unchanged and continues to provide a clear, colour-coded representation of the health score.

---

## Impact

### Before Fix

```
Client Card:
┌─────────────────────────────────────────┐
│ ClientA                    [Status]     │
│ CSE: John • NPS: 85 • Health Score: 92  │ ❌ Duplicate text
│                                          │
│ Health: [███████████░░░░] 92            │ ✅ Visual bar
│ Compliance: [███████████░░░░] 85        │
└─────────────────────────────────────────┘
```

### After Fix

```
Client Card:
┌─────────────────────────────────────────┐
│ ClientA                    [Status]     │
│ CSE: John • NPS: 85                     │ ✅ Clean header
│                                          │
│ Health: [███████████░░░░] 92            │ ✅ Single display
│ Compliance: [███████████░░░░] 85        │
└─────────────────────────────────────────┘
```

### Improvements

- ✅ Cleaner header line (less crowded)
- ✅ No redundant information
- ✅ Health Score still clearly visible as visual indicator
- ✅ Consistent with card design patterns
- ✅ Better visual hierarchy

---

## Technical Details

### File Modified

**src/app/(dashboard)/segmentation/page.tsx**

- Lines removed: 1010-1011 (duplicate Health Score text)
- Total change: 2 lines deleted

### Design Rationale

**Why Keep the Visual Bar Instead of Text?**

1. **Color Coding** - Visual bar provides instant health indication (green/yellow/red)
2. **Proportional Display** - Bar width shows relative score (easier to scan)
3. **Space Efficiency** - Takes up dedicated row below, not crowding header
4. **Consistency** - Compliance also shown as progress bar (matching pattern)

**Why Remove from Header Text?**

1. **Redundancy** - Same information shown twice
2. **Crowding** - Header line was too long with 3 data points
3. **Hierarchy** - CSE and NPS are more important for quick identification
4. **Readability** - Shorter header text is easier to scan

---

## Testing

### Manual Testing

- [x] Verified client cards display correctly
- [x] Header shows CSE and NPS only
- [x] Health Score progress bar still visible
- [x] No layout issues or alignment problems
- [x] Responsive on mobile (tested)

### Visual Comparison

**Before:** Header line ~40% longer, cluttered appearance
**After:** Header line clean, visual hierarchy improved

---

## Deployment

### Deployment Status

- ✅ Fix implemented and committed (commit e1028b1)
- ✅ Code compiles successfully
- ✅ No breaking changes
- ✅ UI improvement only (no functionality affected)

### Rollback Plan

If needed, revert commit e1028b1:

```bash
git revert e1028b1
```

---

## Related Issues

### Similar Patterns in Codebase

This same duplicate display pattern may exist in:

1. **Dashboard client cards** - Check if Health Score duplicated
2. **NPS page client list** - May have similar redundancy
3. **Other card components** - Audit for duplicate data displays

Recommend reviewing all client card displays for consistency.

---

## Files Modified

**Code:**

- `src/app/(dashboard)/segmentation/page.tsx` (lines 1010-1011 deleted)

**Documentation:**

- `docs/BUG-REPORT-DUPLICATE-HEALTH-SCORE-DISPLAY.md` (this file)

---

## Status

✅ **FIXED AND DEPLOYED**

**Commit:** e1028b1
**Branch:** main
**Date Fixed:** 2025-11-30
**Fixed By:** Claude Code

---

**Bug Report Created:** 2025-11-30
**Root Cause:** Redundant text display alongside visual progress bar
**Solution:** Removed duplicate text, kept visual bar for clarity
**Impact:** Cleaner UI with better visual hierarchy
