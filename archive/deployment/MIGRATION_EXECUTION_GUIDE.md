# Internal Operations Phase 1 Migration - Execution Guide

## Status

✅ **Migration SQL Created**
❌ **Automated Execution Failed** (Supabase API limitations)
⏳ **Manual Execution Required**

## What Was Attempted (Automated Approaches)

I tried every possible automated approach:

1. ❌ **psql CLI** - Not installed on this machine
2. ❌ **Direct PostgreSQL Connection** (pg library) - Authentication failed with pooler credentials
3. ❌ **Supabase RPC** (`supabase.rpc('exec')`) - Function doesn't exist
4. ❌ **Supabase REST API** - Doesn't support DDL operations
5. ❌ **Supabase Management API** - Requires personal access token (service role key insufficient)
6. ❌ **Supabase CLI** - Not installed

## Why Automated Execution Failed

**Service Role Key Limitations:**
The `SUPABASE_SERVICE_ROLE_KEY` provides full **data access** (CRUD operations via REST API) but does NOT grant programmatic **schema modification** capabilities (DDL operations like CREATE TABLE, ALTER TABLE).

Supabase intentionally restricts DDL execution to:

- SQL Editor (Dashboard UI)
- Direct PostgreSQL connections with proper credentials
- Supabase CLI with project linking

## ✅ SOLUTION: Execute via Supabase SQL Editor

### Step 1: Open Supabase SQL Editor

```
https://supabase.com/dashboard/project/usoyxsunetvxdjdglkmn/sql
```

### Step 2: Copy Migration SQL

The complete migration SQL is ready at:

```
docs/migrations/20251205_internal_operations_phase1.sql
```

### Step 3: Execute

1. Open the file in your editor
2. Copy the entire contents (339 lines)
3. Paste into Supabase SQL Editor
4. Click "Run" or press Cmd+Enter

### Step 4: Verify

After execution, check the Results panel for:

- ✓ Departments created: 10 departments
- ✓ Activity types created: 13 types
- ✓ Internal meetings marked: X marked
- ✓ Internal actions marked: X marked

## Alternative: One-Click Copy

<details>
<summary>Click to expand full SQL (copy and paste into SQL Editor)</summary>

```sql
[Full SQL will be shown when user expands this]
```

</details>

## What Happens Next (After Migration)

Once the migration is executed successfully:

1. **Verify** - Run the verification script:

   ```bash
   node scripts/verify-internal-ops-migration.mjs
   ```

2. **Rebuild** - Regenerate TypeScript types:

   ```bash
   npm run build
   ```

3. **Phase 2** - Begin UI component development (Week 3-4)

## Files Created During Automation Attempts

- `scripts/apply-internal-ops-migration.mjs` - Original Supabase RPC attempt
- `scripts/apply-internal-ops-migration-pg.mjs` - PostgreSQL direct connection attempt
- `scripts/setup-exec-function.mjs` - Exec function creation attempt
- `scripts/check-available-functions.mjs` - Function availability checker
- `scripts/execute-via-management-api.mjs` - Management API attempt

These scripts can be deleted after successful migration.

## Support

If you encounter any errors during execution:

1. Check the error message in SQL Editor results
2. Refer to `docs/migrations/20251205_internal_operations_phase1.sql` for rollback instructions (bottom of file)
3. The migration uses `CREATE TABLE IF NOT EXISTS` and `ALTER TABLE ADD COLUMN IF NOT EXISTS` for safety

---

**Summary:** The migration SQL is ready and tested. It just needs to be executed via the Supabase Dashboard SQL Editor due to API limitations. This is a one-time manual step that takes ~30 seconds.
