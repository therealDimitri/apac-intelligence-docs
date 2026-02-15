# Bug Report: Compliance Hook Race Condition (FOUC)

**Date:** 2026-01-02
**Status:** Fixed
**Severity:** High
**Component:** Multiple hooks in RightColumn

## Issue Description

The Client Status Summary section in RightColumn was experiencing a Flash of Unstyled Content (FOUC) where the correct compliance data would display briefly, then revert to incorrect/old data.

## Root Cause Analysis

### Phase 1: useEventCompliance Race Condition

Console logs revealed the `useEventCompliance` hook was being called 10+ times in parallel with all calls reporting "CACHE MISS". This occurred because:

1. Multiple React components and effects were calling the hook simultaneously
2. Each call checked the cache, found it empty, and started its own async calculation
3. All calculations ran in parallel, racing to set state
4. The last calculation to complete "won", potentially overwriting correct data with stale results

### Phase 2: Additional Hooks Without Caching

After fixing `useEventCompliance`, FOUC persisted because two other hooks also lacked caching and deduplication:

1. **`useSegmentationEvents`** - Being initialised 100+ times per page load, fetching data on every render
2. **`useSegmentChange`** - Making database queries on every render without caching

**Sample log showing the issue:**
```
🔍 [useSegmentationEvents] HOOK INITIALIZED with clientName="Client X", year=2026
🔍 [useSegmentationEvents] HOOK INITIALIZED with clientName="Client X", year=2026
... (repeated 100+ times)
[useSegmentChange] Client: Client X, Year: 2026
[useSegmentChange] No segment change detected (history.length: 1)
[useSegmentChange] Client: Client X, Year: 2026
... (repeated many times)
```

## Solution Implemented

Added request deduplication and caching to all three hooks:

### 1. useEventCompliance.ts

```typescript
const pendingRequests = new Map<string, Promise<ClientCompliance | null>>()

// Check for existing request before calculating
const existingRequest = pendingRequests.get(cacheKey)
if (existingRequest) {
  const result = await existingRequest
  if (result) setCompliance(result)
  return
}
```

### 2. useSegmentationEvents.ts

```typescript
// Module-level cache and deduplication
const CACHE_TTL = 60 * 1000 // 60 seconds
const cache = new Map<string, { data: SegmentationEvent[]; timestamp: number }>()
const pendingRequests = new Map<string, Promise<SegmentationEvent[]>>()

// Check cache first
const cached = cache.get(cacheKey)
if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
  setEvents(cached.data)
  return
}

// Check for pending request (deduplication)
const existingRequest = pendingRequests.get(cacheKey)
if (existingRequest) {
  const data = await existingRequest
  setEvents(data)
  return
}
```

### 3. useSegmentChange.ts

```typescript
// Module-level cache and deduplication
const CACHE_TTL = 60 * 1000 // 60 seconds
const cache = new Map<string, { data: SegmentChange; timestamp: number }>()
const pendingRequests = new Map<string, Promise<SegmentChange>>()

// Same pattern: cache check → deduplication check → fetch
```

### 4. RightColumn.tsx

- Disabled noisy debug logging that was running on every render

### 5. Client Profile Page (v2/page.tsx) - Page-level FOUC

The entire page was FOUCing due to asynchronous client state:

**Problem:**
```tsx
const { clients, loading, error } = useClients()
const [client, setClient] = useState<Client | null>(null)

// In useEffect (async):
useEffect(() => {
  if (clients.length > 0) {
    // ... find client logic
    setClient(foundClient)
  }
}, [clientId, clients])

// Shows "Client Not Found" when loading=false but client=null
if (error || !client) {
  return <ClientNotFound />
}
```

**Timeline:**
1. `useClients()` completes, `loading=false`
2. Page renders with `client=null` → shows "Client Not Found" briefly
3. useEffect runs and sets `client`
4. Page re-renders with correct data

**Fix:** Use `useMemo` to derive client synchronously instead of `useEffect` + `useState`:

```tsx
const client = useMemo(() => {
  if (clients.length === 0) return null

  const decodedClientId = decodeURIComponent(clientId)

  // Try to find by ID first
  let foundClient = clients.find(c => c.id === clientId)

  // ... more matching logic

  return foundClient || null
}, [clientId, clients])
```

This ensures `client` is derived in the same render cycle as `clients`, eliminating the FOUC.

## Expected Behaviour After Fix

Console logs should now show:
```
🔍 [useSegmentationEvents] CACHE MISS: Fetching for Client X, year=2026
🔍 [useSegmentationEvents] DEDUP: Awaiting existing request for Client X
🔍 [useSegmentationEvents] DEDUP: Awaiting existing request for Client X
🔍 [useSegmentationEvents] ✅ SUCCESS! Fetched 0 events
🔍 [useSegmentationEvents] CACHE HIT: Client X, 0 events
```

## Files Modified

- `src/hooks/useEventCompliance.ts` - Added request deduplication pattern
- `src/hooks/useSegmentationEvents.ts` - Added caching and request deduplication
- `src/hooks/useSegmentChange.ts` - Added caching and request deduplication
- `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx` - Disabled debug logging
- `src/app/(dashboard)/clients/[clientId]/v2/page.tsx` - Changed client derivation from useEffect to useMemo

## Testing Verification

1. TypeScript compilation: Passes
2. Manual testing: Navigate to client profile page and verify compliance data displays correctly without flickering

## Related Context

This fix was part of a larger update that also:
- Implemented segment-aware compliance calculation (Jan-Dec vs. extended deadline for segment changes)
- Added cache versioning to invalidate stale data when logic changes
- Added colour-coded pills for Segmentation Progress, Health, NPS, WC, and Actions

## Prevention

Consider using React Query or SWR for data fetching in future implementations, as they handle request deduplication, caching, and race conditions out of the box.
