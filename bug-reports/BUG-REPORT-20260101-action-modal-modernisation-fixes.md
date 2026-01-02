# Bug Report: Action Modal Modernisation Fixes

**Date:** 1 January 2026
**Status:** ✅ Resolved
**Severity:** Medium
**Component:** Actions Module - Modern Slide-Out Panels

---

## Issues Addressed

### 1. Priority Badge Ring Clipping

**Problem:** When selecting a priority in the ActionSlideOutCreate panel, the selection ring around the priority badge was being clipped at the top and bottom edges.

**Root Cause:** The container had `overflow-x-auto` which clipped the focus ring and selection indicator that extends beyond the button boundary.

**Solution:**
- Removed `overflow-x-auto` from the container
- Changed to `flex-nowrap` to prevent wrapping
- Added `py-1` padding to accommodate the selection ring
- Added `flex-shrink-0` to prevent buttons from compressing

**File Modified:** `src/components/modern-actions/PriorityChips.tsx`

```typescript
// Before
<div className={cn('flex flex-wrap gap-2 overflow-x-auto', className)}>

// After
<div className={cn('flex flex-nowrap gap-1.5 py-1', className)}>
```

---

### 2. Priority Badges Wrapping to Multiple Lines

**Problem:** Priority badges were wrapping to 2 lines instead of appearing on a single line.

**Root Cause:** The `flex-wrap` class allowed the badges to wrap when space was constrained.

**Solution:**
- Changed from `flex-wrap` to `flex-nowrap`
- Reduced gap from `gap-2` to `gap-1.5`
- Made buttons smaller with `px-2.5 py-1` and `text-xs`
- Added `whitespace-nowrap` and `flex-shrink-0` to buttons

**File Modified:** `src/components/modern-actions/PriorityChips.tsx`

---

### 3. Edit Action Using Legacy Modal

**Problem:** When clicking to edit an existing action, the old `ActionDetailModal` was displayed instead of the new modern slide-out panel design.

**Root Cause:** The actions page was still wired to use the legacy `ActionDetailModal` component for editing actions.

**Solution:**
1. Created new `ActionSlideOutEdit.tsx` component matching the design of `ActionSlideOutCreate`
2. Added `useActionSlideOutEdit` hook for managing open/close state
3. Replaced all `setSelectedAction(action)` calls with `actionEditSlideOut.open(action)`
4. Removed legacy `ActionDetailModal` from the page

**Files Created/Modified:**
- `src/components/modern-actions/ActionSlideOutEdit.tsx` (NEW)
- `src/components/modern-actions/index.ts` (updated exports)
- `src/app/(dashboard)/actions/page.tsx` (wired new component)

---

### 4. Description Field Not Required

**Problem:** The Description field was marked as "(optional)" and users could submit actions without a description.

**Solution:**
- Removed "(optional)" label from Description
- Added validation to check for content after stripping HTML tags
- Display error message "Description is required" when empty

**File Modified:** `src/components/modern-actions/ActionSlideOutCreate.tsx`

```typescript
// Added validation
const descriptionContent = descriptionRef.current?.getHTML() || formData.description
const strippedDescription = descriptionContent.replace(/<[^>]*>/g, '').trim()
if (!strippedDescription) {
  newErrors.description = 'Description is required'
}
```

---

### 5. Missing Rich Text Toolbar

**Problem:** The Description field didn't show the rich text formatting toolbar (bold, italic, @mentions, etc.).

**Solution:** Enabled the toolbar on the RichTextEditor component.

**File Modified:** `src/components/modern-actions/ActionSlideOutCreate.tsx`

```typescript
// Before
<RichTextEditor showToolbar={false} />

// After
<RichTextEditor showToolbar={true} />
```

---

### 6. Existing Actions Missing New Required Fields

**Problem:** Existing actions in the database were missing values for the new fields: `department_code`, `activity_type_code`, and `cross_functional`.

**Root Cause:** These fields were added as part of the modernisation but existing records had NULL values.

**Solution:** Created and executed a backfill script to populate default values.

**File Created:** `scripts/backfill-action-fields.mjs`

**Backfill Logic:**
- `department_code`: Set to 'CLIENT_SUCCESS'
- `activity_type_code`: Mapped from existing Category:
  - Meeting → STRATEGIC_REVIEW
  - General → SUPPORT
  - Planning → PLANNING
  - Escalation → SUPPORT
  - Documentation → REPORTING
  - Customer Success → CLIENT_ENABLEMENT
  - Support → SUPPORT
  - Technical → IMPLEMENTATION
  - Training → TRAINING
  - Review → STRATEGIC_REVIEW
  - Default → SUPPORT
- `cross_functional`: Set to false

**Result:** Successfully backfilled 132 actions.

---

## Testing Performed

1. ✅ Create new action - priority badges display on single line
2. ✅ Select priority - ring displays correctly without clipping
3. ✅ Submit without description - shows validation error
4. ✅ Rich text toolbar visible and functional
5. ✅ Click existing action - opens modern slide-out panel
6. ✅ Edit and save action - updates correctly
7. ✅ Delete action - removes from list
8. ✅ TypeScript compilation passes

---

## Related Files

- `src/components/modern-actions/PriorityChips.tsx`
- `src/components/modern-actions/ActionSlideOutCreate.tsx`
- `src/components/modern-actions/ActionSlideOutEdit.tsx`
- `src/components/modern-actions/index.ts`
- `src/app/(dashboard)/actions/page.tsx`
- `scripts/backfill-action-fields.mjs`

---

## Lessons Learned

1. **CSS overflow properties** can clip focus rings and selection indicators - always test interactive states
2. **Flexbox nowrap** is better than overflow-x-auto when you want single-line layouts
3. **Padding on containers** (not just buttons) is needed to accommodate focus rings
4. **Foreign key constraints** must be verified before running backfill scripts - query the database first to find valid codes
