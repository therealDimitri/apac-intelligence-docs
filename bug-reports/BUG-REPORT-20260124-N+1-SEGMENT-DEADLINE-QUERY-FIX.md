# Bug Report: N+1 Query Pattern for Segment Deadline Queries

**Date**: 2026-01-24
**Status**: FIXED
**Severity**: Performance
**Category**: Database Query Optimisation

## Issue Summary

The `useAllClientsCompliance` hook was making 19+ individual database queries to detect segment deadline changes when loading compliance data for all clients. This created an N+1 query pattern that significantly impacted performance.

## Root Cause Analysis

In `src/hooks/useEventCompliance.ts`, the `useAllClientsCompliance` function was using `Promise.all` to call `detectSegmentChange()` for each client individually. The `detectSegmentChange()` function makes 2 database queries per client:

1. Query to `nps_clients` to get the current segment
2. Query to `client_segmentation` to get segment history

For 19 clients, this resulted in 38 individual database queries plus the overhead of creating and managing 19 concurrent promises.

### Before Fix (Problematic Code)
```typescript
// Inside useAllClientsCompliance
const complianceResults: ClientCompliance[] = await Promise.all(
  viewData.map(async (client: RawClientComplianceView) => {
    // This makes 2 queries per client - N+1 problem!
    const deadlineInfo = await detectSegmentChange(client.client_name, year)
    // ... rest of processing
  })
)
```

## Solution

Created a new batched function `detectSegmentChangesBatched()` in `src/lib/segment-deadline-utils.ts` that:

1. Takes an array of client names instead of a single client
2. Fetches all current segments in a single query using `WHERE client_name IN (...)`
3. Fetches all segment histories in a single query using `WHERE client_name IN (...)`
4. Groups and processes the results in memory

### After Fix
```typescript
// In segment-deadline-utils.ts
export async function detectSegmentChangesBatched(
  clientNames: string[],
  year: number
): Promise<Map<string, SegmentChangeInfo>> {
  // Step 1: Batch fetch all current segments from nps_clients
  const { data: clientsData } = await supabase
    .from('nps_clients')
    .select('client_name, segment')
    .in('client_name', clientNames)

  // Step 2: Batch fetch all segment histories from client_segmentation
  const { data: allHistories } = await supabase
    .from('client_segmentation')
    .select('client_name, effective_from, effective_to, segmentation_tiers(tier_name)')
    .in('client_name', clientNames)
    .order('effective_from', { ascending: true })

  // Step 3: Group histories by client and process in memory
  // ... (see implementation for details)
}

// In useEventCompliance.ts
const clientNames = viewData.map((c) => c.client_name)
const deadlineInfoMap = await detectSegmentChangesBatched(clientNames, year)

// Now just synchronous map - no more async per client
const complianceResults: ClientCompliance[] = viewData.map((client) => {
  const deadlineInfo = deadlineInfoMap.get(client.client_name) || defaultInfo
  // ... rest of processing
})
```

## Performance Impact

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Database queries for segment deadlines | 38 (2 * 19 clients) | 2 | 95% reduction |
| Query type | Sequential per client | Batched with IN clause | Bulk operation |
| Memory overhead | 19 concurrent promises | Single synchronous map | Reduced GC pressure |

## Files Changed

1. **`/src/lib/segment-deadline-utils.ts`**
   - Added new exported function `detectSegmentChangesBatched()`
   - Function batches queries using `WHERE client_name IN (...)` clause
   - Groups results by client name in memory for efficient lookup

2. **`/src/hooks/useEventCompliance.ts`**
   - Updated import to include `detectSegmentChangesBatched`
   - Refactored `useAllClientsCompliance` to use batched function
   - Changed from `Promise.all` with async mapping to synchronous map with pre-fetched data

## Testing

- Build passes: `npm run build` completes without TypeScript errors
- TypeScript compilation: `npx tsc --noEmit` shows no errors
- Function maintains same return type and behaviour as individual queries
- Console log added: `[Segment Deadline Batch] Processed ${clientNames.length} clients with 2 queries`

## Verification Steps

1. Open browser console
2. Navigate to compliance page that loads all clients
3. Search for "Segment Deadline Batch" in console logs
4. Verify it shows "Processed X clients with 2 queries" instead of multiple individual query logs

## Related Documentation

- `/docs/database-schema.md` - Schema reference for `nps_clients` and `client_segmentation` tables
- `/docs/features/FEATURE-SEGMENT-DEADLINE-EXTENSION.md` - Business logic for segment deadline extensions
