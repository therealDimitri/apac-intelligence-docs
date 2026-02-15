# Bug Report: Comments Entity Type Constraint Error

**Date:** 12 January 2026
**Severity:** High
**Status:** Resolved

## Summary

When attempting to post comments on newly added PageComments components (compliance, financials, segmentation, etc.), the database rejected the insert with a constraint violation error.

## Error Message

```
PostgrestError: new row for relation "comments" violates check constraint "comments_entity_type_check"
```

## Root Cause

The `comments` table had a PostgreSQL CHECK constraint (`comments_entity_type_check`) that only allowed three entity types:
- `action`
- `meeting`
- `client`

When the PageComments component was added to new pages with entity types like `compliance`, `nps`, `support`, etc., the constraint blocked these inserts.

## Affected Components

- `/compliance` page - `entityType="compliance"`
- `/nps` page - `entityType="nps"`
- `/support` page - `entityType="support"`
- `/alerts` page - `entityType="alert"`
- `/team-performance` page - `entityType="team_performance"`
- `/financials` page - `entityType="financials"`
- `/aging-accounts` page - `entityType="aging_accounts"`
- `/segmentation` page - `entityType="segmentation"`
- `/planning/territory/*` pages - `entityType="territory_plan"`
- `/planning/account/*` pages - `entityType="account_plan"`

## Solution

Updated the database constraint to include all entity types defined in `src/types/comments.ts`:

```sql
ALTER TABLE comments DROP CONSTRAINT IF EXISTS comments_entity_type_check;
ALTER TABLE comments ADD CONSTRAINT comments_entity_type_check
CHECK (entity_type IN (
  'action', 'meeting', 'client', 'note', 'deal',
  'territory_plan', 'account_plan',
  'nps', 'support', 'compliance', 'alert', 'team_performance',
  'priority_matrix', 'aging_accounts', 'financials', 'segmentation', 'benchmarking',
  'page'
));
```

## Verification

After the fix:
1. Navigated to `/compliance` page
2. Expanded "Compliance Discussion" section
3. Posted test comment with rich text
4. Comment saved successfully to database
5. Real-time subscription updated UI immediately
6. Comment displayed with author, timestamp, and action buttons

## Prevention

When adding new entity types to the comments system:
1. Update `src/types/comments.ts` with the new type
2. Update the database constraint via Supabase SQL editor
3. Test comment posting on the affected page

## Related Files

- `src/types/comments.ts` - TypeScript entity type definitions
- `src/components/comments/PageComments.tsx` - Wrapper component
- Database: `comments` table constraint

## Commit Reference

- Feature commit: `c5dbb34e` - "feat: add PageComments to all dashboard and planning pages"
- Database fix: Applied directly to Supabase (no migration file)
