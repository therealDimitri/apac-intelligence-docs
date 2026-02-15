# Bug Report: Universal Search Deep Linking Not Working

**Date**: 26 December 2025
**Severity**: Medium
**Status**: Fixed
**Commits**: `b3f8bbe`, `0c97941`

---

## Summary

Clicking on meeting or action search results in Universal Search navigated to the correct page but did not open the specific item.

## Root Cause 1: Wrong ID Fields in Search API

The Search API (`/api/search/route.ts`) was returning the wrong ID fields:

| Entity   | Was Using        | Should Use                                 |
| -------- | ---------------- | ------------------------------------------ |
| Meetings | `m.id` (integer) | `m.meeting_id` (string like "MEETING-xxx") |
| Actions  | `a.id` (integer) | `a.Action_ID` (string like "ACT-xxx")      |

The hooks (`useMeetings.ts`, `useActions.ts`) transform records using these string identifiers:

- `useMeetings.ts:341`: `id: meeting.meeting_id || meeting.id`
- `useActions.ts:175`: `id: action.Action_ID`

The deep linking on the pages uses these string IDs to find the target item:

- `meetings/page.tsx:206`: `meetings.find(m => m.id === meetingIdParam)`
- `actions/page.tsx:768`: `actions.find(a => a.id === actionIdParam)`

When the search API returned integer IDs, the string comparison failed.

### Fix 1 Applied

Updated `/src/app/api/search/route.ts`:

```typescript
// Meetings - use meeting_id for deep linking
id: m.meeting_id || m.id,

// Actions - use Action_ID for deep linking
id: a.Action_ID || a.id,
```

## Root Cause 2: Pagination Prevented Finding Target Meeting

The Briefing Room page uses pagination (20 meetings per page). When deep linking to a meeting that isn't on the current page, the `.find()` would fail because the meeting wasn't in the loaded dataset.

- `meetings/page.tsx:167`: `fetchAllMeetings` was only true for grouping or department filters
- Deep link searches `meetings.find()` which only contained the current page

### Fix 2 Applied

Updated `/src/app/(dashboard)/meetings/page.tsx` to fetch all meetings when a deep link is present:

```typescript
// When grouping, department filter, OR deep link is enabled, fetch ALL meetings
const hasDeepLink = !!searchParams.get('meeting')
const fetchAllMeetings = groupBy !== 'none' || !!activeFilters.department || hasDeepLink
```

Note: Actions page doesn't have this issue as it fetches all actions without pagination.

## Testing

1. Open Universal Search (Cmd+K)
2. Search for "Epworth" (a client with meetings that may not be on page 1)
3. Click on a meeting result
4. Verify the Briefing Room opens with that **specific** meeting selected
5. Search for an action and verify it opens correctly

## Files Changed

- `src/app/api/search/route.ts` - Fixed ID field mapping
- `src/app/(dashboard)/meetings/page.tsx` - Fetch all meetings when deep linking

## Related

- Previous commit `4d1fc20`: Added collapsible results and initial deep linking URLs
- Previous commit `7985299`: Renamed Command Palette to Universal Search
