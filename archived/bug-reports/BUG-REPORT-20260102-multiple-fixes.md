# Bug Report: Multiple UI/UX Fixes - January 2, 2026

**Date:** 2026-01-02
**Severity:** Mixed (Low to Medium)
**Status:** Fixed

## Summary

This report covers multiple bug fixes and enhancements applied to the APAC Intelligence platform.

---

## 1. Add Contact Modal Not Displaying Correctly

**Severity:** Medium
**Root Cause:** The RightColumn container uses `overflow-hidden` which affected `position: fixed` modals
**Fix:** Used React's `createPortal` to render the AddContactModal directly in `document.body`, escaping the overflow container

**File Modified:**
- `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx`

---

## 2. Products Card Moved to Team Tab

**Severity:** Low (Enhancement)
**Change:** Moved ProductsSection from LeftColumn to RightColumn, renamed tab from "Team" to "Team & Products"

**Files Modified:**
- `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx` - Removed ProductsSection
- `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx` - Added ProductsSection to Team tab

---

## 3. Comments Tab Added to Action Detail Slide-Over

**Severity:** Low (Enhancement)
**Change:** Added a collapsible Comments section to the ActionDetailPanel using the existing UnifiedComments component

**File Modified:**
- `src/components/unified-actions/ActionDetailPanel.tsx`

---

## 4. History/Related Actions Not Displaying

**Severity:** Medium
**Root Cause:** The HistorySection and RelatedActionsSection were collapsed by default (`isExpanded = false`)
**Fix:** Changed default state to expanded (`isExpanded = true`)
**Note:** Database tables (`action_activity_log`, `action_relations`) already existed; the issue was UX-related

**File Modified:**
- `src/components/unified-actions/ActionDetailPanel.tsx`

**Migration Created:**
- `docs/migrations/20260102_action_activity_and_relations.sql` (for reference if tables need recreation)

---

## 5. Priority Matrix Autoscroll Removed

**Severity:** Low (Enhancement)
**Change:** Removed autoscroll behaviour when opening/closing the slide-over detail panel, as it's now redundant with the slide-over UX

**Files Modified:**
- `src/components/priority-matrix/PriorityMatrix.tsx` - Removed scroll-back-to-card logic in `handleCloseDetail`
- `src/components/priority-matrix/views/SlideOverDetail.tsx` - Removed scroll-into-view on panel open

---

## 6. Health Score Weightings Verification

**Severity:** N/A (Already Correct)
**Requested Weights:** NPS=20, Compliance=60, WC=10, Actions=10
**Current Configuration:** Already configured correctly in `src/lib/health-score-config.ts` (version 4.0)

---

## Files Modified Summary

| File | Changes |
|------|---------|
| `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx` | Added portal for AddContactModal, added ProductsSection to Team tab, renamed tab |
| `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx` | Removed ProductsSection |
| `src/components/unified-actions/ActionDetailPanel.tsx` | Added CommentsSection, set History/Related sections to expanded by default |
| `src/components/priority-matrix/PriorityMatrix.tsx` | Removed autoscroll on detail close |
| `src/components/priority-matrix/views/SlideOverDetail.tsx` | Removed autoscroll on panel open |

## Testing

All changes verified with TypeScript compilation (`npx tsc --noEmit`).
