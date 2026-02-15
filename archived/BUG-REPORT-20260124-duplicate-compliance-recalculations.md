# Bug Report: Duplicate Compliance Recalculations

**Date:** 24 January 2026
**Status:** FIXED
**Severity:** Medium (Performance)
**Component:** `useAllClientsCompliance` hook

## Issue Description

The console showed duplicate compliance calculations running for the same client:

```
[useAllClientsCompliance] SA Health (iPro): Segment changed, recalculated score=38% (was 100%)
[useAllClientsCompliance] SA Health (iPro): Segment changed, recalculated score=38% (was 100%)
```

Each client with a segment change was being recalculated twice, causing unnecessary network requests and processing overhead.

## Root Cause

The `useAllClientsCompliance` hook had two issues causing duplicate calculations:

1. **Missing request deduplication**: Unlike `useEventCompliance` which had a `pendingRequests` Map to deduplicate in-flight requests, `useAllClientsCompliance` was missing this mechanism.

2. **useEffect re-running on callback recreation**: The `useEffect` depended on `calculateAllCompliance`, which was recreated on renders, causing the effect to fire multiple times.

## Solution

Applied the same deduplication pattern used in `useEventCompliance`:

1. **Added `pendingAllClientsRequests` Map**: A module-level Map to track in-flight requests and allow subsequent callers to await the existing promise instead of starting a new request.

2. **Added `lastInitiatedYearRef` ref**: Tracks the year for which a calculation was already initiated, preventing duplicate calculations on React re-renders.

3. **Wrapped calculation in Promise**: The actual calculation logic is wrapped in a Promise that gets stored in the pending requests Map, allowing deduplication.

4. **Added `useMemo` for cache key**: Prevents unnecessary recalculation of the cache key string.

## Files Modified

- `/src/hooks/useEventCompliance.ts`
  - Added `pendingAllClientsRequests` Map for request deduplication
  - Added `lastInitiatedYearRef` ref to track initiated calculations
  - Added `useMemo` for cache key
  - Wrapped calculation in Promise for deduplication
  - Updated `useEffect` to check `lastInitiatedYearRef` before initiating
  - Updated `refetch` to reset the ref when manually refetching

## Code Changes

### Before (problematic)
```typescript
const cacheKey = `${CACHE_KEY_PREFIX}_all_${year}`

const calculateAllCompliance = useCallback(async () => {
  // ... calculation logic directly in callback
}, [year, cacheKey])

useEffect(() => {
  if (year) {
    calculateAllCompliance()
  }
}, [calculateAllCompliance, year])
```

### After (fixed)
```typescript
// Module-level deduplication Map
const pendingAllClientsRequests = new Map<string, Promise<ClientCompliance[]>>()

// In hook:
const cacheKey = useMemo(() => `${CACHE_KEY_PREFIX}_all_${year}`, [year])
const lastInitiatedYearRef = useRef<number | null>(null)

const calculateAllCompliance = useCallback(async () => {
  // Check for existing pending request
  const existingRequest = pendingAllClientsRequests.get(cacheKey)
  if (existingRequest) {
    const result = await existingRequest
    setAllCompliance(result)
    return
  }

  // Wrap calculation in Promise and store for deduplication
  const calculationPromise = (async (): Promise<ClientCompliance[]> => {
    // ... calculation logic
  })()

  pendingAllClientsRequests.set(cacheKey, calculationPromise)
  // ... cleanup in finally block
}, [year, cacheKey])

useEffect(() => {
  if (lastInitiatedYearRef.current === year) {
    return // Skip if already initiated for this year
  }
  if (year) {
    lastInitiatedYearRef.current = year
    calculateAllCompliance()
  }
}, [calculateAllCompliance, year])
```

## Testing

1. Build passes with zero TypeScript errors
2. Compliance calculations now run exactly once per client
3. Console no longer shows duplicate log messages
4. Existing caching behaviour preserved
5. Manual refetch still works correctly

## Impact

- Reduced network requests by ~50% for compliance calculations
- Improved page load performance on segmentation dashboard
- Cleaner console output for debugging
