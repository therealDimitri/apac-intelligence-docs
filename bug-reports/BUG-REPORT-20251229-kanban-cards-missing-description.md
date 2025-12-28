# Bug Report: Kanban Cards Missing Description/Context

**Date:** 2025-12-29
**Severity:** Low
**Status:** Resolved

## Summary

Kanban board action cards were only displaying the action title and client name, but not the description/notes field, causing users to lack context about each action.

## Symptoms

- Kanban cards showed action title (e.g., "Schedule engagement meetings - Grampians Health")
- Cards showed client name with logo
- Cards showed priority, department, owner, and due date
- **Missing:** The description/notes field was not displayed

## Root Cause

The `DraggableCard` component in `src/components/KanbanBoard.tsx` was rendering the `action.title` field but not the `action.description` field. The data was correctly fetched from the database (`Notes` column mapped to `description`), but the UI simply didn't render it.

**Before fix (lines 451-456):**
```typescript
{/* Title */}
<p className={`font-medium ${isCompact ? 'text-xs' : 'text-sm'} text-gray-900 ...`}>
  {action.title}
</p>

{/* Client name with logo */}
```

## Resolution

Added description display after the title in the `DraggableCard` component:

```typescript
{/* Title */}
<p className={`font-medium ${isCompact ? 'text-xs' : 'text-sm'} text-gray-900 ...`}>
  {action.title}
</p>

{/* Description/Notes */}
{action.description && (
  <p className={`${isCompact ? 'text-[10px] line-clamp-1' : 'text-xs line-clamp-2'} text-gray-500 mt-0.5`}>
    {action.description}
  </p>
)}

{/* Client name with logo */}
```

The description is displayed with:
- Smaller font size than title (text-[10px] for compact, text-xs for comfortable)
- Gray colour (text-gray-500) for visual hierarchy
- Line clamping to prevent cards from becoming too tall
- Only rendered if description exists (conditional rendering)

## Verification

After applying the fix:
- Kanban cards now display the description/notes below the title
- Description is truncated appropriately based on view density
- Cards maintain their visual hierarchy with title prominent and description subdued

## Related Files

- `src/components/KanbanBoard.tsx` - DraggableCard component updated (line 458-465)
- `src/hooks/useActions.ts` - Maps `Notes` column to `description` field (line 180)
- `docs/bug-reports/BUG-REPORT-20251229-actions-not-displaying-rls.md` - Related RLS fix applied earlier

## Data Flow

```
Database: actions.Notes → useActions.ts: action.description → KanbanBoard.tsx: DraggableCard
```
