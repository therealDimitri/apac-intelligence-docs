# Enhancement Report: BURC Historical Analytics Cache Optimisation

**Date:** 3 January 2026
**Type:** Performance Optimisation
**Status:** Completed
**Components Affected:** Historical Analytics API

---

## Summary

Implemented in-memory caching with HTTP cache headers to dramatically improve the performance of the Historical Analytics (2019-2025) tab on the Financials page. Previously, each page view triggered 5-6 API calls that each paginated through 85,000+ database records. Now, aggregated results are cached for 1 hour.

---

## Performance Improvement

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| First load (cold cache) | ~50s | ~50s | Same |
| Subsequent loads (warm cache) | ~50s | **<50ms** | **~1000x faster** |
| Database queries per page view | 5-6 | 0* | **100% reduction** |
| API response headers | None | Cache-Control, X-Cache-Status | Added |

*After initial cache population

---

## Implementation Details

### 1. In-Memory Cache (Server-Side)

Added a global cache store in the API route with:
- **TTL:** 1 hour (configurable via `CACHE_TTL_MS`)
- **Cache keys:** Unique per view type and date range
- **Automatic expiry:** Entries older than TTL are automatically purged

```typescript
const CACHE_TTL_MS = 60 * 60 * 1000 // 1 hour

interface CacheEntry<T> {
  data: T
  timestamp: number
  key: string
}

const cache = new Map<string, CacheEntry<unknown>>()
```

### 2. HTTP Cache Headers (Client-Side)

All responses now include cache headers:
```
Cache-Control: public, max-age=3600, stale-while-revalidate=7200
X-Cache-Status: HIT | MISS
X-Cache-Age: <seconds since cached>
X-Cache-Key: <cache key used>
```

### 3. Cache Keys

| View | Cache Key Format |
|------|------------------|
| Revenue Trend | `trend_${startYear}_${endYear}` |
| Revenue Mix | `mix_${startYear}_${endYear}` |
| Client Lifetime | `clients_lifetime` |
| Concentration | `concentration` |
| NRR/GRR | `nrr_${startYear}_${endYear}` |

### 4. Cache Management Endpoint

**POST /api/analytics/burc/historical**

| Action | Description |
|--------|-------------|
| `?action=invalidate` | Clear all cached data (call after syncing new data) |
| `?action=status` | Get cache statistics and entry list |

---

## Files Modified

### `src/app/api/analytics/burc/historical/route.ts`

- Added cache configuration constants
- Added `CacheEntry` interface
- Added `cache` Map for global storage
- Added `getCached<T>()` helper function
- Added `setCache<T>()` helper function
- Added `cachedResponse<T>()` helper for HTTP headers
- Updated all 5 view functions to use caching:
  - `getRevenueTrend()` - Cache key: `trend_${startYear}_${endYear}`
  - `getRevenueMix()` - Cache key: `mix_${startYear}_${endYear}`
  - `getClientLifetimeValue()` - Cache key: `clients_lifetime`
  - `getRevenueConcentration()` - Cache key: `concentration`
  - `getHistoricalNRR()` - Cache key: `nrr_${startYear}_${endYear}`
- Added `POST` handler for cache management

---

## Usage

### Invalidate Cache After Data Sync

After running revenue sync scripts, invalidate the cache:

```bash
curl -X POST "http://localhost:3000/api/analytics/burc/historical?action=invalidate"
```

### Check Cache Status

```bash
curl -X POST "http://localhost:3000/api/analytics/burc/historical?action=status"
```

Response:
```json
{
  "cacheSize": 5,
  "ttlSeconds": 3600,
  "entries": [
    { "key": "trend_2019_2025", "ageSeconds": 120, "expiresInSeconds": 3480 },
    { "key": "clients_lifetime", "ageSeconds": 115, "expiresInSeconds": 3485 }
  ]
}
```

---

## Why In-Memory vs Database Cache?

| Approach | Pros | Cons |
|----------|------|------|
| **In-Memory (chosen)** | No schema changes, instant implementation, <1ms reads | Lost on server restart, per-instance cache |
| Database Cache | Persistent, shared across instances | Requires migrations, additional queries |
| Redis | Fast, shared, TTL built-in | Additional infrastructure |

For this use case, in-memory caching is ideal because:
1. Historical data rarely changes (only on manual sync)
2. Single-instance deployment
3. 1-hour TTL is acceptable given data stability
4. No additional infrastructure needed

---

## Future Improvements

1. **Pre-warm cache on server start** - Load popular views automatically
2. **Database cache tables** - For persistent caching across restarts (scripts already prepared)
3. **Webhook integration** - Auto-invalidate cache when data sync completes
4. **Cache metrics dashboard** - Monitor hit/miss ratios in UI

---

## Related Documentation

- [2025 Revenue Data Sync](./ENHANCEMENT-20260103-2025-revenue-data-sync.md)
- [BURC Historical Data Display Bug Fix](./BUG-FIX-20260103-burc-historical-data-display.md)
- [BURC Historical Dashboard Enhancement](./ENHANCEMENT-20260102-burc-historical-dashboard.md)
