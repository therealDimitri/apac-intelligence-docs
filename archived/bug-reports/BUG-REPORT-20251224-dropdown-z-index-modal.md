# Bug Report: Dropdown Menus Not Visible in Modals

**Date:** 2025-12-24
**Status:** Fixed
**Severity:** High
**Affected Component:** `src/components/ui/Select.tsx`

---

## Summary

Dropdown menus (Select components) were not appearing when clicked inside modal dialogs. Users reported that "none of the dropdowns are working" in the meeting scheduling modals.

---

## Root Cause

The issue was a **z-index stacking context conflict** between modal overlays and dropdown portals:

| Component                                                       | z-index   | Behaviour                      |
| --------------------------------------------------------------- | --------- | ------------------------------ |
| Modal overlays (`UniversalMeetingModal`, `AIFirstMeetingModal`) | `z-[100]` | Creates fixed overlay          |
| Select dropdown (`SelectContent` via Radix UI Portal)           | `z-50`    | Renders at document body level |

Because `z-50 < z-[100]`, the dropdown content was rendering **behind** the modal overlay, making it invisible and seemingly non-functional.

### Technical Details

The Radix UI Select component uses a **Portal** to render the dropdown content at the document body level (outside the modal's DOM hierarchy). This is intentional to avoid clipping issues, but it means the dropdown's z-index must be higher than any overlapping elements.

```tsx
// SelectContent component - The problematic code
<SelectPrimitive.Portal>
  <SelectPrimitive.Content
    className={cn(
      'relative z-50 max-h-96 ...', // z-50 was too low
    )}
  >
```

---

## Fix Applied

Changed the z-index from `z-50` to `z-[200]` in `src/components/ui/Select.tsx`:

```tsx
// Before
'relative z-50 max-h-96 min-w-[8rem] overflow-hidden rounded-lg border border-gray-200 bg-white shadow-lg',

// After
'relative z-[200] max-h-96 min-w-[8rem] overflow-hidden rounded-lg border border-gray-200 bg-white shadow-lg',
```

This ensures dropdowns render above modals (`z-[100]`) whilst still being below any critical overlays that might use higher z-indices.

---

## Affected Areas

The fix resolves dropdown visibility in:

- **UniversalMeetingModal** - Client Name, Meeting Type, Duration selects
- **AIFirstMeetingModal** - All embedded selects
- **MeetingPreviewCard** - Duration select
- **Any modal** using the Select component throughout the application

---

## Testing Performed

1. Opened Briefing Room → New Meeting
2. Clicked "Create Manually" to open UniversalMeetingModal
3. Clicked Client Name dropdown → **Verified listbox appears above modal**
4. Selected "Epworth Healthcare" → **Verified selection works**
5. Confirmed dropdown closes properly after selection

---

## Prevention

When creating new modal components:

1. Use `z-[100]` or lower for modal overlays
2. Be aware that Portal-based components (dropdowns, tooltips, popovers) need higher z-indices
3. Test all interactive elements within modals before deployment

---

## Commit

```
fix: increase Select dropdown z-index to appear above modals
Commit: 4994ff1
```
