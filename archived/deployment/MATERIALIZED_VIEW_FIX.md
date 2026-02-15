# Event Compliance Materialized View Fix

## Problem Identified

The dashboard shows **0% completion for all event types** even though events are completed in the database.

### Root Cause

1. **Duplicate Event Types**: SA Health (iPro) has a segment change (Nurture → Collaboration)
2. **Current View Logic**: Creates separate requirements for each segment period
3. **Result**: Each event type appears TWICE in the materialized view:
   - First occurrence: 0 events (wrong)
   - Second occurrence: actual events (correct)
4. **Dashboard Bug**: Shows the first occurrence (0 events) instead of the correct one

### Example from SA Health (iPro)

```
SLA/Service Review Meeting:
  #1: 0 of 4 completed (0%) ← Dashboard shows this ❌
  #17: 7 of 4 completed (175%) ← Should show this ✅

Updating Client 360:
  #4: 0 of 8 completed (0%) ← Dashboard shows this ❌
  #15: 12 of 8 completed (150%) ← Should show this ✅
```

## Solution

The fixed materialized view:

1. **Reads segment change history** from `client_segmentation` table
2. **Combines tier requirements** across all segment periods (Nurture + Collaboration)
3. **Deduplicates event types** (takes MAX required_count if event in multiple tiers)
4. **Counts ALL events** for the year regardless of which segment period
5. **Result**: Each event type appears only ONCE with correct total counts

## How to Apply the Fix

### Option 1: Run SQL in Supabase Dashboard (Recommended)

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Copy the contents of this file:
   ```
   docs/migrations/20251202_fix_event_compliance_view_segment_changes.sql
   ```
4. Paste into SQL Editor
5. Click **Run**

### Option 2: Use psql Command Line

```bash
# Use your DATABASE_URL from .env.local
psql "$DATABASE_URL" -f docs/migrations/20251202_fix_event_compliance_view_segment_changes.sql
```

## Expected Results After Fix

For SA Health (iPro):

- **SLA/Service Review Meeting**: 7 of 4 completed (175%) ✅
- **Updating Client 360**: 12 of 8 completed (150%) ✅
- **Insight Touch Point**: 19 of 12 completed (158%) ✅
- **CE On-Site Attendance**: 7 of 2 completed (350%) ✅
- **Strategic Ops Plan**: 2 of 2 completed (100%) ✅
- **Upcoming Release Planning**: 2 of 2 completed (100%) ✅

**No more duplicates!** Each event type appears only once.

## Verification Queries

After running the migration, verify with these queries:

```sql
-- Check SA Health (iPro) no longer has duplicates
SELECT
  client_name,
  year,
  segment,
  overall_compliance_score,
  json_array_length(event_compliance) as event_type_count
FROM event_compliance_summary
WHERE client_name = 'SA Health (iPro)'
  AND year = 2025;

-- Expected: ~9-10 unique event types, not 18 duplicates
```

```sql
-- View all events for SA Health (iPro)
SELECT
  jsonb_pretty(event_compliance::jsonb)
FROM event_compliance_summary
WHERE client_name = 'SA Health (iPro)'
  AND year = 2025;

-- Expected: Each event type appears once with actual counts
```

## Files Modified

1. **New Migration**: `docs/migrations/20251202_fix_event_compliance_view_segment_changes.sql`
   - Drops and recreates the materialized view with segment change support
   - Adds deduplication logic for event types
   - Fixes the "Whitespace Demos (Sunrise)" issue (greyed-out events)

## Next Steps

1. **Deploy the SQL migration** (Option 1 or 2 above)
2. **Verify the fix** using the verification queries
3. **Check the dashboard** - SA Health (iPro) should now show correct completion percentages
4. **Clear browser cache** if needed to refresh the frontend

## Additional Issue: Greyed-Out Events

The fix also addresses greyed-out events like "Whitespace Demos (Sunrise)" that don't apply to certain clients:

- **Previous**: Included in requirements with 0 expected count, showing as "0 of 2 completed"
- **Fixed**: `WHERE ter.required_count > 0` filters out greyed-out events entirely

These events will no longer appear in the Event Type Breakdown on the dashboard.
