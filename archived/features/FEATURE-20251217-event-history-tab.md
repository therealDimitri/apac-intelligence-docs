# Feature: Event History Tab

**Date**: 17 December 2024
**Status**: Completed
**Priority**: Medium

## Summary

Added a History tab to the Event Detail Modal to track all changes/logs for segmentation events. Users can now see who actioned changes, what was changed, and when changes were made.

## User Request

> "History tab for Events should list all changes/log for that event. Include who actioned the change, history of the change, change date and time."

## Implementation Details

### Files Created

1. **`src/components/EventDetailModal.tsx`**
   - New modal component with Overview and History tabs
   - Overview shows event details (date, location, attendees, notes, etc.)
   - History shows timeline of all changes with:
     - User who made the change
     - Type of action (created, updated, completed, reopened)
     - Field changed (if applicable)
     - Old and new values
     - Timestamp (relative and absolute)
   - Mark Complete functionality with effectiveness score slider

2. **`supabase/migrations/20251217_add_event_edit_history.sql`**
   - Adds `edit_history` JSONB column to `segmentation_events` table
   - Creates database trigger to auto-log changes
   - Backfills existing events with 'created' history entry

3. **`src/app/api/admin/run-event-history-migration/route.ts`**
   - API endpoint to run migration and backfill data
   - Provides SQL for manual execution if automatic fails

4. **`scripts/run-event-history-migration.mjs`**
   - Node.js script for backfilling edit_history

### Files Modified

1. **`src/hooks/useEvents.ts`**
   - Added `EditHistoryEntry` interface
   - Added `edit_history` field to `Event` interface
   - Updated event mapping to include edit_history

2. **`src/app/(dashboard)/segmentation/page.tsx`**
   - Added imports for EventDetailModal, useEvents, useEventTypes
   - Added state for selectedEvent and showEventDetailModal
   - Added Event History section with clickable event list
   - Integrated EventDetailModal component

## Database Schema

### Edit History Entry Structure

```typescript
interface EditHistoryEntry {
  timestamp: string // ISO 8601 timestamp
  user: string // Name of user who made the change
  action: 'created' | 'updated' | 'completed' | 'reopened'
  field: string | null // Field that was changed (null for create/complete)
  old_value: string | null
  new_value: string | null
}
```

### Tracked Fields

The database trigger automatically logs changes to:

- `completed` - When event is marked complete or reopened
- `event_date` - When event date is changed
- `notes` - When notes are updated
- `effectiveness_score` - When effectiveness score is updated
- `attendees` - When attendee list is changed
- `location` - When location is changed
- `meeting_link` - When meeting link is changed

## User Interface

### Segmentation Page - Event History Section

A new "Event History" section displays up to 10 recent events:

- Shows event type name
- Event date
- Completed status badge (green for completed, yellow for scheduled)
- Completion by (if completed)
- Click to open Event Detail Modal

### Event Detail Modal - History Tab

Timeline view showing:

- Colour-coded action dots (green=created, blue=updated, emerald=completed, orange=reopened)
- User name and relative timestamp
- Action description
- Value change visualisation for updates (old → new)
- Full timestamp on hover

## Migration Steps (Required)

The `edit_history` column needs to be added to the database. Run the following SQL in Supabase SQL Editor:

```sql
-- Add edit_history column to segmentation_events table
ALTER TABLE segmentation_events
ADD COLUMN IF NOT EXISTS edit_history JSONB DEFAULT '[]'::jsonb;

-- Create index for efficient querying
CREATE INDEX IF NOT EXISTS idx_events_edit_history ON segmentation_events USING gin (edit_history);
```

Then call the migration API to backfill existing events:

```
POST /api/admin/run-event-history-migration
```

Or run the full migration file:

- `supabase/migrations/20251217_add_event_edit_history.sql`

## Testing

1. Navigate to Segmentation page
2. Expand a client's details
3. Scroll to "Event History" section
4. Click on any event to open the Event Detail Modal
5. Click on "History" tab to view change history
6. Verify the overview tab shows correct event details
7. Try marking an event as complete (if not already completed)
8. Verify the history shows the completion action

## Future Enhancements

- Add ability to edit events from the modal
- Add comments functionality similar to Priority Matrix
- Export event history to PDF/CSV
- Real-time history updates via Supabase subscriptions
- Filter history by action type or date range
