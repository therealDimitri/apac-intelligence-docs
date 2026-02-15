# Bug Report: Actions Not Displaying - RLS Policy Missing

**Date:** 2025-12-29
**Severity:** High
**Status:** Resolved

## Summary

The `/actions` page was showing 0 actions despite the `actions` table containing 140 records. The root cause was missing Row Level Security (RLS) policies for the `anon` role.

## Symptoms

- Actions page showing "0 actions"
- Console logs: `✅ Successfully fetched 0 actions from Supabase`
- Database contained 140 action records (verified via service role key)

## Root Cause

The `actions` table had RLS enabled but was missing policies for the `anon` role. The application uses the Supabase anonymous key for client-side queries, which requires explicit RLS policies to allow access.

**Before fix:**
- Service role key: ✅ Could access 140 records
- Anon key: ❌ Could access 0 records (blocked by RLS)

## Resolution

Applied RLS policies to allow anonymous access to the `actions` table:

```sql
-- Allow anon users to read all actions
CREATE POLICY "Allow anon read actions"
  ON public.actions
  FOR SELECT
  TO anon
  USING (true);

-- Allow anon users to create actions
CREATE POLICY "Allow anon insert actions"
  ON public.actions
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Allow anon users to update actions
CREATE POLICY "Allow anon update actions"
  ON public.actions
  FOR UPDATE
  TO anon
  USING (true)
  WITH CHECK (true);

-- Allow anon users to delete actions
CREATE POLICY "Allow anon delete actions"
  ON public.actions
  FOR DELETE
  TO anon
  USING (true);
```

## Verification

After applying the fix:
- Anon key: ✅ Can access 140 records
- Actions page displays all actions correctly

## Prevention

The migration file `docs/migrations/20251215_fix_actions_anon_rls_policies.sql` existed but had not been applied to the database. Future deployments should ensure all migration files are executed.

## Related Files

- `docs/migrations/20251215_fix_actions_anon_rls_policies.sql` - Migration file (should be applied)
- `docs/bug-reports/BUG-REPORT-ACTIONS-RLS-POLICY-BLOCKING.md` - Previous related RLS issue
