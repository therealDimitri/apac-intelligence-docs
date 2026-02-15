# Bug Report: Priority Matrix Display and Assignment Enhancements

**Date:** 2025-12-31
**Severity:** Medium
**Status:** Fixed

## Issues Addressed

### 1. "2C 2 CSEs" Avatar Display Bug

**Issue:** Cards with multiple CSE assignments were displaying "2C" as avatar initials derived from the literal text "2 CSEs" instead of showing proper OwnerAvatarGroup with actual CSE photos.

**Root Cause:**
- The `deriveOwnerFromClientAssignments()` function in `utils.ts` was returning "X CSEs" (e.g., "2 CSEs") for multiple unique assignees
- This string was being stored in `item.metadata.owner`
- When components rendered, if `clientAssignments` wasn't passed correctly, they fell back to `metadata.owner` and `EnhancedAvatar` created "2C" initials from "2 CSEs"

**Solution:**
1. Updated `deriveOwnerFromClientAssignments()` to return `null` for multiple owners instead of "X CSEs" label
2. Added validation pattern in `MatrixItem.tsx` and `MatrixItemCompact.tsx` to detect and filter out legacy "X CSEs" patterns
3. Components now properly use `OwnerAvatarGroup` for multi-owner display when `clientAssignments` is available

### 2. "Financial" Label Should Be "BURC"

**Issue:** Items from the BURC file were displaying "Financial" as their source label, but users expected "BURC" to clearly identify the data source.

**Solution:**
1. Updated `formatTag()` in `utils.ts` to convert "financial" tag to "BURC" for display
2. Updated filter dropdown in `MatrixFilterBar.tsx` to show "💰 BURC" instead of "💰 Financial"
3. Updated `getFinancialTypeLabel()` fallback to return "BURC" instead of "Financial"

### 3. CSE Assignment Suggestions Not Using Smart Identification

**Issue:** The "Assign to Team Member" menu wasn't suggesting the client's assigned CSE first, even when the client-CSE relationship existed in the database.

**Root Cause:**
- The `getClientCSE()` function in `useAssignmentSuggestions.ts` used exact name matching
- Client names from matrix items often didn't match database names exactly (e.g., "WA Health" vs "Department of Health - Western Australia")

**Solution:**
Enhanced `getClientCSE()` with multi-level fuzzy matching:
1. Exact match (case-insensitive)
2. Partial match (name contains or is contained by search term)
3. Word-based matching for abbreviated names (e.g., "WA Health" matches client names containing both "WA"/"Western" and "Health")

### 4. Cards Without Owner Should Show "Unassigned Owner"

**Issue:** Cards that had no owner assigned were showing nothing in the owner section, making it unclear whether the item was unassigned or if data was missing.

**Solution:**
1. Added "Unassigned Owner" fallback display in `MatrixItem.tsx` and `MatrixItemCompact.tsx`
2. Shows a grey circle with "?" placeholder avatar
3. Displays italic "Unassigned Owner" text in grey
4. Provides clear visual indicator that the item needs owner assignment

## Files Modified

- `src/components/priority-matrix/utils.ts` - formatTag(), deriveOwnerFromClientAssignments(), getFinancialTypeLabel()
- `src/components/priority-matrix/MatrixItem.tsx` - Added pattern validation for owner display, "Unassigned Owner" fallback
- `src/components/priority-matrix/MatrixItemCompact.tsx` - Added pattern validation for owner display, "Unassigned Owner" fallback, BURC tag formatting
- `src/components/priority-matrix/MatrixFilterBar.tsx` - Updated filter dropdown label
- `src/components/priority-matrix/views/AgendaView.tsx` - Updated tag display to convert "financial" to "BURC"
- `src/hooks/useAssignmentSuggestions.ts` - Enhanced getClientCSE() with fuzzy matching

## Testing

1. **2C CSEs Bug:**
   - Open Priority Matrix with multi-client segmentation events
   - Verify cards show proper OwnerAvatarGroup with CSE photos, not "2C" initials

2. **BURC Label:**
   - View items from BURC/financial data source
   - Verify source badge shows "BURC" not "Financial"
   - Verify filter dropdown shows "💰 BURC"

3. **CSE Suggestions:**
   - Click "Assign to Team Member" on any client action
   - Verify the client's assigned CSE appears first in suggestions
   - Test with various client name formats (exact, partial, abbreviated)

4. **Unassigned Owner:**
   - View cards that have no owner assigned
   - Verify they display grey "?" avatar and italic "Unassigned Owner" text
   - Confirm this clearly distinguishes unassigned items from assigned ones

## Technical Notes

- The "financial" tag is still used internally for filtering purposes
- Only the display label is changed to "BURC"
- Fuzzy matching priority: exact > partial > word-based
- Word-based matching requires at least 2 matching words (or 1 for single-word searches)
