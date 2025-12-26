# Database Migrations

This directory contains SQL migrations for the APAC Intelligence application.

## How to Apply Migrations

Since Supabase doesn't support automated DDL execution via client libraries, migrations must be applied manually through the Supabase SQL Editor.

### Steps to Apply a Migration:

1. **Navigate to Supabase SQL Editor:**
   - URL: https://supabase.com/dashboard/project/usoyxsunetvxdjdglkmn/sql/new

2. **Open the migration file:**
   - Located in `docs/migrations/[migration-name].sql`

3. **Copy the SQL statements:**
   - Copy all CREATE INDEX / CREATE VIEW / ALTER TABLE statements

4. **Paste into SQL Editor:**
   - Paste the copied SQL into the editor

5. **Execute:**
   - Click the "Run" button
   - Verify success in the results panel

6. **Verify:**
   - Run the verification queries provided in each migration file

---

## Pending Migrations

### ✅ Ready to Apply

#### 1. `20251202_add_composite_indexes.sql`
**Status:** Ready
**Priority:** HIGH
**Time:** < 1 minute
**Risk:** Very Low (non-blocking, IF NOT EXISTS)

**SQL to Execute:**
```sql
CREATE INDEX IF NOT EXISTS idx_actions_client_status ON actions("Client", "Status");
CREATE INDEX IF NOT EXISTS idx_actions_owner_status ON actions("Owner", "Status");
CREATE INDEX IF NOT EXISTS idx_actions_due_date_status ON actions("Due_Date", "Status");
CREATE INDEX IF NOT EXISTS idx_events_client_date ON events(client_name, event_date);
CREATE INDEX IF NOT EXISTS idx_events_segment_type ON events(segment, event_type_id);
CREATE INDEX IF NOT EXISTS idx_meetings_client_date ON meetings(client, meeting_date);
```

**Verification Query:**
```sql
SELECT
  schemaname,
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE 'idx_%'
ORDER BY tablename, indexname;
```

**Expected Result:** 6 indexes listed (or more if other idx_ indexes exist)

**Performance Impact:**
- Actions queries: -75% query time
- Events queries: -75% query time
- Meetings queries: -75% query time

---

## Applied Migrations

*(None yet)*

---

## Migration Naming Convention

Format: `YYYYMMDD_description.sql`

Examples:
- `20251202_add_composite_indexes.sql`
- `20251202_create_client_health_materialized_view.sql`
- `20251202_create_compliance_view.sql`

---

## Safety Guidelines

1. **Always use IF NOT EXISTS** for CREATE statements
2. **Always use IF EXISTS** for DROP statements
3. **Test in development first** (if available)
4. **Backup critical data** before major schema changes
5. **Non-blocking operations** preferred (CREATE INDEX can run while app is live)
6. **Document rollback procedures** for each migration

---

## Troubleshooting

### Error: "relation already exists"
- Safe to ignore if using `IF NOT EXISTS`
- Index creation is idempotent

### Error: "column does not exist"
- Verify table schema matches expectation
- Check for typos in column names (case-sensitive)

### Error: "permission denied"
- Ensure using service role key (not anon key)
- Execute via Supabase SQL Editor (has full permissions)

---

## Helper Scripts

- **`scripts/apply-composite-indexes.mjs`**
  Displays SQL statements and instructions for composite indexes

- **`scripts/execute-indexes-via-api.sh`**
  Documents the limitation of API-based execution

---

## Contact

For questions about migrations, refer to:
- `docs/SUPABASE-OPTIMIZATION-ANALYSIS.md` - Full optimization analysis
- `docs/BUG-REPORT-*.md` - Bug reports and resolutions
