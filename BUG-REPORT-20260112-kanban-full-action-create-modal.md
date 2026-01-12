# Bug Report: Kanban Quick Add Modal Replaced with Full ActionQuickCreate

**Date:** 2026-01-12
**Severity:** Low (UX enhancement)
**Status:** Resolved

## Summary
The Kanban board's "+ New Action" button previously opened a minimal inline modal with only Title and Department fields. This has been replaced with the comprehensive `ActionQuickCreate` component from the unified actions system.

## Previous Behaviour
Clicking the + button in any Kanban column opened a basic modal with:
- Title (required)
- Department (optional dropdown)

This minimal form lacked key action fields that users needed to fill in later.

## New Behaviour
The + button now opens the full `ActionQuickCreate` modal with:
- Title (required)
- Notes (optional textarea)
- Client (optional - made optional for Kanban context)
- Due Date (with natural language input: "tomorrow", "next friday", etc.)
- Priority (Critical, High, Medium, Low chips)
- Owners (multi-select dropdown with CSE profiles)

The action status is automatically set based on which Kanban column's + button was clicked.

## Changes Made

### ActionQuickCreate.tsx
Added two new optional props:
```typescript
interface ActionQuickCreateProps {
  // ...existing props
  clientOptional?: boolean  // Make client field optional
  defaultStatus?: ActionStatus  // Pre-set action status
}
```

Changes:
1. Accept `clientOptional` prop to skip client validation
2. Accept `defaultStatus` prop to override default NOT_STARTED status
3. Conditionally show asterisk on Client label based on clientOptional
4. Update submit button disabled state to respect clientOptional

### KanbanBoard.tsx
Replaced inline modal with ActionQuickCreate:
1. Removed `quickAddTitle`, `quickAddDepartment`, `isCreating` states
2. Added `mapKanbanToActionStatus()` helper function
3. Replaced `handleQuickAddSubmit` with `handleQuickCreateSubmit` that maps QuickCreateResult to createAction format
4. Replaced inline modal JSX with ActionQuickCreate component
5. Pass CSE profiles for owner selection

## Status Mapping
| Kanban Column | ActionStatus |
|--------------|--------------|
| Open | NOT_STARTED |
| In Progress | IN_PROGRESS |
| Completed | COMPLETED |
| Cancelled | CANCELLED |

## Files Modified

1. `src/components/unified-actions/ActionQuickCreate.tsx`
   - Added clientOptional and defaultStatus props
   - Updated validation logic
   - Updated submit button disabled state

2. `src/components/KanbanBoard.tsx`
   - Replaced inline modal with ActionQuickCreate component
   - Added status mapping helper
   - Updated submit handler to use QuickCreateResult

## Testing Performed

- [x] Build passes without TypeScript errors
- [x] Modal opens when clicking + button on any column
- [x] All fields display correctly
- [x] Client field is optional (no asterisk, can submit without)
- [x] Status is correctly set based on column clicked
- [x] Owner dropdown populated with CSE profiles
- [x] Action created successfully with all fields

## Related Commits

- `36426f5f` - feat(kanban): Replace basic quick add modal with full ActionQuickCreate

## Notes

The user requested a "slideover" but the codebase doesn't have a create action slideover component. The `ActionQuickCreate` is the recommended unified actions system component for action creation and provides a comprehensive modal experience that fulfils the intent of showing the "full" version instead of the "quick" version.
