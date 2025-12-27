# Bug Report: Deep Link Routes Return 404

**Date:** 27 December 2025
**Severity:** Medium
**Status:** Fixed
**Commit:** `2ff34eb`

## Summary

ChaSen AI was generating deep links to specific actions and meetings (e.g., `/actions/368`, `/meetings/123`) but these routes returned 404 errors because the dynamic route pages didn't exist.

## Symptoms

When clicking on action or meeting links in ChaSen AI responses:
- `/actions/368` → 404 Not Found
- `/meetings/123` → 404 Not Found

The links were correctly formatted with proper entity IDs from the database, but Next.js had no route handlers for these paths.

## Root Cause

The application only had list pages for actions (`/actions`) and meetings (`/meetings`), but no dynamic routes for viewing individual items by ID.

When the stream endpoint was updated to include deep links with entity IDs:
```typescript
// In route.ts
parts.push(`- [${action.Action_Description}](/actions/${action.id})`)
parts.push(`- [${meeting.title}](/meetings/${meeting.id})`)
```

There were no corresponding page components to handle these routes:
- Missing: `src/app/(dashboard)/actions/[id]/page.tsx`
- Missing: `src/app/(dashboard)/meetings/[id]/page.tsx`

## Fix Applied

Created two new dynamic route pages:

### 1. Action Detail Page

**Location:** `src/app/(dashboard)/actions/[id]/page.tsx`

Features:
- Fetches action by numeric ID from Supabase `actions` table
- Displays client header with logo and link to client profile
- Shows action title, status, priority, category badges
- Due date with overdue indicator
- Assigned owners
- Notes section
- Meeting context link (if action was created from a meeting)
- Comments section with real-time updates
- Back to Actions navigation

### 2. Meeting Detail Page

**Location:** `src/app/(dashboard)/meetings/[id]/page.tsx`

Features:
- Fetches meeting by numeric ID from Supabase `unified_meetings` table
- Displays client header with logo and link to client profile
- Shows meeting title, status (Scheduled/Completed/Cancelled), type badge
- Date, time, duration
- Organiser and attendees list
- AI Summary (if available)
- Key Topics, Decisions Made, Key Risks, Next Steps sections
- Meeting Notes
- Transcript and Recording file links
- Comments section with real-time updates
- Back to Briefing Room navigation

## Database Queries

Both pages use the numeric `id` column (integer primary key) for lookups:

```typescript
// Action lookup
const { data } = await supabase
  .from('actions')
  .select('*')
  .eq('id', parseInt(actionId))
  .single()

// Meeting lookup
const { data } = await supabase
  .from('unified_meetings')
  .select('*')
  .eq('id', parseInt(meetingId))
  .single()
```

## Files Created

| File | Purpose |
|------|---------|
| `src/app/(dashboard)/actions/[id]/page.tsx` | Action detail page with full action information |
| `src/app/(dashboard)/meetings/[id]/page.tsx` | Meeting detail page with full meeting information |

## Verification

After the fix:
1. `/actions/368` → Displays "Activation process review" action for GRMC
2. `/meetings/123` → Displays "2026 APAC MarCom Plan" meeting

Both pages render correctly with:
- Client branding and navigation
- Full entity details
- Comments section
- Session-aware user context

## Testing

1. Navigate to `/ai` (ChaSen AI page)
2. Ask about a specific client's actions or meetings
3. Click on any action or meeting link in the response
4. Verify the detail page loads correctly with all information
5. Verify "Back to Actions" / "Back to Briefing Room" navigation works
6. Verify comments can be added

## Related

- [ChaSen Bullet Alignment Bug](./BUG-REPORT-20251227-chasen-bullet-alignment-and-client-assignments.md)
- [ChaSen Stream Missing Org Context](./BUG-REPORT-20251227-chasen-stream-missing-org-context.md)

## Technical Notes

- Uses `useSession` from next-auth for user context in comments
- Transforms database column names to match existing interface types
- Handles date parsing for Australian DD/MM/YYYY format
- Graceful error handling for missing entities
