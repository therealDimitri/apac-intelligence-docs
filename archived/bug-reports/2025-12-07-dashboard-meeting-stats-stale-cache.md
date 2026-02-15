# Bug Report: Dashboard Meeting Stats Show Stale/Incorrect Numbers

**Date**: 2025-12-07
**Severity**: Medium (Data accuracy issue)
**Status**: Identified
**Reporter**: User
**Environment**: Production

## Summary

The dashboard shows incorrect meeting statistics (1 thisWeek, 18 completed, 2 scheduled, 0 cancelled) when the actual database contains 74 total meetings (0 thisWeek, 73 completed, 1 scheduled, 0 cancelled).

## Evidence

**Screenshot**: Dashboard showing incorrect stats
**Actual Database Stats** (verified via direct query):

- Total Meetings: 74
- This Week: 0
- Completed: 73
- Scheduled: 1
- Cancelled: 0

**Dashboard Display** (from screenshot):

- This Week: 1
- Completed: 18
- Scheduled: 2
- Cancelled: 0
- **Total shown: 21 (should be 74)**

**Discrepancy**: 53 meetings are missing from the dashboard display!

## Root Cause

**Client-side cache is serving stale data.**

The application uses an in-memory cache with a **15-minute TTL** (Time To Live):

```typescript
// src/hooks/useMeetings.ts (line 54)
const CACHE_TTL = 15 * 60 * 1000 // 15 minutes
```

### How the Cache Works:

1. **First Load**: useMeetings hook fetches fresh data from database → caches it for 15 minutes
2. **Subsequent Loads**: Returns cached data without hitting database
3. **Background Refresh**: Fetches fresh data but doesn't update UI immediately
4. **Problem**: If user deletes meetings or data changes, the dashboard shows old cached stats for up to 15 minutes

### Cache Key Structure:

```typescript
// src/hooks/useMeetings.ts (line 78)
const cacheKey = `${CACHE_KEY}-page-${page}`
// Example: "meetings-page-1"
```

**Issue**: Each page is cached separately. When meetings are deleted:

- The cache still contains the old count
- Stats calculation uses cached data
- Dashboard shows outdated numbers

## User Impact

- **Data Trust**: Users lose confidence in dashboard accuracy
- **Decision Making**: Leaders making decisions based on incorrect metrics
- **Confusion**: "Why do the numbers not add up?"
- **Workflow Disruption**: Users must manually refresh to see accurate data

## Technical Details

### Files Involved:

1. **src/hooks/useMeetings.ts** (lines 52-100)
   - Cache TTL: 15 minutes
   - Cache strategy: Background refresh + stale-while-revalidate
   - Stats calculation: Lines 212-224

2. **src/lib/cache.ts** (lines 1-93)
   - In-memory cache implementation
   - Global singleton pattern
   - No automatic invalidation on data changes

3. **src/components/TraditionalDashboard.tsx** (lines 61, 208-214)
   - Displays cached stats from useMeetings hook
   - No manual refresh mechanism

### Cache Lifecycle:

```
User loads dashboard
     ↓
useMeetings.fetchMeetings(page=1)
     ↓
Check cache.get("meetings-page-1")
     ↓
[CACHE HIT] Return cached data (15-min old)
     ↓
Dashboard displays OLD stats (1, 18, 2, 0)
     ↓
Background: fetchFreshData() runs but doesn't force UI update
     ↓
User sees stale data until TTL expires (up to 15 minutes)
```

## Reproduction Steps

1. Load dashboard → note the meeting stats
2. Navigate to `/meetings` and delete several meetings
3. Return to dashboard immediately
4. **Expected**: Stats reflect the deletions
5. **Actual**: Stats show old cached values

## Proposed Solutions

### Option 1: Reduce Cache TTL ⭐ QUICK FIX

**Effort**: 2 minutes
**Impact**: Medium

Reduce cache TTL from 15 minutes to 1-2 minutes for faster staleness detection:

```typescript
// src/hooks/useMeetings.ts (line 54)
const CACHE_TTL = 2 * 60 * 1000 // 2 minutes (was 15)
```

**Benefits**:

- Minimal code change
- Data updates appear within 2 minutes instead of 15
- Still provides caching benefit

**Limitations**:

- Doesn't solve the root cause
- Still potential for stale data (just shorter window)

---

### Option 2: Invalidate Cache on Delete ⭐⭐ RECOMMENDED

**Effort**: 30 minutes
**Impact**: High

Automatically invalidate meeting cache when meetings are deleted:

```typescript
// src/app/(dashboard)/meetings/page.tsx
const handleDeleteMeeting = async (meetingId: string) => {
  // ... delete logic ...

  // Invalidate ALL meeting cache pages
  cache.deletePattern('meetings')

  refetch() // Force immediate refetch
}
```

**Benefits**:

- Immediate UI update after delete
- Maintains long cache TTL for performance
- Fixes root cause

**Implementation**:

1. Import cache from '@/lib/cache'
2. Call `cache.deletePattern('meetings')` after successful delete
3. Force refetch to repopulate cache with fresh data

---

### Option 3: Add Manual Refresh Button

**Effort**: 15 minutes
**Impact**: Low-Medium

Add a "Refresh Stats" button on dashboard:

```tsx
<button
  onClick={() => {
    cache.deletePattern('meetings')
    refetchMeetings()
  }}
>
  <RefreshCw className="h-4 w-4" />
  Refresh
</button>
```

**Benefits**:

- User control over data freshness
- No automatic cache changes
- Quick implementation

**Limitations**:

- Requires user action
- Doesn't fix automatic staleness

---

### Option 4: Real-time Subscription Updates ⭐⭐⭐ BEST PRACTICE

**Effort**: 1-2 hours
**Impact**: Very High

Use Supabase real-time subscriptions to auto-update stats when data changes:

```typescript
// src/hooks/useMeetings.ts
useEffect(() => {
  const subscription = supabase
    .channel('meetings-changes')
    .on(
      'postgres_changes',
      {
        event: '*', // INSERT, UPDATE, DELETE
        schema: 'public',
        table: 'unified_meetings',
      },
      () => {
        // Invalidate cache and refetch
        cache.deletePattern('meetings')
        fetchMeetings(currentPage)
      }
    )
    .subscribe()

  return () => subscription.unsubscribe()
}, [currentPage])
```

**Benefits**:

- Real-time updates (instant)
- No manual refresh needed
- Industry best practice
- Scales to multiple users

**Already Implemented**: The codebase has `useRealtimeSubscriptions` hook! Just need to wire it to invalidate cache.

---

## Recommended Implementation (Hybrid Approach)

Combine **Option 2 (Cache Invalidation)** + **Option 4 (Real-time Subscription)**:

### Step 1: Invalidate Cache on Delete (Immediate Fix)

```typescript
// src/app/(dashboard)/meetings/page.tsx (line 263)
import { cache } from '@/lib/cache'

const handleDeleteMeeting = async (meetingId: string) => {
  // ... existing delete logic ...

  // ✅ INVALIDATE CACHE
  cache.deletePattern('meetings')

  // ✅ FORCE IMMEDIATE REFETCH
  refetch()
}
```

### Step 2: Wire Real-time Subscription to Cache Invalidation

```typescript
// src/hooks/useMeetings.ts (add after line 100)
useEffect(() => {
  const subscription = supabase
    .channel('meetings-realtime')
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'unified_meetings',
      },
      () => {
        console.log('[Meetings] Real-time change detected, invalidating cache')
        cache.deletePattern('meetings')
        fetchMeetings(currentPage)
      }
    )
    .subscribe()

  return () => {
    subscription.unsubscribe()
  }
}, [currentPage, fetchMeetings])
```

### Step 3: Reduce Cache TTL for Safety

```typescript
// src/hooks/useMeetings.ts (line 54)
const CACHE_TTL = 5 * 60 * 1000 // 5 minutes (reduced from 15)
```

---

## Expected Outcome

After implementing the fix:

1. **User deletes a meeting** → Cache invalidated instantly → Stats update within 1 second
2. **Another user deletes a meeting** → Real-time subscription detects change → Cache invalidated → Stats auto-update
3. **Worst case**: If real-time fails, cache expires after 5 minutes instead of 15

**Result**: Dashboard always shows accurate, up-to-date statistics

---

## Testing Plan

1. **Manual Test**:
   - Load dashboard → note meeting stats (e.g., "73 completed")
   - Delete a meeting
   - Verify stats update immediately (e.g., "72 completed")
   - Verify total count decreases by 1

2. **Multi-User Test**:
   - User A: Opens dashboard
   - User B: Deletes a meeting
   - User A: Should see stats auto-update (real-time)

3. **Edge Cases**:
   - Delete multiple meetings rapidly → stats should update for each delete
   - Network offline → cache invalidation should still work locally
   - Cache TTL expiry → should refresh automatically after 5 minutes

---

## Success Metrics

- **Data Accuracy**: Dashboard stats match database 100% of the time
- **Update Latency**: Stats update within 1 second of delete action
- **User Confidence**: Zero complaints about "numbers don't add up"

---

## Status

**TO IMPLEMENT**: Recommended implementation (Option 2 + Option 4)

---

**Priority**: High
**Effort**: 1 hour total
**Business Value**: Critical (data integrity and user trust)
