# Bug Report: CSE Dropdown Styling Mismatch

**Date**: 17 January 2026
**Severity**: Low
**Status**: Fixed
**Affected Areas**: Strategic Plan Wizard - Setup Context Step

---

## Summary

The CSE dropdown in the Setup Context step of the Strategic Plan wizard had inconsistent styling compared to the Territory/Region input field. The dropdown used a lighter border colour and default browser select styling, making the form appear inconsistent.

---

## Root Cause

**File**: `src/app/(dashboard)/planning/strategic/new/steps/SetupContextStep.tsx`
**Lines**: 87-107

The CSE `<select>` element had different styling properties than the Territory/Region `<input>`:

| Property | CSE Dropdown (Before) | Territory/Region |
|----------|----------------------|------------------|
| Border | `border-gray-100` | `border-gray-200` |
| Focus | Default ring style | No visible ring |
| Chevron | Browser default | N/A (input field) |

---

## Solution

Updated the CSE dropdown to match the Territory/Region field styling:

### Before
```tsx
<select
  className="w-full px-3 py-2 border border-gray-100 rounded-lg bg-gray-50 focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
>
```

### After
```tsx
<select
  className="w-full px-3 py-2 border border-gray-200 rounded-lg bg-gray-50 focus:outline-none focus:ring-0 disabled:bg-gray-100 disabled:cursor-not-allowed appearance-none cursor-pointer"
  style={{
    backgroundImage:
      "url(\"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3E%3Cpath stroke='%236b7280' stroke-linecap='round' stroke-linejoin='round' stroke-width='1.5' d='m6 8 4 4 4-4'/%3E%3C/svg%3E\")",
    backgroundPosition: 'right 0.5rem center',
    backgroundRepeat: 'no-repeat',
    backgroundSize: '1.5em 1.5em',
    paddingRight: '2.5rem',
  }}
>
```

### Changes Made
1. **Border colour**: Changed from `border-gray-100` to `border-gray-200`
2. **Focus styling**: Replaced `focus:ring-2 focus:ring-indigo-500 focus:border-transparent` with `focus:outline-none focus:ring-0`
3. **Native select override**: Added `appearance-none` to remove browser default styling
4. **Custom chevron**: Added SVG chevron via `backgroundImage` for consistent cross-browser appearance
5. **Cursor**: Added `cursor-pointer` for better UX indication
6. **Disabled states**: Added `disabled:bg-gray-100 disabled:cursor-not-allowed`

---

## Files Modified

| File | Changes |
|------|---------|
| `src/app/(dashboard)/planning/strategic/new/steps/SetupContextStep.tsx` | Updated CSE dropdown className and added inline styles for custom chevron |

---

## Verification Steps

1. Navigate to Planning Hub → Create New Plan
2. View the Setup Context step
3. Compare CSE dropdown and Territory/Region input field styling
4. Verify both fields have:
   - Matching border colour (gray-200)
   - Consistent background (gray-50)
   - Similar visual weight
5. Click the CSE dropdown to verify custom chevron displays correctly
6. Test disabled state matches between both fields

---

## Before/After Comparison

**Before fix:**
- CSE dropdown had lighter border (gray-100)
- Default browser select styling with blue focus ring
- Inconsistent appearance with Territory/Region field

**After fix:**
- Both fields have matching gray-200 border
- CSE dropdown has custom chevron matching design system
- No jarring focus ring on select
- Consistent disabled state styling

---

## Related Commits

- `fec05197` - Fix CSE dropdown styling to match Territory/Region field

---

## Prevention

To prevent similar styling inconsistencies:
1. Create reusable form field components (e.g., `<SelectField>`, `<InputField>`)
2. Use shared className constants for form elements
3. Review form UX holistically when adding new fields
4. Add visual regression tests for form components
