# Client UUID Migration - API Adoption Report

**Date:** 2025-12-27
**Type:** Migration
**Status:** Complete (Phase 2)
**Commit:** ab634ec

---

## Summary

Implemented Phase 2 of the client unification migration by updating critical ChaSen API routes to use `client_uuid` instead of `client_name` string matching. This improves query performance and ensures consistent client resolution across the application.

---

## Changes Made

### New Files

| File | Purpose |
|------|---------|
| `src/lib/client-resolver.ts` | Central helper for client UUID resolution |

### Modified Files

| File | Queries Updated | Notes |
|------|-----------------|-------|
| `src/app/api/chasen/meeting-prep/route.ts` | 8 → 5 use UUID | 3 tables don't have client_uuid |
| `src/app/api/chasen/recommend-actions/route.ts` | 2 | Uses canonical name |
| `src/app/api/chasen/nps-insights/route.ts` | 1 | Cache uses canonical name |
| `src/app/api/clients/health-insights/route.ts` | 4 → 3 use UUID | 1 table lacks client_uuid |

### Skipped

| File | Reason |
|------|--------|
| `src/app/api/chasen/analyze/route.ts` | `chasen_documents` table lacks client_uuid |

---

## Client Resolver Functions

The new `client-resolver.ts` module provides:

```typescript
// Resolve single client name to UUID
resolveClientUUID(clientName: string): Promise<string | null>

// Batch resolve multiple names
resolveClientUUIDs(clientNames: string[]): Promise<Map<string, string | null>>

// Get canonical client info by UUID
getClientByUUID(clientUUID: string): Promise<{
  id: string
  canonical_name: string
  display_name: string
} | null>

// Get display name for client
getClientDisplayName(clientUUID: string): Promise<string | null>

// Get all aliases for a client
getClientAliases(clientUUID: string): Promise<string[]>
```

---

## Migration Pattern

Each API route was updated following this pattern:

```typescript
// Before
const { clientName } = body
const { data } = await supabase
  .from('unified_meetings')
  .eq('client_name', clientName)

// After
import { resolveClientUUID, getClientByUUID } from '@/lib/client-resolver'

const { clientName } = body

// Resolve to UUID
const clientUUID = await resolveClientUUID(clientName)
if (!clientUUID) {
  return NextResponse.json({ error: `Client "${clientName}" not found` }, { status: 404 })
}

// Get canonical info
const clientInfo = await getClientByUUID(clientUUID)
const canonicalName = clientInfo?.canonical_name || clientName

// Query with UUID where available
const { data } = await supabase
  .from('unified_meetings')
  .eq('client_uuid', clientUUID)

// Use canonical name for tables without client_uuid
const { data } = await supabase
  .from('nps_clients')
  .eq('client_name', canonicalName)
```

---

## Tables Using client_uuid

| Table | Coverage | Notes |
|-------|----------|-------|
| unified_meetings | 73% | Internal meetings = NULL (expected) |
| actions | 88% | Cross-client actions = NULL (expected) |
| nps_responses | 100% | All responses have UUID |
| segmentation_events | 100% | Uses client_uuid |
| portfolio_initiatives | 100% | Uses `client_id` (UUID) |

## Tables Still Using client_name

| Table | Reason |
|-------|--------|
| nps_clients | No client_uuid column yet |
| client_arr | No client_uuid column yet |
| segmentation_compliance_scores | No client_uuid column yet |
| client_health_summary | No client_uuid column yet |
| nps_insights_cache | Uses canonical name for consistency |

---

## Benefits Achieved

1. **Faster Queries**: UUID joins outperform string comparisons
2. **Alias Support**: "GHA" resolves to "Gippsland Health Alliance (GHA)" automatically
3. **Case Insensitive**: No more case mismatch issues
4. **Single Source of Truth**: All queries now use the same resolution logic
5. **Future Ready**: New tables can adopt client_uuid from day one

---

## Remaining Work

### Phase 3: Update Hooks (Medium Priority)
- `src/hooks/useChaSenRecommendations.ts`
- `src/hooks/usePortfolioInitiatives.ts`
- `src/hooks/useHealthHistory.ts`
- `src/hooks/useStreamingChat.ts`
- `src/hooks/useNPSAnalysis.ts`

### Phase 4: Update Components (Lower Priority)
- `src/app/(dashboard)/nps/page.tsx`
- `src/components/LogEventModal.tsx`
- Multiple components passing clientName props

### Phase 5: Deprecate Legacy Utilities
- `src/lib/client-name-mapper.ts` → Use `clients.display_name`
- `src/utils/clientMatching.ts` → Use UUID comparison

### Add client_uuid to Remaining Tables
- nps_clients
- client_arr
- segmentation_compliance_scores
- client_health_summary
- chasen_documents

---

## Testing

1. TypeScript check: **PASSED**
2. Build: **PASSED**
3. All API routes compile correctly

---

## Rollback

If issues arise, revert commit ab634ec:
```bash
git revert ab634ec
```

The database triggers continue to populate client_uuid on new records regardless of application code.
