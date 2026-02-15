# Bug Report: Bulk Delete Actions Failing Silently

**Date**: 2025-12-16
**Severity**: High
**Status**: Fixed
**Commit**: `c64b287`

## Summary

Bulk delete and bulk complete operations on the Actions page were failing silently. Users could select multiple actions and click "Delete" or "Mark Complete", but the operations would fail without any visible change to the data.

## Symptoms

1. User selects multiple actions using checkboxes
2. User clicks "Delete" button and confirms the dialog
3. Alert shows "Failed to delete actions: Unknown error"
4. Actions remain unchanged in the database

## Root Cause Analysis

The bug was caused by a **column name mismatch** between the TypeScript code and the database schema.

### The Issue

The `actions` table has two different ID columns:

- `id` (integer) - Auto-incrementing primary key
- `Action_ID` (text) - Human-readable identifier (e.g., "ACT-001")

In `useActions.ts`, the Action interface's `id` field is populated from `Action_ID`:

```typescript
// Line 158 in useActions.ts
id: action.Action_ID || `action-${Date.now()}-${Math.random()}`
```

However, the bulk operations were querying the wrong column:

```typescript
// BEFORE (incorrect)
.in('id', idsToDelete)  // Querying integer 'id' column with text values
```

Since "ACT-001" cannot match an integer column, Supabase returned 0 affected rows (silent failure due to RLS and no match).

### Additional Issue

The bulk complete was also using lowercase `status` instead of `Status` (PascalCase):

```typescript
// BEFORE (incorrect)
.update({ status: 'completed', ... })

// AFTER (correct)
.update({ Status: 'Completed', ... })
```

## Fix Applied

### File: `src/app/(dashboard)/actions/page.tsx`

**Bulk Complete:**

```typescript
// BEFORE
const { error } = await supabase
  .from('actions')
  .update({ status: 'completed', updated_at: new Date().toISOString() })
  .in('id', Array.from(selectedActionIds))

// AFTER
const { error } = await supabase
  .from('actions')
  .update({ Status: 'Completed', updated_at: new Date().toISOString() })
  .in('Action_ID', Array.from(selectedActionIds))
```

**Bulk Delete:**

```typescript
// BEFORE
const idsToDelete = Array.from(selectedActionIds).map(id =>
  typeof id === 'string' ? parseInt(id, 10) : id
)
const { error, count } = await supabase.from('actions').delete().in('id', idsToDelete)

// AFTER
const idsToDelete = Array.from(selectedActionIds)
const { error, count } = await supabase.from('actions').delete().in('Action_ID', idsToDelete)
```

## Verification

1. TypeScript compilation passed
2. ESLint checks passed
3. Node.js test script confirmed delete works with anon key
4. RLS policies for anon role were added in previous fix

## Lessons Learned

1. **Always verify column names against database-schema.md** before writing queries
2. **Be aware of ID mapping** - The TypeScript interface `id` field may not map to the database `id` column
3. **Check column case sensitivity** - Supabase columns are case-sensitive (`Status` vs `status`)
4. **Silent failures are common** - When RLS policies are in place or column names don't match, Supabase often returns success with 0 affected rows

## Related Files

- `src/app/(dashboard)/actions/page.tsx` - Contains bulk operations
- `src/hooks/useActions.ts` - Maps Action_ID to id field
- `docs/database-schema.md` - Database schema reference
- `docs/migrations/20251215_fix_actions_anon_rls_policies.sql` - RLS policy fix (applied separately)

## Prevention

This type of bug can be prevented by:

1. Running `npm run validate-schema` before commits
2. Following the Database Column Verification Rules in CLAUDE.md
3. Adding explicit comments when ID columns don't map directly
