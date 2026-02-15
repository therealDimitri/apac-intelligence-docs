# Bug Report: Action Modal UI Polish

**Date:** 1 January 2026
**Status:** ✅ Resolved
**Severity:** Low
**Component:** Actions Module - Modern Slide-Out Panels

---

## Issues Addressed

### 1. Footer Formatting Squashed When Required Field Missing

**Problem:** When a required field validation error occurred, the footer appeared squashed with the keyboard shortcut "⌘↵ to save" appearing on two lines.

**Root Cause:** The footer container was using basic flex without proper nowrap and sizing constraints.

**Solution:**
- Added `whitespace-nowrap` to prevent text wrapping
- Added `flex-shrink-0` to prevent compression
- Increased gap from `gap-2` to `gap-3` for better spacing
- Added `flex items-center gap-1.5` wrapper for keyboard hint
- Updated error badge padding to `px-2.5 py-1` for better visibility

**Files Modified:**
- `src/components/modern-actions/ActionSlideOutCreate.tsx`
- `src/components/modern-actions/ActionSlideOutEdit.tsx`

---

### 2. Missing Activity Type: Deal/Renewal Prep (Internal)

**Problem:** The Activity Type dropdown was missing a "Deal/Renewal Prep (Internal)" option needed for internal deal and renewal preparation activities.

**Solution:** Created and executed a script to add the new activity type to the database.

**File Created:** `scripts/add-deal-renewal-activity-type.mjs`

**Database Change:**
```json
{
  "id": 14,
  "code": "DEAL_RENEWAL_PREP",
  "name": "Deal/Renewal Prep",
  "description": "Preparation activities for deals and renewals",
  "category": "internal_ops",
  "shows_on_client_profile": false,
  "color": "amber",
  "is_active": true,
  "sort_order": 14
}
```

---

### 3. Client and Owner Fields Not Horizontally Aligned

**Problem:** The Client and Owner fields appeared misaligned due to different help text lengths below each field.

**Root Cause:**
- ClientMultiSelect displayed: "Select multiple clients or type custom names"
- PeopleSearchInput displayed: "Search for people in your organisation or type a name and press Enter"

**Solution:**
1. Added `hideHelpText` prop to both components
2. Set `hideHelpText={true}` in the action slide-out panels
3. Added `items-start` to the grid container for proper alignment

**Files Modified:**
- `src/components/ClientMultiSelect.tsx` - Added `hideHelpText` prop
- `src/components/PeopleSearchInput.tsx` - Added `hideHelpText` prop
- `src/components/modern-actions/ActionSlideOutCreate.tsx` - Applied `hideHelpText={true}`
- `src/components/modern-actions/ActionSlideOutEdit.tsx` - Applied `hideHelpText={true}`

---

### 4. Missing Teams Icon on Post to Microsoft Teams Toggle

**Problem:** The "Post to Microsoft Teams" toggle was missing an icon, unlike the "Cross-Functional Collaboration" toggle which had a Network icon.

**Solution:** Added the `Send` icon from lucide-react to the Teams toggle, matching the styling of the Cross-Functional Collaboration toggle.

**Files Modified:**
- `src/components/modern-actions/ActionSlideOutCreate.tsx`
- `src/components/modern-actions/ActionSlideOutEdit.tsx`

```tsx
<div className="flex items-center gap-2 flex-1 min-w-0">
  <Send className="h-4 w-4 text-purple-600 flex-shrink-0" />
  <span className="text-sm font-medium text-gray-700 dark:text-gray-300">
    Post to Microsoft Teams
  </span>
</div>
```

---

### 5. Activity Type Dropdown Not Sorted Alphabetically

**Problem:** The Activity Type dropdown displayed items in database order (by sort_order column) rather than alphabetically, making it harder to find specific activity types.

**Solution:** Updated the ActivityTypeSelector component to sort options alphabetically by name before display.

**File Modified:** `src/components/internal-ops/ActivityTypeSelector.tsx`

```typescript
// Sort alphabetically by name
[...activityTypes]
  .sort((a, b) => a.name.localeCompare(b.name))
  .map(activityType => ...)
```

---

## Testing Performed

1. ✅ Footer displays correctly with validation errors - no line wrapping
2. ✅ "Deal/Renewal Prep" appears in Activity Type dropdown under Internal category
3. ✅ Client and Owner fields are horizontally aligned without help text
4. ✅ Teams toggle displays Send icon in purple colour
5. ✅ Activity Type dropdown sorted alphabetically (Deal/Renewal Prep, Governance, Health Check, etc.)
6. ✅ TypeScript compilation passes with no errors

---

## Related Files

- `src/components/modern-actions/ActionSlideOutCreate.tsx`
- `src/components/modern-actions/ActionSlideOutEdit.tsx`
- `src/components/ClientMultiSelect.tsx`
- `src/components/PeopleSearchInput.tsx`
- `src/components/internal-ops/ActivityTypeSelector.tsx`
- `scripts/add-deal-renewal-activity-type.mjs`

---

## Database Changes

Added new record to `activity_types` table:
- Code: `DEAL_RENEWAL_PREP`
- Name: `Deal/Renewal Prep`
- Category: `internal_ops`
