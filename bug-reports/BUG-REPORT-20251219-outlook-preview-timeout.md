# Bug Report: Outlook Preview API Timeout (N+1 Query Problem)

## Date

19 December 2025

## Issue Summary

The Outlook Calendar preview endpoint (`/api/outlook/preview`) was timing out after 56 seconds when processing calendar events due to an N+1 database query problem.

## Symptoms

- Users clicking "Sync from Outlook" would see the loading spinner for over 50 seconds
- Client-side fetch requests would timeout before the server completed processing
- Netlify function logs showed 56-second execution times
- Console showed no explicit errors - just a hanging request

## Root Cause

The preview route was making **216 individual database queries** - one for each Outlook calendar event fetched. This caused massive latency:

```typescript
// BEFORE: N+1 Query Pattern (BAD)
for (const event of outlookEvents) {
  // Each iteration makes a separate database query
  const { data: existingMeetings } = await supabase
    .from('unified_meetings')
    .select('*')
    .eq('outlook_event_id', event.id)
    .limit(1)
  // ... process event
}
```

With 216 events, this resulted in:

- 216 network round-trips to Supabase
- Each query taking ~250ms on average
- Total execution time: ~56 seconds

## Solution

Changed from N+1 individual queries to a single batch query with O(1) Map lookup:

```typescript
// AFTER: Batch Query Pattern (GOOD)
// 1. Collect all event IDs upfront
const allEventIds = outlookEvents.map(event => event.id)

// 2. Single batch query
const { data: existingMeetingsData } = await supabase
  .from('unified_meetings')
  .select('outlook_event_id, updated_at')
  .in('outlook_event_id', allEventIds)

// 3. Create Map for O(1) lookup
const existingMeetingsMap = new Map()
if (existingMeetingsData) {
  for (const meeting of existingMeetingsData) {
    existingMeetingsMap.set(meeting.outlook_event_id, meeting)
  }
}

// 4. Process events using Map lookup (no DB calls in loop)
for (const event of outlookEvents) {
  const existingMeeting = existingMeetingsMap.get(event.id) // O(1)
  // ... process event
}
```

## Files Modified

1. `src/app/api/outlook/preview/route.ts` - Main fix
2. `src/app/api/outlook/import-selected/route.ts` - Same optimisation applied

## Performance Improvement

- **Before**: ~56 seconds for 216 events
- **After**: ~2-3 seconds expected (single batch query + Map lookup)
- **Improvement**: ~95% reduction in execution time

## Prevention

To avoid N+1 query problems in future:

1. **Never query in a loop** - If you need data for multiple items, batch the query
2. **Use `.in()` operator** - Supabase supports `WHERE column IN (values)` efficiently
3. **Pre-fetch related data** - Load all related records before processing
4. **Use Maps for lookups** - O(1) lookup instead of O(n) array searches

## Testing

- Build passes with no TypeScript errors
- Code committed and pushed to main branch
- Deploy should complete successfully

## Related Issues

This issue was discovered while debugging what appeared to be a Microsoft token expiry problem. The token was valid, but the function was simply taking too long to complete.

## Commit

`51d30dc` - fix(outlook): resolve N+1 query timeout in preview and import routes
