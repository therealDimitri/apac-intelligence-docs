# Bug Report: Action Slide-Out Panel UI Issues

**Date:** 1 January 2026
**Reported By:** User feedback with screenshots
**Status:** RESOLVED
**Severity:** Medium

## Issues Reported

### 1. Dropdown Font Size Too Large in ClientMultiSelect
**Problem:** The client selection dropdown text appeared too large compared to other compact UI elements.

**Root Cause:** Dropdown items were using `text-sm` (14px) with large padding.

**Fix Applied:**
- Reduced font from `text-sm` to `text-xs` (12px)
- Reduced padding from `px-4 py-2.5` to `px-3 py-2`
- Reduced gap between checkbox and text from `gap-3` to `gap-2`
- Reduced checkbox size from `w-5 h-5` to `w-4 h-4`
- Made client names truncate with `truncate` class

**File Modified:** `src/components/ClientMultiSelect.tsx`

---

### 2. Squashed Checkboxes in Collaboration Section
**Problem:** Checkboxes in the Collaboration section appeared squashed/compressed.

**Root Cause:** Checkbox inputs lacked proper flex-shrink-0 and sufficient sizing.

**Fix Applied:**
- Wrapped checkbox in `flex-shrink-0` container
- Increased checkbox size from `w-4 h-4` to `w-5 h-5`
- Added explicit `border-2` with colour
- Increased padding from `p-2.5` to `p-3`
- Added `focus:ring-offset-0` for better focus styling
- Added `cursor-pointer` for better UX

**File Modified:** `src/components/modern-actions/ActionSlideOutCreate.tsx`

---

### 3. Owner Lookup MS Graph Connection
**Status:** Already Working

**Investigation:** The Owner lookup field IS connected to MS Graph via the `/api/organization/people` endpoint which uses:
- `searchOrganizationUsers()` for search queries
- `fetchOrganizationPeople()` for frequently contacted people
- Requires `People.Read` permission (granted by admin)

**File Location:** `src/app/api/organization/people/route.ts`

**Note:** If no results appear, check:
1. User authentication status
2. MS Graph People.Read permission
3. Network connectivity to Microsoft Graph API

---

### 4. Due Date Calendar View Not Visible
**Problem:** The calendar icon existed but clicking it didn't obviously trigger a calendar picker.

**Root Cause:** Native date input had `opacity-0` making the clickable area invisible.

**Fix Applied:**
- Restructured the date picker trigger with proper layering
- Added hover states to calendar icon: `hover:text-purple-600 hover:bg-purple-50`
- Made the invisible date input cover the visible icon button
- Added `z-10` to ensure clickable area is on top
- Added rounded corners and padding to the icon button

**File Modified:** `src/components/modern-actions/NaturalLanguageDateInput.tsx`

**Note:** The native browser date picker will open when clicking the calendar icon. The appearance varies by browser (Chrome shows a calendar grid, Safari shows a wheel picker).

---

### 5. Create Action Button Hidden by ChaSen Icon
**Problem:** The floating ChaSen AI icon in the bottom-right corner overlapped with the "Create Action" button in the footer.

**Root Cause:** Footer had uniform padding that didn't account for the floating icon.

**Fix Applied:**
- Changed footer padding from `px-4` to `px-4 pr-20`
- This adds 80px right padding to avoid the floating icon

**File Modified:** `src/components/modern-actions/ActionSlideOutCreate.tsx`

---

## Summary of Changes

| Component | Change | Before | After |
|-----------|--------|--------|-------|
| ClientMultiSelect | Font size | text-sm (14px) | text-xs (12px) |
| ClientMultiSelect | Checkbox size | w-5 h-5 | w-4 h-4 |
| ClientMultiSelect | Item padding | px-4 py-2.5 | px-3 py-2 |
| ActionSlideOutCreate | Checkbox wrapper | Direct | flex-shrink-0 container |
| ActionSlideOutCreate | Checkbox size | w-4 h-4 | w-5 h-5 |
| ActionSlideOutCreate | Footer padding | px-4 | px-4 pr-20 |
| NaturalLanguageDateInput | Calendar icon | Static | Hover states with bg |

## Testing Checklist

- [x] TypeScript compilation passes
- [ ] ClientMultiSelect dropdown shows smaller, more compact text
- [ ] Checkboxes in Collaboration section properly sized
- [ ] Calendar icon highlights on hover
- [ ] Clicking calendar icon opens native date picker
- [ ] Create Action button visible (not hidden by ChaSen)
- [ ] Owner search returns MS Graph results when authenticated

## Files Modified

1. `src/components/ClientMultiSelect.tsx`
2. `src/components/modern-actions/ActionSlideOutCreate.tsx`
3. `src/components/modern-actions/NaturalLanguageDateInput.tsx`
