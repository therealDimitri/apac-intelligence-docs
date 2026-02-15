# Database Migration Guide - Client Segmentation Event Tracking System

**Date:** November 27, 2025
**Component:** Supabase Database Schema
**Required for:** Client Segmentation Event Tracking features to function

## Overview

The Client Segmentation Event Tracking System requires several database tables. Some tables already exist from the old dashboard backup (November 13, 2025), but the schema needs to be updated to match the new implementation.

## Current Database State

**✅ Exists with correct schema:**

- `segmentation_event_types` - 12 official event types (President/Group Leader, EVP, Strategic Ops, etc.)
- `nps_clients` - Client master data with segments
- `client_segmentation` - Segment change history (for deadline extension rule)

**⚠️ Exists but needs schema update:**

- `tier_event_requirements` - Currently uses `tier_id` foreign key, needs to be migrated to `segment` varchar

**❌ Missing (need to be created):**

- `segmentation_events` - Event tracking table
- `segmentation_event_compliance` - Pre-calculated compliance scores (optional, for caching)
- `segmentation_compliance_scores` - AI prediction results (optional, for historical tracking)

## Migration Steps

### Step 1: Access Supabase SQL Editor

1. Navigate to: https://supabase.com/dashboard/project/usoyxsunetvxdjdglkmn
2. Click on **SQL Editor** in the left sidebar
3. Create a **New Query**

### Step 2: Run Migrations in Order

**Execute each SQL file in this exact order:**

#### 2.1: Migrate tier_event_requirements Schema (REQUIRED)

**File:** `supabase/migrations/20251127_migrate_tier_requirements_schema.sql`

**What it does:**

- Backs up existing 72 rows to `tier_event_requirements_backup` table
- Drops old `tier_event_requirements` table
- Creates new table with `segment` (varchar) instead of `tier_id` (uuid)
- Adds indexes and RLS policies

**Action:**

1. Copy the entire contents of `20251127_migrate_tier_requirements_schema.sql`
2. Paste into Supabase SQL Editor
3. Click **Run** (or press Cmd+Enter)
4. Verify: Should see "Success. No rows returned"

#### 2.2: Seed Tier Requirements (REQUIRED)

**File:** `supabase/migrations/20251127_seed_tier_requirements.sql`

**What it does:**

- Populates `tier_event_requirements` with official Altera APAC requirements
- 72 rows covering all 6 segments × 12 event types
- Sets required counts per year and priority levels

**Action:**

1. Copy the entire contents of `20251127_seed_tier_requirements.sql`
2. Paste into Supabase SQL Editor
3. Click **Run**
4. Verify: Should see "Success. No rows returned" (inserts are silent)
5. Confirm data:
   ```sql
   SELECT segment, COUNT(*) FROM tier_event_requirements GROUP BY segment;
   ```
   Should return 12 rows per segment.

#### 2.3: Create segmentation_events Table (REQUIRED)

**File:** `supabase/migrations/20251127_add_event_tracking_schema.sql`

**What it does:**

- Creates `segmentation_events` table for tracking event completion
- Creates `segmentation_event_compliance` table for caching compliance calculations
- Creates `segmentation_compliance_scores` table for AI prediction history

**Action:**

1. Copy the entire contents of `20251127_add_event_tracking_schema.sql`
2. Paste into Supabase SQL Editor
3. Click **Run**
4. Verify: Should see "Success. No rows returned"

### Step 3: Verify Migration Success

Run these verification queries in Supabase SQL Editor:

```sql
-- 1. Verify tier_event_requirements schema
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'tier_event_requirements'
ORDER BY ordinal_position;

-- Should show: segment (varchar), event_type_id (uuid), required_count_per_year (integer), priority_level (varchar)

-- 2. Verify tier_event_requirements data
SELECT segment, COUNT(*) as event_types
FROM tier_event_requirements
GROUP BY segment
ORDER BY segment;

-- Should return 6 segments with 12 event types each (72 total rows)

-- 3. Verify segmentation_events table exists
SELECT COUNT(*) FROM segmentation_events;

-- Should return 0 (empty table, will be populated as events are scheduled)

-- 4. Verify all event types are seeded
SELECT event_code, event_name
FROM segmentation_event_types
ORDER BY event_code;

-- Should return 12 event types (PGL_ENGAGE, EVP_ENGAGE, STRAT_OPS, etc.)
```

### Step 4: Test in Application

After running migrations:

1. Navigate to: https://apac-cs-dashboards.com/segmentation
2. Click on any client card to expand event details
3. Verify:
   - Event types display (12 events per client based on segment)
   - Compliance percentages calculate correctly
   - "Schedule Event" button is functional
   - Expected vs Actual counts show correctly

## Rollback Plan (If Needed)

If something goes wrong, you can restore the old schema:

```sql
-- Restore old tier_event_requirements from backup
DROP TABLE IF EXISTS tier_event_requirements;
CREATE TABLE tier_event_requirements AS
SELECT * FROM tier_event_requirements_backup;

-- Drop new tables if they cause issues
DROP TABLE IF EXISTS segmentation_events CASCADE;
DROP TABLE IF EXISTS segmentation_event_compliance CASCADE;
DROP TABLE IF EXISTS segmentation_compliance_scores CASCADE;
```

**Note:** The backup table `tier_event_requirements_backup` is preserved for safety.

## Migration Files Location

All migration files are in:

```
/supabase/migrations/
├── 20251127_migrate_tier_requirements_schema.sql  (Run FIRST)
├── 20251127_seed_tier_requirements.sql            (Run SECOND)
├── 20251127_add_event_tracking_schema.sql         (Run THIRD)
└── 20251127_seed_event_types.sql                  (Optional - already applied)
```

## Expected Results After Migration

**Database Tables:**

- ✅ `tier_event_requirements` - 72 rows (6 segments × 12 event types)
- ✅ `segmentation_event_types` - 12 rows (official Altera APAC event types)
- ✅ `segmentation_events` - 0 rows initially (populated as events are scheduled)
- ✅ `tier_event_requirements_backup` - 72 rows (safety backup)

**Application Features Enabled:**

- ✅ Client event detail panels show 12 event types
- ✅ Compliance tracking calculates correctly
- ✅ AI predictions generate recommendations
- ✅ Event scheduling with deadline extension rule
- ✅ CSE workload view with compliance metrics

## Troubleshooting

### Issue: "relation tier_event_requirements already exists"

**Solution:** The migration script includes `DROP TABLE IF EXISTS`, so this shouldn't happen. If it does:

1. Verify you're running migrations in order
2. Check if the old backup table is interfering
3. Manually drop: `DROP TABLE tier_event_requirements CASCADE;`
4. Re-run migration

### Issue: "foreign key violation" when seeding

**Solution:** Ensure `segmentation_event_types` table has all 12 event types:

```sql
SELECT COUNT(*) FROM segmentation_event_types;
-- Should return 12
```

If less than 12, run: `supabase/migrations/20251127_seed_event_types.sql`

### Issue: "column segment does not exist" error in application

**Solution:** Migration Step 2.1 didn't complete successfully.

1. Check current schema:
   ```sql
   \d tier_event_requirements
   ```
2. If `tier_id` column exists, re-run Step 2.1
3. If `segment` column exists, the issue is elsewhere (check application code)

## Post-Migration Checklist

- [ ] All 3 migration SQL files executed successfully
- [ ] Verification queries return expected row counts
- [ ] Backup table `tier_event_requirements_backup` exists with 72 rows
- [ ] Application loads `/segmentation` page without errors
- [ ] Client event panels display 12 event types per client
- [ ] Compliance scores calculate correctly (not all 0%)
- [ ] "Schedule Event" modal opens and saves events
- [ ] CSE Workload View displays metrics correctly

## Support

If you encounter issues not covered in this guide:

1. Check browser console for client-side errors
2. Check Supabase logs for database errors
3. Verify environment variables (NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY)
4. Test API routes: `/api/events/schedule` should return 200 OK

---

**Migration Guide Version:** 1.0
**Last Updated:** November 27, 2025
**Deployment Commit:** d2cbb62
