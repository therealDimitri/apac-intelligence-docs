# Bug Report: Notifications Table Missing from Supabase

**Date**: 2025-12-17
**Reporter**: Claude Code
**Status**: RESOLVED

## Issue Summary

The notifications system was implemented with full frontend code (hooks, components, API routes) but the database table was missing from Supabase, causing 500 errors on every notification API request.

## Error Observed

```
[Notifications API] GET Error: {
  code: 'PGRST205',
  details: null,
  hint: "Perhaps you meant the table 'public.nps_topic_classifications'",
  message: "Could not find the table 'public.notifications' in the schema cache"
}
```

## Root Cause

The notifications feature was committed with all application code but the database table was never created in Supabase. The original migration script only checked if the table existed and output SQL for manual execution, but the actual table creation step was skipped.

## Impact

- Notification bell showing loading spinner indefinitely
- 500 errors on every `/api/notifications` request
- Users not receiving @mention notifications
- Console spam with repeated PGRST205 errors

## Resolution

### Step 1: Created the table via Supabase SQL Editor

Executed the following SQL in the Supabase Dashboard SQL Editor:

```sql
-- Create notifications table for @mentions
CREATE TABLE IF NOT EXISTS notifications (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id text NOT NULL,
  user_email text,
  type text NOT NULL DEFAULT 'mention',
  title text NOT NULL,
  message text NOT NULL,
  link text,
  item_id text,
  comment_id text,
  triggered_by text NOT NULL,
  triggered_by_avatar text,
  read boolean DEFAULT false,
  read_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_email ON notifications(user_email);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);

-- Enable RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Allow all select on notifications" ON notifications FOR SELECT USING (true);
CREATE POLICY "Allow all insert on notifications" ON notifications FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow all update on notifications" ON notifications FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Allow all delete on notifications" ON notifications FOR DELETE USING (true);
```

### Step 2: Verified table functionality

Ran comprehensive tests via `scripts/test-notifications-table.mjs`:

- Table exists: ✓
- Insert works: ✓
- Read works: ✓
- Delete works: ✓

### Step 3: Updated schema documentation

- Added `notifications` to the introspect-schema script table list
- Manually documented the notifications table schema in `docs/database-schema.md`

## Files Modified

- `scripts/introspect-database-schema.mjs` - Added notifications to table list
- `docs/database-schema.md` - Added notifications table schema
- `scripts/create-notifications-table-direct.mjs` - Created for future automation attempts
- `scripts/create-notifications-via-api.mjs` - Created for future automation attempts
- `scripts/test-notifications-table.mjs` - Created for verification

## Prevention

1. **Always verify database tables exist** before committing features that depend on them
2. **Run schema introspection** after any database changes
3. **Test full CRUD operations** on new tables before marking features complete
4. **Document database dependencies** in feature documentation

## Related Files

- `src/hooks/useNotifications.ts` - Notification hook
- `src/components/NotificationBell.tsx` - UI component
- `src/app/api/notifications/route.ts` - API route
- `docs/FEATURE-20251217-notifications-system.md` - Feature documentation
