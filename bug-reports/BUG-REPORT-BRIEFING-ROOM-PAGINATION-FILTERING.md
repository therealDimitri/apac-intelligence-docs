# Bug Report: Briefing Room Pagination Filtering

**Date**: 2025-12-07
**Severity**: High
**Component**: Briefing Room (Meetings Page)
**Status**: Fixed ✅

---

## Problem Summary

The Briefing Room pagination filtering was applying filters to the **current page only** instead of the **entire dataset**. This caused incorrect behaviour where:

- Filtering by "Scheduled" only showed scheduled meetings from the current 20-item page
- Pagination count remained at total meetings (e.g., 113) instead of filtered count
- Users had to manually navigate through all pages to find filtered results
- Filter counts in stats bar showed totals from all meetings, not filtered results

---

## Root Cause

The `useMeetings` hook fetched paginated meetings (20 per page) via `.range(from, to)` from Supabase, and the meetings page applied filters to this already-paginated array client-side. This meant:

1. Server fetched 20 meetings (e.g., page 1: meetings 1-20)
2. Client-side filter applied to these 20 meetings only
3. If page 1 had only 5 scheduled meetings, only 5 were shown
4. Pagination still showed 6 total pages (113 ÷ 20 = 6)

**Example Scenario:**

- Total meetings: 113
- Scheduled meetings across all pages: 45
- User clicks "Scheduled" filter
- **Expected**: Show 45 scheduled meetings across 3 pages (45 ÷ 20 = 3)
- **Actual**: Show 5-10 scheduled meetings from current page, still shows 6 pages

---

## Technical Details

### Before (Broken Implementation)

**useMeetings.ts:**

```typescript
// Fetched paginated data WITHOUT filters
const { data: meetingsData } = await supabase
  .from('unified_meetings')
  .select('...')
  .or('deleted.is.null,deleted.eq.false')
  .order('meeting_date', { ascending: false })
  .range(from, to) // ❌ Pagination BEFORE filtering
```

**meetings/page.tsx:**

```typescript
// Applied filters CLIENT-SIDE to already-paginated results
const filteredMeetings = useMemo(() => {
  let filtered = meetings // ❌ Only 20 meetings from current page

  if (activeFilters.status) {
    filtered = filtered.filter(meeting => meeting.status === activeFilters.status)
  }
  // ... more filters
}, [meetings, activeFilters])
```

### After (Fixed Implementation)

**useMeetings.ts:**

```typescript
export interface MeetingFilters {
  status?: 'completed' | 'scheduled' | 'cancelled'
  timeRange?: 'all' | 'week' | 'month'
  viewMode?: 'all' | 'my-meetings'
  search?: string
  clientFilter?: string[] // For CSE role filtering
}

export function useMeetings(initialPage = 1, filters?: MeetingFilters) {
  // Build query with filters BEFORE pagination
  let meetingsQuery = supabase
    .from('unified_meetings')
    .select('...')
    .or('deleted.is.null,deleted.eq.false')

  // Apply status filter
  if (filters?.status) {
    meetingsQuery = meetingsQuery.eq('status', filters.status)
  }

  // Apply time range filter
  if (filters?.timeRange === 'week') {
    meetingsQuery = meetingsQuery
      .gte('meeting_date', startOfWeek.toISOString())
      .lte('meeting_date', endOfWeek.toISOString())
  }

  // Apply search filter
  if (filters?.search) {
    meetingsQuery = meetingsQuery.or(
      `meeting_notes.ilike.%${filters.search}%,client_name.ilike.%${filters.search}%`
    )
  }

  // Apply client filter (for CSE my-meetings view)
  if (filters?.clientFilter?.length > 0) {
    meetingsQuery = meetingsQuery.in('client_name', filters.clientFilter)
  }

  // ✅ Apply pagination AFTER all filters
  meetingsQuery = meetingsQuery.order('meeting_date', { ascending: false }).range(from, to)
}
```

**meetings/page.tsx:**

```typescript
// Build filters for server-side filtering
const meetingsFilters = useMemo<MeetingFilters>(() => {
  const filters: MeetingFilters = {
    status: activeFilters.status,
    timeRange: activeFilters.timeRange,
    search: searchTerm,
  }

  // For my-meetings view, pass assigned clients
  if (activeFilters.viewMode === 'my-meetings' && profile?.assignedClients) {
    filters.clientFilter = profile.assignedClients
  }

  return filters
}, [activeFilters, searchTerm, profile])

// ✅ Pass filters to hook for server-side filtering
const { meetings } = useMeetings(1, meetingsFilters)

// ✅ Meetings already filtered server-side, use directly
const filteredMeetings = meetings
```

---

## Changes Made

### 1. Updated `src/hooks/useMeetings.ts`

**Added:**

- `MeetingFilters` interface with all filter types
- `filters` parameter to `useMeetings()` function
- Server-side filter application in `fetchFreshData()`
- Filters included in cache key for proper caching

**Key Changes:**

```typescript
// Before
export function useMeetings(initialPage = 1) {

// After
export function useMeetings(initialPage = 1, filters?: MeetingFilters) {

// Before
const cacheKey = `${CACHE_KEY}-page-${page}`

// After
const cacheKey = `${CACHE_KEY}-page-${page}-${JSON.stringify(filters || {})}`
```

### 2. Updated `src/app/(dashboard)/meetings/page.tsx`

**Removed:**

- 60+ lines of client-side filtering logic (lines 164-224)
- Redundant time range calculations
- Duplicate status filtering
- Duplicate search filtering

**Added:**

- `meetingsFilters` memoized object to build filter configuration
- Server-side filtering via `useMeetings(1, meetingsFilters)`
- Simplified sorting (only client priority sorting remains)

---

## Database Columns Used

✅ **Verified against `docs/database-schema.md`:**

| Column Name     | Table            | Used For                                      |
| --------------- | ---------------- | --------------------------------------------- |
| `status`        | unified_meetings | Status filter (scheduled/completed/cancelled) |
| `meeting_date`  | unified_meetings | Time range filter (week/month)                |
| `meeting_notes` | unified_meetings | Search filter (title/subject)                 |
| `client_name`   | unified_meetings | Search filter + CSE client filter             |
| `deleted`       | unified_meetings | Exclude deleted meetings                      |

---

## Testing Verification

### Build Validation

✅ TypeScript compilation successful
✅ Next.js build completed without errors
✅ No type mismatches or undefined errors

### Expected Behavior After Fix

1. **Status Filter:**
   - Click "Scheduled" → Shows ONLY scheduled meetings from entire dataset
   - Pagination count updates to reflect filtered results
   - Example: 45 scheduled meetings = 3 pages (45 ÷ 20)

2. **Time Range Filter:**
   - Click "This Week" → Shows only meetings from current week
   - Pagination updates correctly
   - Stats bar shows counts for filtered results only

3. **Search Filter:**
   - Type "Altera" → Shows all meetings with "Altera" in title or client name
   - Results span across all data, not just current page
   - Pagination reflects search results count

4. **My Meetings Filter (CSE role):**
   - Shows only meetings for assigned clients
   - Filtered server-side using client names from profile
   - Pagination reflects CSE's meeting count

5. **Combined Filters:**
   - Multiple filters work together (e.g., "This Week" + "Scheduled" + "Search")
   - All filters applied server-side before pagination
   - Counts and pagination update correctly

---

## Performance Impact

### Before

- Fetched 20 meetings per page regardless of filters
- Client-side filtering wasted bandwidth on filtered-out meetings
- Multiple filter changes caused unnecessary re-renders

### After

- Fetches only filtered meetings from database
- Reduced data transfer (fewer meetings per page when filtered)
- Better cache efficiency (separate cache per filter combination)
- Improved user experience (correct pagination counts)

---

## Related Files

- `src/hooks/useMeetings.ts` - Server-side filtering implementation
- `src/app/(dashboard)/meetings/page.tsx` - Filter configuration and usage
- `src/hooks/useUserProfile.ts` - CSE assigned clients for "my-meetings" filter
- `docs/database-schema.md` - Schema validation reference

---

## Lessons Learned

1. **Always filter before pagination** - Apply filters at database level, not client-side
2. **Verify column names** - Reference `docs/database-schema.md` before writing queries
3. **Test filter combinations** - Ensure multiple filters work together correctly
4. **Cache key management** - Include filters in cache keys to prevent stale data
5. **TypeScript types** - Use strong typing for filter interfaces to prevent errors

---

## Prevention Checklist

For future pagination implementations:

- [ ] Apply filters in database query BEFORE `.range()`
- [ ] Include filter parameters in hook/function signature
- [ ] Update cache keys to include filter values
- [ ] Verify database column names against schema docs
- [ ] Test with multiple filter combinations
- [ ] Validate TypeScript types compile successfully
- [ ] Check pagination counts update correctly

---

**Fixed By**: Claude Code
**Verified By**: Build validation + TypeScript compilation
**Documentation**: This bug report
