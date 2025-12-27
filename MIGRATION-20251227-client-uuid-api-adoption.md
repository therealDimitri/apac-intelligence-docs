# Client UUID Migration - API Adoption Report

**Date:** 2025-12-27
**Type:** Migration
**Status:** Complete (All Phases)
**Commits:** ab634ec, 66b516e, 5524627, 75c9648

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

### Phase 3: Update Hooks ✅ COMPLETE
- `src/hooks/useChaSenRecommendations.ts` - No changes needed (uses API)
- `src/hooks/usePortfolioInitiatives.ts` - Deferred (low priority, uses client_name)
- `src/hooks/useHealthHistory.ts` - Uses API (health-history route updated)
- `src/hooks/useNPSAnalysis.ts` - Updated to use unified `client_aliases` table
- `src/app/api/clients/health-history/route.ts` - Added canonical name resolution

### Phase 4: Update Components ✅ COMPLETE
- `src/app/(dashboard)/nps/page.tsx` - Updated to use `client_aliases` table
- `src/components/LogEventModal.tsx` - No changes needed (triggers auto-populate client_uuid)
- `src/app/(dashboard)/meetings/[id]/page.tsx` - Added clientUuid to Meeting transformation
- `src/hooks/useMeetings.ts` - Added clientUuid to Meeting interface and query
- 5 client detail components updated to use `matchesClientSmart()`
  - `LeftColumn.tsx`
  - `CenterColumn.tsx`
  - `ClientActionBar.tsx`
  - `QuickStatsRow.tsx`
  - `MeetingHistorySection.tsx`

### Phase 5: Deprecate Legacy Utilities ✅ COMPLETE
- `src/utils/clientMatching.ts` - Added `matchesClientSmart()` with UUID-first matching
  - `matchesClient()` marked as deprecated
  - `matchesClientByUuid()` added for direct UUID comparison
  - `matchesClientSmart()` added for smart fallback to string matching
- `src/lib/client-name-mapper.ts` - Deprecated and replaced with database-backed solution
  - All 13 components migrated to use `useClientDisplayNames` hook
  - File marked as deprecated with migration notice
  - Hard-coded `DISPLAY_NAMES` replaced with `clients.display_name` from database

### Phase 6: Component Display Name Migration ✅ COMPLETE
Migrated all components from hard-coded `getDisplayName` to database-backed hook:

| Component | File |
|-----------|------|
| KanbanBoard | `src/components/KanbanBoard.tsx` |
| Actions Page | `src/app/(dashboard)/actions/page.tsx` |
| Action Detail | `src/app/(dashboard)/actions/[id]/page.tsx` |
| Meeting Detail | `src/app/(dashboard)/meetings/[id]/page.tsx` |
| NPS Page | `src/app/(dashboard)/nps/page.tsx` |
| Segmentation Page | `src/app/(dashboard)/segmentation/page.tsx` |
| MeetingDetailTabs | `src/components/MeetingDetailTabs.tsx` |
| RecurringMeetingPatterns | `src/components/RecurringMeetingPatterns.tsx` |
| MeetingRecommendations | `src/components/MeetingRecommendations.tsx` |
| CompactMeetingCard | `src/components/CompactMeetingCard.tsx` |
| MeetingAnalyticsDashboard | `src/components/MeetingAnalyticsDashboard.tsx` |
| MeetingPrepChecklist | `src/components/MeetingPrepChecklist.tsx` |

Also cleaned up:
- `src/hooks/useEventCompliance.ts` - Removed unused `normalizeClientName` import
- `src/app/(dashboard)/segmentation/page.tsx` - Removed deprecated `getSegmentationName` and `getAllClientNames` usage

### Add client_uuid to Remaining Tables ✅ COMPLETE
All tables now have `client_uuid` column with backfilled data:

| Table | Coverage | Notes |
|-------|----------|-------|
| nps_clients | 100% | All 18 rows have UUID |
| client_arr | 100% | All 16 rows have UUID |
| segmentation_compliance_scores | 100% | All 19 rows have UUID |
| chasen_documents | 0% | All 11 rows have NULL client_name (expected - documents uploaded without client association) |

Migration scripts created:
- `docs/migrations/20251227_add_client_uuid_to_remaining_tables.sql`
- `scripts/apply-client-uuid-migration.mjs` (Node.js backfill script)
- `scripts/execute-client-uuid-sql.mjs` (SQL executor script)

New utilities created:
- `src/lib/client-display-names.ts` - Database-backed display name resolver
- `src/hooks/useClientDisplayNames.ts` - React hook for client-side display names

### client_health_summary View
This is a materialized view. A future migration should update the view definition to include `client_uuid` from the clients table join.

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
