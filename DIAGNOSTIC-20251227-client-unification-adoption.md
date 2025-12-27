# Client Unification Migration - Diagnostic Report

**Date:** 2025-12-27
**Status:** Database Complete, Application Update Required
**Priority:** High

---

## Executive Summary

The client unification migration has successfully created the database infrastructure with 32 clients, 77 aliases, and 10 auto-resolve triggers. However, **the application code has not yet been updated** to use the new `client_uuid` columns - all queries still use string-based `client_name` matching.

---

## Benefits of Client Unification

### 1. **Data Integrity**
- Single source of truth for client identity via `clients` table
- UUID-based foreign keys eliminate string matching errors
- Case-insensitive alias lookup handles variations automatically

### 2. **Performance Improvements**
- UUID joins are faster than string comparisons
- Indexed `client_uuid` columns enable efficient lookups
- No more full-table scans for fuzzy string matching

### 3. **Automatic Resolution**
- 10 database triggers auto-populate `client_uuid` on INSERT/UPDATE
- New records automatically linked to correct client
- `resolve_client_id()` function handles alias matching

### 4. **Reduced Maintenance**
- Add new aliases via `add_client_alias()` function
- No code changes needed for new client name variations
- Parent-child hierarchies (e.g., SingHealth subsidiaries) built-in

### 5. **Query Simplification**
```sql
-- Before (fragile string matching)
SELECT * FROM unified_meetings WHERE client_name = 'Barwon Health'

-- After (reliable UUID join)
SELECT * FROM unified_meetings um
JOIN clients c ON um.client_uuid = c.id
WHERE c.canonical_name = 'Barwon Health Australia'
```

---

## Database Status ✅

| Component | Count | Status |
|-----------|-------|--------|
| Clients | 32 | ✅ Complete |
| Aliases | 77 | ✅ Complete |
| Auto-resolve Triggers | 10 | ✅ Installed |
| Views | 3 | ✅ Created |

### Tables with `client_uuid` Column
| Table | Coverage | Notes |
|-------|----------|-------|
| unified_meetings | 73% | Internal meetings = NULL (expected) |
| actions | 88% | Cross-client actions = NULL (expected) |
| client_segmentation | 100% | ✅ |
| aging_accounts | 100% | ✅ |
| nps_responses | 100% | ✅ |
| portfolio_initiatives | 100% | Uses `client_id` (UUID) |
| client_health_history | 100% | Uses `client_id` (UUID) |

---

## Application Code Status ⚠️

### Files Using `client_uuid`: **0**
### Files Using String Matching: **12+ API routes, 30+ hooks/components**

---

## Files Requiring Update

### Critical API Routes (12 files)

| File | Priority | Current Pattern |
|------|----------|-----------------|
| `src/app/api/chasen/meeting-prep/route.ts` | HIGH | 8x `.eq('client_name', ...)` |
| `src/app/api/chasen/recommend-actions/route.ts` | HIGH | 2x `.eq('client_name', ...)` |
| `src/app/api/chasen/nps-insights/route.ts` | HIGH | 1x `.eq('client_name', ...)` |
| `src/app/api/chasen/analyze/route.ts` | HIGH | 1x `.eq('client_name', ...)` |
| `src/app/api/chasen/folders/route.ts` | MEDIUM | 2x `.eq('client_name', ...)` |
| `src/app/api/clients/health-insights/route.ts` | HIGH | 4x `.eq('client_name', ...)` |
| `src/app/api/clients/health-history/route.ts` | HIGH | 1x `.eq('client_name', ...)` |
| `src/app/api/comments/by-client/route.ts` | MEDIUM | 1x `.eq('client_name', ...)` |
| `src/app/api/aging-alerts/check/route.ts` | MEDIUM | 1x `.eq('client_name', ...)` |
| `src/app/api/segmentation-events/route.ts` | MEDIUM | 1x `.eq('client_name', ...)` |
| `src/app/api/cse-suggestions/route.ts` | MEDIUM | 1x `.eq('client_name', ...)` |
| `src/app/api/cron/aged-accounts-snapshot/route.ts` | LOW | 1x `.eq('client_name', ...)` |

### Hooks (5 files)

| File | Issue |
|------|-------|
| `src/hooks/useChaSenRecommendations.ts` | Uses `clientName` string parameter |
| `src/hooks/usePortfolioInitiatives.ts` | Uses `.ilike('client_name', ...)` |
| `src/hooks/useHealthHistory.ts` | Uses `clientName` string parameter |
| `src/hooks/useStreamingChat.ts` | Passes `clientName` to API |
| `src/hooks/useNPSAnalysis.ts` | Uses `.eq('client_name', ...)` |

### Legacy Utilities (2 files)

| File | Notes |
|------|-------|
| `src/lib/client-name-mapper.ts` | Hardcoded display name mapping - should use `clients.display_name` |
| `src/utils/clientMatching.ts` | Fuzzy string matching - should use `client_uuid` |

### Dashboard Components

- `src/app/(dashboard)/nps/page.tsx` - Uses `.eq('client_name', ...)`
- `src/components/LogEventModal.tsx` - Uses `.eq('client', ...)`
- Multiple components passing `clientName` props

---

## Recommended Migration Path

### Phase 1: Create Client Resolution Helper (Immediate)
```typescript
// src/lib/client-resolver.ts
export async function resolveClientUUID(clientName: string): Promise<string | null> {
  const { data } = await supabase.rpc('resolve_client_id', { p_name: clientName })
  return data
}
```

### Phase 2: Update Critical ChaSen APIs (High Priority)
1. `meeting-prep/route.ts` - Highest impact, 8 queries
2. `recommend-actions/route.ts` - Core AI feature
3. `nps-insights/route.ts` - NPS analysis

### Phase 3: Update Client Hooks (Medium Priority)
1. Add `clientUUID` to hook parameters
2. Deprecate `clientName` parameter
3. Update all consumers

### Phase 4: Update Dashboard Components (Lower Priority)
1. Pass `clientUUID` instead of `clientName`
2. Use `clients.display_name` for UI labels

### Phase 5: Deprecate Legacy Utilities
1. Replace `client-name-mapper.ts` with database lookups
2. Replace `clientMatching.ts` with UUID comparison

---

## Query Migration Examples

### Before (String Matching)
```typescript
const { data } = await supabase
  .from('unified_meetings')
  .select('*')
  .eq('client_name', clientName)
```

### After (UUID Join)
```typescript
// Option 1: Direct UUID lookup
const { data } = await supabase
  .from('unified_meetings')
  .select('*')
  .eq('client_uuid', clientUUID)

// Option 2: Resolve on-the-fly (for legacy compatibility)
const { data: clientId } = await supabase.rpc('resolve_client_id', { p_name: clientName })
const { data } = await supabase
  .from('unified_meetings')
  .select('*')
  .eq('client_uuid', clientId)
```

---

## Testing Checklist

After each file update:
- [ ] Verify queries return correct results
- [ ] Test with client aliases (e.g., "GHA" should match "Gippsland Health Alliance")
- [ ] Test internal/multi-client entries (NULL `client_uuid` is valid)
- [ ] Run `npm run build` to catch TypeScript errors
- [ ] Test in browser for UI regressions

---

## Monitoring

Use the `client_id_backfill_status` view to monitor adoption:
```sql
SELECT * FROM client_id_backfill_status ORDER BY percentage;
```

Check for new unresolved names:
```sql
SELECT * FROM client_unresolved_names WHERE NOT resolved ORDER BY record_count DESC;
```

---

## Conclusion

The database infrastructure is complete and working. The triggers automatically populate `client_uuid` for new records. However, to fully realise the benefits of the unification, the application code needs to be updated to:

1. Query using `client_uuid` instead of `client_name`
2. Use `clients.display_name` for UI labels
3. Remove hardcoded mappings in `client-name-mapper.ts`

**Estimated effort:** 2-3 hours for critical APIs, additional time for full adoption
