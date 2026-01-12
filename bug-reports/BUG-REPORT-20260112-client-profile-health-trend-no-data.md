# Bug Report: Client Profile Health Score Trend and Segmentation Actions Not Displaying Data

**Date:** 12 January 2026
**Status:** Fixed
**Severity:** High
**Component:** Client Profiles V2 Page

## Problem Summary

The Health Score Trend chart and Segmentation Actions section on Client Profile pages were not displaying any data, despite the data existing in the database. The UI showed:
- Health Score Trend: "Historical data will appear after the first snapshot"
- Segmentation Actions: 0% Overall Compliance, 0 On Target, 0 At Risk, 0 Total

## Root Cause Analysis

### The Bug

The `ClientMetricsProvider` was receiving the wrong value for `clientName`. The URL structure uses `client.id` (numeric database ID from `client_health_summary` view) as the route parameter, but the provider expected the actual client name.

### Data Flow Before Fix

```
URL: /clients/123/v2  (where 123 is the database row ID)
         ↓
params.clientId = "123"
         ↓
ClientMetricsProvider clientName="123"  ← WRONG!
         ↓
useHealthHistory({ clientName: "123" })
         ↓
API: /api/clients/health-history?client=123
         ↓
Query: SELECT * FROM client_health_history WHERE client_name = '123'
         ↓
Result: 0 records (no client named "123" exists)
```

### Evidence

Debug script confirmed:
- **Database has 33 health history records** for "Albury Wodonga Health"
- **Database has compliance data** with 100% score for 2025
- The API worked correctly when passed the actual client name

### Code Location

**File:** `src/app/(dashboard)/clients/[clientId]/v2/page.tsx`

**Original Code (Lines 1284-1306):**
```tsx
export default function ClientProfilePageV2() {
  const params = useParams()
  const clientId = decodeURIComponent(params.clientId as string)

  return (
    <ClientMetricsProvider clientName={clientId}>  // ← Bug: clientId is "123", not "Albury Wodonga Health"
      <Suspense>
        <ClientProfileContent />
      </Suspense>
    </ClientMetricsProvider>
  )
}
```

The inner `ClientProfileContent` component correctly resolved the client by ID:
```tsx
const client = useMemo(() => {
  // Try to find by ID first
  let foundClient = clients.find(c => c.id === clientId)
  // Falls back to name matching...
  return foundClient
}, [clientId, clients])
```

But this resolved client was only available INSIDE the provider, not before the provider was created.

## Solution Implemented

Created a new wrapper component `ClientProfileWithProvider` that:
1. Resolves the client by ID FIRST using `useClients()`
2. Only renders `ClientMetricsProvider` AFTER client is resolved
3. Passes `client.name` (the actual client name) to the provider

### Fixed Code

```tsx
function ClientProfileWithProvider() {
  const params = useParams()
  const clientId = decodeURIComponent(params.clientId as string)
  const { clients, loading } = useClients()

  // Resolve client by ID or name
  const client = useMemo(() => {
    if (clients.length === 0) return null
    let foundClient = clients.find(c => c.id === clientId)
    if (!foundClient) {
      foundClient = clients.find(c => c.name.toLowerCase() === clientId.toLowerCase())
    }
    return foundClient || null
  }, [clientId, clients])

  if (loading) return <LoadingSpinner />
  if (!client) return <ClientNotFound />

  // Now pass the ACTUAL client name to the provider
  return (
    <ClientMetricsProvider clientName={client.name}>
      <Suspense>
        <ClientProfileContent />
      </Suspense>
    </ClientMetricsProvider>
  )
}

export default function ClientProfilePageV2() {
  return <ClientProfileWithProvider />
}
```

### Data Flow After Fix

```
URL: /clients/123/v2
         ↓
params.clientId = "123"
         ↓
useClients() → clients array
         ↓
client = clients.find(c => c.id === "123")  → { id: "123", name: "Albury Wodonga Health", ... }
         ↓
ClientMetricsProvider clientName="Albury Wodonga Health"  ← CORRECT!
         ↓
useHealthHistory({ clientName: "Albury Wodonga Health" })
         ↓
API: /api/clients/health-history?client=Albury%20Wodonga%20Health
         ↓
Query: SELECT * FROM client_health_history WHERE client_name = 'Albury Wodonga Health'
         ↓
Result: 33 records ✓
```

## Files Modified

| File | Change |
|------|--------|
| `src/app/(dashboard)/clients/[clientId]/v2/page.tsx` | Added `ClientProfileWithProvider` wrapper component that resolves client before creating provider |

## Testing Performed

1. ✅ TypeScript compilation (0 errors)
2. ✅ Build succeeds
3. ✅ Schema validation passes (no new errors)
4. ✅ Debug script confirms data present in database

## Impact

- **Health Score Trend**: Now displays historical health score data with trend chart
- **Segmentation Actions**: Now displays correct compliance percentage and event counts
- **All metrics hooks**: Now receive correct client name for data fetching

## Why This Wasn't Caught Earlier

The bug was introduced when the client profile URLs were changed to use numeric IDs (for cleaner URLs) instead of client names. The `ClientProfileContent` component was updated to resolve the ID to a client, but the outer `ClientMetricsProvider` wrapper was not updated.

The issue was masked because:
1. The page still loaded correctly (client resolution worked inside the content)
2. The basic client info displayed correctly (from the resolved client object)
3. Only the metrics hooks failed silently (empty arrays instead of errors)

## Related Documentation

- `docs/database-schema.md` - `client_health_history` table schema
- `src/contexts/ClientMetricsContext.tsx` - Provider that uses client name for all hooks
- `src/hooks/useHealthHistory.ts` - Hook that fetches health history data
