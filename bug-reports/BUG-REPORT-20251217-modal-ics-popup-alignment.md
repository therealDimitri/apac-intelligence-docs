# Bug Report: Modal Z-Index and ICS Popup Alignment Issues

**Date:** 17 December 2025
**Severity:** Medium
**Status:** RESOLVED

## Problem Summary

When adding a meeting in the Briefing Room or syncing from Outlook, modals displayed incorrectly with two issues:

1. **Modal overlay not covering page elements** - The filter bar (CondensedStatsBar) and sidebar were appearing ON TOP of the modal overlay, making it look like the modal was partially behind the page content.

2. **ICS popup misaligned** - The ICS download popup at the bottom of meeting modals was not contained within the modal bounds.

## Root Causes

### Issue 1: Inconsistent Z-Index Hierarchy

The application had inconsistent z-index values across components:

- `CondensedStatsBar` used `z-[100]` for sticky positioning
- Modals used `z-50` for their overlays
- This caused sticky headers to appear ABOVE modal overlays

### Issue 2: Missing Position Context for ICS Popup

The ICS download popup in meeting modals used `position: absolute` with coordinates `bottom-6 left-6 right-6`. However, parent modal container `<div>` elements did not have `position: relative` set.

In CSS, absolutely positioned elements are positioned relative to their nearest positioned ancestor. Without `position: relative` on the modal container, the popup positioned itself relative to a different ancestor.

### Issue 3: Stacking Context Isolation

The OutlookSyncButton modal was rendered inline within the component hierarchy. Parent elements with CSS properties like `overflow: hidden`, `transform`, or `opacity` create new stacking contexts, which isolate z-index values. This caused the modal to remain behind sticky headers despite having a higher z-index value.

## Solution

### Fix 1: Standardise Modal Z-Index to `z-[100]`

Updated ALL modal overlays from `z-50` to `z-[100]` to ensure they always appear above sticky headers and other page elements.

### Fix 2: Lower CondensedStatsBar Z-Index

Changed the filter bar z-index from `z-[100]` to `z-40` to be consistent with other sticky headers.

### Fix 3: Add Position Context to Modal Containers

Added the `relative` CSS class to modal container `<div>` elements for proper ICS popup positioning.

### Fix 4: Use React Portal for OutlookSyncButton Modal

Added `createPortal` from `react-dom` to render the OutlookSyncButton modal directly to `document.body`. This escapes any parent stacking contexts, ensuring the modal always renders above all other page elements.

```tsx
// Before - rendered inline (affected by parent stacking contexts)
{
  showModal && <div className="fixed inset-0 z-[100] ...">...</div>
}

// After - rendered via portal to document.body
{
  mounted &&
    showModal &&
    createPortal(<div className="fixed inset-0 z-[100] ...">...</div>, document.body)
}
```

## Files Modified

### Modal Overlay Z-Index Updates (z-50 → z-[100])

| Component                 | File                                                                  | Line     |
| ------------------------- | --------------------------------------------------------------------- | -------- |
| OutlookSyncButton         | `src/components/OutlookSyncButton.tsx`                                | 194      |
| UniversalMeetingModal     | `src/components/UniversalMeetingModal.tsx`                            | 361      |
| QuickScheduleMeetingModal | `src/components/QuickScheduleMeetingModal.tsx`                        | 193      |
| ScheduleMeetingModal      | `src/components/schedule-meeting-modal.tsx`                           | 342      |
| ScheduleEventModal        | `src/components/ScheduleEventModal.tsx`                               | 130      |
| ChasenWelcomeModal        | `src/components/ChasenWelcomeModal.tsx`                               | 192      |
| EventDetailModal          | `src/components/EventDetailModal.tsx`                                 | 218      |
| ConfirmationModal         | `src/components/ConfirmationModal.tsx`                                | 98, 103  |
| EditActionModal           | `src/components/EditActionModal.tsx`                                  | 659      |
| KeyboardShortcutsModal    | `src/components/KeyboardShortcutsModal.tsx`                           | 27, 33   |
| FeedbackModal             | `src/components/FeedbackModal.tsx`                                    | 38       |
| OutlookImportModal        | `src/components/outlook-import-modal.tsx`                             | 266      |
| ActionDetailModal         | `src/components/ActionDetailModal.tsx`                                | 210      |
| ClientNPSTrendsModal      | `src/components/ClientNPSTrendsModal.tsx`                             | 201      |
| ReassignModal             | `src/components/priority-matrix/ReassignModal.tsx`                    | 40       |
| PriorityMatrix (mobile)   | `src/components/priority-matrix/PriorityMatrix.tsx`                   | 491      |
| GlobalSearch              | `src/components/GlobalSearch.tsx`                                     | 181, 190 |
| AddContactModal           | `src/components/AddContactModal.tsx`                                  | 83       |
| TopTopicsBySegment        | `src/components/TopTopicsBySegment.tsx`                               | 214      |
| LeftColumn (NPS Modal)    | `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx` | 785      |
| MeetingsPage (mobile)     | `src/app/(dashboard)/meetings/page.tsx`                               | 926      |
| ClientsPage (detail)      | `src/app/(dashboard)/clients/page.tsx`                                | 452      |
| SegmentationPage (detail) | `src/app/(dashboard)/segmentation/page.tsx`                           | 1216     |

### Sticky Header Z-Index Update

| Component         | File                                   | Line | Change             |
| ----------------- | -------------------------------------- | ---- | ------------------ |
| CondensedStatsBar | `src/components/CondensedStatsBar.tsx` | 138  | `z-[100]` → `z-40` |

### Position Context Updates

| Component                 | File                                           | Line |
| ------------------------- | ---------------------------------------------- | ---- |
| UniversalMeetingModal     | `src/components/UniversalMeetingModal.tsx`     | 362  |
| QuickScheduleMeetingModal | `src/components/QuickScheduleMeetingModal.tsx` | 194  |
| ScheduleMeetingModal      | `src/components/schedule-meeting-modal.tsx`    | 343  |

### React Portal Implementation

| Component         | File                                   | Change                                                  |
| ----------------- | -------------------------------------- | ------------------------------------------------------- |
| OutlookSyncButton | `src/components/OutlookSyncButton.tsx` | Added `createPortal` to render modal to `document.body` |

## Testing Verification

1. Build completed successfully with no TypeScript errors
2. Modal overlays now cover the entire page including sidebar and filter bar
3. ICS popup appears at the bottom of the modal, within the modal bounds
4. All 24 modals updated and verified

## Updated Z-Index Guidelines

Follow this z-index hierarchy for consistent layering:

| Layer           | Z-Index          | Usage                                           |
| --------------- | ---------------- | ----------------------------------------------- |
| Sticky headers  | `z-10` to `z-40` | Page headers, filter bars, sticky table headers |
| Dropdowns/Menus | `z-50`           | Dropdown menus, context menus, tooltips         |
| Sidebars        | `z-50`           | Slide-over panels, sidebars                     |
| **Modals**      | `z-[100]`        | **All modal overlays and containers**           |
| Notifications   | `z-[9999]`       | Toast notifications (highest priority)          |

## Prevention Guidelines

### For New Modals

1. Always use `z-[100]` for modal overlays
2. Add `position: relative` (or `relative` class) to modal content containers
3. Never use z-index values above `z-40` for sticky headers
4. **Use React Portal** (`createPortal`) to render modals to `document.body` to escape stacking contexts

### React Portal Pattern

```tsx
import { useState, useEffect } from 'react'
import { createPortal } from 'react-dom'

function MyModal({ isOpen }) {
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  if (!isOpen) return null

  return (
    mounted &&
    createPortal(
      <div className="fixed inset-0 z-[100] ...">{/* Modal content */}</div>,
      document.body
    )
  )
}
```

### For Absolutely Positioned Elements Inside Modals

1. Ensure the parent container has `position: relative`
2. Test popup/tooltip positions at different screen sizes
3. Verify z-index doesn't conflict with modal overlay

## Related Documentation

- See `docs/DATABASE_STANDARDS.md` for database-related guidelines
- See `docs/QUICK_REFERENCE.md` for quick development references
