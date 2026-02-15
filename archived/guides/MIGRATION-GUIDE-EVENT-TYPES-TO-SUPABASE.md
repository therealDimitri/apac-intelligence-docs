# Migration Guide: Event Types from Excel to Supabase

**Date**: 2025-11-28
**Purpose**: Fix "No event data available" error in production
**Status**: Ready to execute

---

## Problem Summary

The Client Segmentation page shows "No event data available" in production because:

- Event type data is read from a local Excel file: `/Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth/...`
- This file doesn't exist on Netlify's production servers
- The Excel parser returns an empty array, causing the UI to show "No data available"

## Solution

Migrate event type data to Supabase database so it's accessible in both development and production.

---

## Migration Steps

### Step 1: Create Supabase Tables

1. **Open Supabase SQL Editor**:
   - Navigate to: https://supabase.com/dashboard/project/usoyxsunetvxdjdglkmn/sql
   - Or: Supabase Dashboard → SQL Editor

2. **Run the SQL script**:
   - Open file: `scripts/create_event_types_tables.sql`
   - Copy all SQL
   - Paste into Supabase SQL Editor
   - Click "Run" button

3. **Verify tables were created**:

   ```sql
   SELECT table_name
   FROM information_schema.tables
   WHERE table_schema = 'public'
   AND table_name LIKE 'segmentation_event%';
   ```

   Should return:
   - `segmentation_event_types`
   - `segmentation_event_compliance`

---

### Step 2: Run Migration Script Locally

This script reads from your local Excel file and populates Supabase.

1. **Ensure Excel file is accessible**:

   ```bash
   ls -lh "/Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth/APAC Clients - Client Success/Client Segmentation/APAC Client Segmentation Activity Register 2025.xlsx"
   ```

   Should show file size (not "0 bytes").

2. **Run migration script**:

   ```bash
   npx tsx scripts/migrate-events-to-supabase.ts
   ```

3. **Expected output**:

   ```
   🚀 Starting migration: Excel → Supabase
   =====================================

   🔧 Creating tables if they don't exist...
   ✅ Tables exist

   🧹 Clearing existing data...
   ✅ Cleared existing data

   📊 Reading event types from Excel...
   ✅ Found 12 event types in Excel

   💾 Inserting event types into Supabase...
      ✓ APAC Client Forum / User Group (300% complete)
        → Inserted 90 compliance records
      ✓ CE On-Site Attendance (207% complete)
        → Inserted 360 compliance records
      ...

   ✅ Migration complete!

   🔍 Verifying migration...
   ✅ Verified 12 event types
   ✅ Verified 1,080 compliance records

   📊 Sample data:
      • APAC Client Forum / User Group: 300% complete (15/5)
      • CE On-Site Attendance: 207% complete (62/30)
      • EVP Engagement: 264% complete (29/11)

   ✅ All done! Event type data is now in Supabase.
   ```

---

### Step 3: Verify Data in Supabase

1. **Check event types table**:

   ```sql
   SELECT
     name,
     frequency,
     priority,
     total_events,
     completed_events,
     completion_percentage
   FROM segmentation_event_types
   ORDER BY priority, name;
   ```

2. **Check compliance table**:

   ```sql
   SELECT
     COUNT(*) as total_records,
     COUNT(DISTINCT event_type_id) as event_types,
     COUNT(DISTINCT month) as months,
     COUNT(DISTINCT client_name) as clients
   FROM segmentation_event_compliance;
   ```

   Should show:
   - `total_records`: ~1,000+ (depends on Excel data)
   - `event_types`: 12
   - `months`: 12
   - `clients`: ~18 (depends on Excel data)

---

### Step 4: Deploy Updated Code

The code changes are already committed and ready:

1. **Commit message**: Will be created with bug report

2. **Files changed**:
   - `src/app/api/event-types/route.ts` - Updated to fetch from Supabase
   - `scripts/migrate-events-to-supabase.ts` - Migration script
   - `scripts/create_event_types_tables.sql` - SQL schema

3. **Deploy**:

   ```bash
   git add .
   git commit -m "fix: migrate event types to Supabase for production availability"
   git push origin main
   ```

4. **Netlify auto-deploys** within 2-3 minutes

---

### Step 5: Verify Production

1. **Navigate to**: https://apac-cs-dashboards.com/segmentation

2. **Check Event Type Visualization section**:
   - Should show event types with progress bars
   - Should display completion percentages
   - Should show monthly timeline data
   - Should have toggle buttons (Progress, Comparison, Monthly)

3. **Open browser console** (F12):
   ```
   [API /event-types] Fetching event type data...
   [API /event-types] Attempting to fetch from Supabase...
   [API /event-types] ✅ Fetched 12 event types from Supabase
   [EventTypeVisualization] Received 12 event types
   ```

---

## Architecture Changes

### Before (Excel-based)

```
Segmentation Page
  ↓
EventTypeVisualization Component
  ↓ fetch('/api/event-types')
/api/event-types API Route
  ↓ parseEventTypeData()
Excel Parser (fs.readFileSync)
  ↓
Local Excel File
  ❌ MISSING IN PRODUCTION
```

### After (Supabase-based)

```
Segmentation Page
  ↓
EventTypeVisualization Component
  ↓ fetch('/api/event-types')
/api/event-types API Route
  ├─ Try Supabase first ✅
  │   ↓
  │  Supabase Database
  │   ✅ AVAILABLE IN PRODUCTION
  │
  └─ Fallback to Excel (dev only)
      ↓
     Local Excel File (dev)
```

---

## Data Flow

### Production

1. User visits `/segmentation`
2. `EventTypeVisualization` component mounts
3. Fetches from `/api/event-types`
4. API route queries Supabase
5. Returns event types + compliance data
6. UI displays charts and progress bars

### Local Development

1. Same flow as production
2. If Supabase has data, uses it
3. If Supabase is empty, falls back to Excel file
4. Allows testing with live Excel data

---

## Database Schema

### `segmentation_event_types` Table

```sql
CREATE TABLE segmentation_event_types (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  frequency TEXT NOT NULL,
  team TEXT,
  priority TEXT,              -- 'high', 'medium', 'low'
  severity TEXT,              -- 'critical', 'warning', 'normal'
  total_events INTEGER,       -- Expected total across all segments
  completed_events INTEGER,   -- Actual completed
  remaining_events INTEGER,   -- total_events - completed_events
  completion_percentage NUMERIC,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
);
```

### `segmentation_event_compliance` Table

```sql
CREATE TABLE segmentation_event_compliance (
  id UUID PRIMARY KEY,
  event_type_id UUID REFERENCES segmentation_event_types(id),
  month TEXT NOT NULL,        -- e.g., "January", "February"
  client_name TEXT NOT NULL,  -- e.g., "SingHealth", "MinDef"
  completed BOOLEAN,          -- true/false
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  UNIQUE(event_type_id, month, client_name)
);
```

---

## Future Updates

### Option 1: Manual SQL Updates

Update event types directly in Supabase SQL Editor:

```sql
-- Update completion for a specific event
UPDATE segmentation_event_types
SET
  completed_events = 70,
  remaining_events = 30,
  completion_percentage = 70.0,
  updated_at = NOW()
WHERE name = 'CE On-Site Attendance';
```

### Option 2: Re-run Migration Script

If Excel file is updated:

```bash
npx tsx scripts/migrate-events-to-supabase.ts
```

This clears existing data and re-imports from Excel.

### Option 3: Build Admin UI

Create a management page to update event compliance directly in the dashboard:

- `/segmentation/admin` page
- Update completion status per client
- Mark events as complete
- View historical compliance

---

## Rollback Plan

If migration causes issues:

1. **Revert API route**:

   ```bash
   git revert HEAD
   git push origin main
   ```

2. **Falls back to Excel** (works in dev, shows "No data" in prod)

3. **Delete Supabase tables** (optional):
   ```sql
   DROP TABLE IF EXISTS segmentation_event_compliance CASCADE;
   DROP TABLE IF EXISTS segmentation_event_types CASCADE;
   ```

---

## Benefits

### ✅ Production Availability

- Data accessible from anywhere (not just local machine)
- No dependency on local Excel file
- Works on Netlify servers

### ✅ Performance

- Database queries faster than file parsing
- No Excel file reading overhead
- Indexed queries for compliance data

### ✅ Scalability

- Can add admin UI for direct updates
- Can automate data sync from other sources
- Can add historical tracking

### ✅ Reliability

- Data persists across deployments
- No file path issues
- Proper error handling

---

## Troubleshooting

### Migration script fails with "Tables don't exist"

**Solution**: Run SQL script in Supabase SQL Editor first (Step 1).

### Migration script shows "No event types found in Excel file"

**Causes**:

- Excel file path is wrong
- Excel file is on OneDrive cloud (not synced locally)
- Excel file is open (locked)

**Solution**:

```bash
# Check if file exists
ls -lh "/Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth/APAC Clients - Client Success/Client Segmentation/APAC Client Segmentation Activity Register 2025.xlsx"

# If file shows "0 bytes", it's a cloud placeholder
# Right-click → "Always Keep on This Device" in OneDrive
```

### Production still shows "No event data available"

**Causes**:

- Migration didn't run successfully
- Supabase tables are empty
- RLS policies blocking access

**Solution**:

1. Check Supabase table data (SQL query)
2. Check browser console for API errors
3. Verify RLS policies allow anon reads

### API returns "Supabase query error"

**Causes**:

- Table names wrong
- RLS policies too restrictive
- Environment variables missing

**Solution**:

1. Verify table names match exactly
2. Check RLS policies in Supabase
3. Ensure `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` are set

---

## Monitoring

### Check Production Logs

Netlify Functions logs will show:

```
[API /event-types] Fetching event type data...
[API /event-types] Attempting to fetch from Supabase...
[API /event-types] ✅ Fetched 12 event types from Supabase
```

Or if Supabase fails:

```
[API /event-types] Supabase error, falling back to Excel: ...
[API /event-types] ⚠️  No data available from either Supabase or Excel
```

### Supabase Dashboard

Monitor database queries:

- Dashboard → Logs → Database
- Should see SELECT queries from API route

---

## Success Criteria

- ✅ Migration script runs without errors
- ✅ Supabase has 12 event types in `segmentation_event_types`
- ✅ Supabase has 1,000+ records in `segmentation_event_compliance`
- ✅ Production segmentation page displays event data
- ✅ Progress bars show correct completion percentages
- ✅ Monthly timeline view shows client breakdown
- ✅ No console errors in production

---

## Conclusion

This migration moves event type data from a local Excel file to Supabase database, ensuring production availability and better scalability. The Excel file can still be used for local development and data updates, with a simple re-run of the migration script.

**Next Steps After Migration**:

1. Consider building an admin UI for direct data updates
2. Set up automated sync if Excel is regularly updated
3. Add audit logging for compliance changes
4. Implement data validation rules in Supabase
