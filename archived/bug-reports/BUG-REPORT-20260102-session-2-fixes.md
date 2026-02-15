# Bug Report: Session 2 Multiple Fixes - January 2, 2026

**Date:** 2026-01-02
**Severity:** Mixed (Low to Medium)
**Status:** Fixed

## Summary

This report covers the second batch of bug fixes and enhancements applied to the APAC Intelligence platform.

---

## 1. Tab Headings Cutoff in PageTabs

**Severity:** Low (UX)
**Issue:** Tab headings like "Team & Products" were wrapping to multiple lines
**Root Cause:** The button elements in PageTabs didn't have `whitespace-nowrap` to prevent wrapping
**Fix:** Added `whitespace-nowrap` to button className and `overflow-x-auto` to container

**File Modified:**
- `src/components/ui/enhanced/EnhancedTabs.tsx` (PageTabs component, line 196)

---

## 2. Health Score Modal Showing Old Formula

**Severity:** Medium
**Issue:** Health score modal displayed old formula (NPS 40, Compliance 50, WC 10) instead of new formula (NPS 20, Compliance 60, WC 10, Actions 10)
**Root Cause:** The `healthComponents` useMemo in LeftColumn.tsx was hardcoded with old values instead of using the health-score-config.ts values

**Fix:**
- Updated healthComponents calculation to use new formula (v4.0)
- Added Actions component to the calculation
- Updated modal UI to display 4 components instead of 3
- Updated tooltip text to reflect new percentages
- Updated colour thresholds for new point ranges:
  - NPS: 16 (green), 10 (yellow) for 20 max points
  - Compliance: 48 (green), 30 (yellow) for 60 max points

**File Modified:**
- `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`
  - Lines 474-551: Updated healthComponents calculation
  - Lines 881-886: Updated tooltip text
  - Lines 916-1035: Updated modal UI with 4 components

---

## 3. Comments/History Count Badges in ActionDetailPanel

**Severity:** Low (Enhancement)
**Issue:** Comments and History sections didn't show count badges like the Tags section
**Fix:**
- Added `useActionHistory` and `useComments` hooks to fetch counts
- Updated HistorySection and CommentsSection to accept `count` prop
- Added styled count badges matching the Tags section pattern

**File Modified:**
- `src/components/unified-actions/ActionDetailPanel.tsx`
  - Lines 57-59: Added hook imports
  - Lines 501-529: Updated HistorySection with count badge
  - Lines 553-585: Updated CommentsSection with count badge
  - Lines 632-642: Added hooks to fetch counts
  - Lines 919-923: Updated section calls with count props

---

## 4. Priority Matrix Tabs Already Present

**Severity:** N/A (Already Implemented)
**Finding:** The Priority Matrix DetailPanel already has tabs (Overview, History, Comments) with count badges
**Location:** `src/components/priority-matrix/detail/DetailPanel.tsx`

---

## 5. Priority Matrix Autoscroll Removed

**Severity:** Low (UX)
**Issue:** Clicking an item in Priority Matrix caused unwanted scroll to top of page
**Root Cause:** `handleItemClick` function was explicitly scrolling to top
**Fix:** Removed scroll logic from both `handleItemClick` and URL sync effect

**File Modified:**
- `src/components/priority-matrix/PriorityMatrix.tsx`
  - Lines 105-121: Removed scroll from URL sync effect
  - Lines 422-433: Removed scroll from handleItemClick

---

## Files Modified Summary

| File | Changes |
|------|---------|
| `src/components/ui/enhanced/EnhancedTabs.tsx` | Added whitespace-nowrap and overflow-x-auto to PageTabs |
| `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx` | Updated health score formula from v3.0 to v4.0, added Actions component |
| `src/components/unified-actions/ActionDetailPanel.tsx` | Added count badges to History and Comments sections |
| `src/components/priority-matrix/PriorityMatrix.tsx` | Removed autoscroll on item click and URL sync |

## Testing

All changes verified with TypeScript compilation (`npx tsc --noEmit`).

## Health Score Formula Comparison

| Component | Old (v3.0) | New (v4.0) |
|-----------|------------|------------|
| NPS Score | 40 pts (40%) | 20 pts (20%) |
| Segmentation Compliance | 50 pts (50%) | 60 pts (60%) |
| Working Capital | 10 pts (10%) | 10 pts (10%) |
| Actions | N/A | 10 pts (10%) |
| **Total** | **100 pts** | **100 pts** |
