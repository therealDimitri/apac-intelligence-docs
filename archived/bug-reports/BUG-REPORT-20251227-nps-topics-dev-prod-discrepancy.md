# Bug Report: NPS Topics Dev vs Prod Discrepancy

**Date**: 2025-12-27
**Status**: Fixed
**Severity**: Medium

## Issue

NPS Topics displayed in the "Top Topics by Client Segment" section showed different data between Dev and Prod environments, even though both access the same Supabase database.

### Symptoms

**Dev Environment (Leverage segment - Q4 25):**
- #1 Account Management (2 mentions, positive)
- #2 Configuration & Customisation (1 mention, negative)
- #3 Product & Features (1 mention, negative)

**Prod Environment (Leverage segment - Q4 25):**
- #1 Support & Service (2 mentions, positive)
- #2 Product & Features (2 mentions, negative)

### Actual Database Data (Leverage Q4 25)

| Topic | Sentiment | Count |
|-------|-----------|-------|
| Account Management | positive | 3 |
| Support & Service | positive | 2 |
| Product & Features | neutral | 2 |
| Configuration & Customisation | negative | 1 |
| Collaboration & Partnership | positive | 1 |

Neither Dev nor Prod matched the actual database state.

## Root Cause

**Stale localStorage cache** - The NPS page caches topic analysis results in localStorage with key `nps-segment-topics-cache`. Each browser environment (Dev, Prod) maintains its own independent cache that persists for 24 hours.

When topic classifications were updated in the database, the cached data in each browser remained stale until either:
1. The 24-hour cache expired
2. User clicked "Refresh Insights" button
3. User cleared localStorage

## Fix Applied

Added a **cache version suffix** to the localStorage key to force cache invalidation when topic classification logic changes:

```typescript
// Before
const TOPICS_CACHE_KEY = 'nps-segment-topics-cache'

// After
const CACHE_VERSION = 'v2' // Increment this to force cache refresh
const TOPICS_CACHE_KEY = `nps-segment-topics-cache-${CACHE_VERSION}`
```

When deployed, both Dev and Prod will look for the new cache key (`nps-segment-topics-cache-v2`). Since no data exists for this key, they will fetch fresh data from the database.

## Files Changed

- `src/app/(dashboard)/nps/page.tsx` - Added cache version to localStorage keys

## Prevention

To avoid similar issues in the future:

1. **Increment `CACHE_VERSION`** whenever topic classification logic changes significantly
2. **Consider shorter cache duration** for development environments
3. **Add "Last refreshed" indicator** to help users identify stale data
4. **Document cache keys** in database schema docs

## Testing

After deployment:
1. Both Dev and Prod should show identical topic data
2. Data should match the database: Account Management #1 (3 mentions), Support & Service #2 (2 mentions)
3. "Refresh Insights" button should work to fetch fresh data
