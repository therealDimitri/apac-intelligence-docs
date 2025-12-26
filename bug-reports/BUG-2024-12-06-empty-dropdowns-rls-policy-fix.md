# Bug Report: Empty Department & Activity Type Dropdowns in Edit Meeting Modal

**Date**: December 6, 2024
**Severity**: HIGH
**Status**: RESOLVED
**Component**: EditMeetingModal
**Database**: Supabase RLS Policies

---

## Summary

The Department and Activity Type dropdowns in the Edit Meeting Modal were displaying empty (no options) despite having valid data in the database. The root cause was Row Level Security (RLS) policies that blocked anonymous/public access to reference tables.

---

## Symptoms

1. **Department Dropdown**: Empty - showing "Select department..." placeholder but no options
2. **Activity Type Dropdown**: Empty - showing "Select activity type..." placeholder but no options
3. **Database Verification**: Confirmed 10 active departments and 13 active activity types exist
4. **No Error Messages**: Console showed no errors, queries succeeded but returned 0 records

---

## Impact

- **Users Affected**: All users attempting to edit meetings
- **Business Impact**: Unable to assign department or activity type to meetings
- **Scope**: Edit Meeting Modal completely non-functional for these fields
- **Duration**: Unknown (likely since RLS policies were applied on Dec 5, 2024)

---

## Root Cause Analysis

### Investigation Steps

1. **Database Verification** (Service Role Key)
   ```javascript
   // Using service role key - SUCCESSFUL
   const { data } = await supabase
     .from('departments')
     .select('code, name')
     .eq('is_active', true);
   // Result: 10 departments ✅
   ```

2. **Browser Client Testing** (Anonymous Key)
   ```javascript
   // Using anon key (what browser uses) - FAILED
   const anonSupabase = createClient(url, ANON_KEY);
   const { data } = await anonSupabase
     .from('departments')
     .select('code, name')
     .eq('is_active', true);
   // Result: 0 departments ❌
   ```

3. **RLS Policy Review**
   - Located in: `docs/migrations/20251205_internal_operations_rls.sql`
   - Lines 16-22 (departments), Lines 42-48 (activity_types)

   ```sql
   CREATE POLICY "Allow authenticated users to read departments"
   ON departments
   FOR SELECT
   TO authenticated  -- ❌ PROBLEM: Browser uses 'anon' role, not 'authenticated'
   USING (true);
   ```

### Root Cause

**RLS policies were configured for `authenticated` role, but browser clients use the `anon` (anonymous) role.**

- Supabase client-side code uses `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- This key has the `anon`/`public` role, NOT `authenticated`
- Existing policies: `TO authenticated` → blocks anon access
- Result: Queries succeed but return 0 records (no permission to see rows)

---

## Fix Applied

### Migration File Created
**File**: `docs/migrations/20251206_fix_reference_tables_rls_for_public_access.sql`

### SQL Applied
```sql
-- Fix departments table - add public/anon SELECT policy
DROP POLICY IF EXISTS "Allow public read access to departments" ON departments;
CREATE POLICY "Allow public read access to departments"
  ON departments
  FOR SELECT
  TO anon, public
  USING (true);

-- Fix activity_types table - add public/anon SELECT policy
DROP POLICY IF EXISTS "Allow public read access to activity_types" ON activity_types;
CREATE POLICY "Allow public read access to activity_types"
  ON activity_types
  FOR SELECT
  TO anon, public
  USING (true);
```

### Application Method
- SQL executed manually via Supabase Dashboard SQL Editor
- URL: https://supabase.com/dashboard/project/usoyxsunetvxdjdglkmn/sql/new
- Execution confirmed: "No rows returned" (expected for DDL statements)

---

## Verification Results

### Before Fix
- Departments accessible (anon key): 0 records ❌
- Activity types accessible (anon key): 0 records ❌

### After Fix
- Departments accessible (anon key): **10 records** ✅
- Activity types accessible (anon key): **13 records** ✅

### Sample Data Retrieved
**Departments**:
- People & Culture
- Finance & Corporate
- Clinical Excellence & Safety
- (7 more departments)

**Activity Types**:
- Quarterly Business Review
- Monthly Check-in
- Product Training
- (10 more types)

---

## Technical Details

### Affected Files
1. **EditMeetingModal.tsx** (lines 152-204)
   - `fetchDepartments()` useEffect hook
   - `fetchActivityTypes()` useEffect hook

2. **Database Tables**
   - `departments` table (10 active records)
   - `activity_types` table (13 active records)

3. **RLS Policies**
   - Original: `20251205_internal_operations_rls.sql`
   - Fix: `20251206_fix_reference_tables_rls_for_public_access.sql`

### Supabase Role Hierarchy
```
anon/public      → Client-side browser code (limited permissions)
authenticated    → Logged-in users (more permissions)
service_role     → Server-side admin access (bypasses RLS)
```

### Why This Happened
- Initial migration (Dec 5) created policies for `authenticated` users
- Frontend code uses `anon` key (standard for client-side Supabase)
- Assumption: Users would be authenticated when editing meetings
- Reality: Modal uses anonymous client before authentication context loads

---

## Lessons Learned

1. **Always test with anon key**: Reference tables accessed by browser must allow `anon` role
2. **RLS policy defaults**: Reference data (departments, types, categories) should default to public read
3. **Testing checklist**: Add "test with anon key" to migration verification
4. **Documentation**: Clearly document which role each RLS policy targets

---

## Prevention Measures

### For Future Reference Table Migrations

1. **Default RLS Template for Reference Tables**:
   ```sql
   -- Reference tables should allow public read by default
   CREATE POLICY "Allow public read access to [table_name]"
   ON [table_name]
   FOR SELECT
   TO anon, public  -- ✅ Always include both
   USING (true);
   ```

2. **Migration Checklist**:
   - [ ] Create RLS policy
   - [ ] Test with service role key
   - [ ] **Test with anon key** ← CRITICAL
   - [ ] Test in browser dev tools
   - [ ] Verify dropdown populations

3. **Standard Pattern**:
   - **Reference tables** (departments, types, categories): `TO anon, public`
   - **User data** (meetings, actions, notes): `TO authenticated`
   - **Sensitive data** (internal ops, financials): `TO authenticated` + row-level conditions

---

## Related Issues

- Original migration: `docs/migrations/20251205_internal_operations_rls.sql`
- Internal operations dropdowns also affected (same root cause)
- Same fix pattern applied to both reference tables

---

## References

### Scripts Created During Investigation
- `scripts/check-reference-tables-rls.mjs` - Verification script
- `scripts/fix-internal-ops-dropdowns-rls.mjs` - Automated fix attempt
- `scripts/apply-rls-policies-via-api.mjs` - API-based fix attempt
- `src/app/api/admin/apply-rls-policies/route.ts` - Next.js API route attempt

### Supabase Documentation
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Database Roles](https://supabase.com/docs/guides/database/postgres/roles)

---

## Status

**RESOLVED** ✅

- [x] Root cause identified
- [x] Migration created
- [x] SQL applied to production
- [x] Verified with anon key testing
- [x] Dropdowns now populate correctly
- [x] Bug report documented

---

**Resolution Date**: December 6, 2024
**Resolved By**: Claude Code
**Verification**: User confirmed + automated testing
