# Bug Report: Support Health Page Enhancements

**Date:** 8 January 2026
**Status:** Fixed
**Commit:** `01dd3d67`

## Issues Addressed

### 1. SLA% Shows N/A for All Clients
**Root Cause:** The `resolution_sla_percent` column is NULL in the `support_sla_metrics` table for all imported records. The source data does not include SLA percentage values.

**Status:** Data issue - N/A display is correct behaviour. The API and UI correctly handle null values.

### 2. Albury Wodonga CSAT Shows N/A
**Root Cause:** The `satisfaction_score` column is NULL for Albury Wodonga Health in the database.

**Status:** Data issue - N/A display is correct behaviour.

### 3. "View Support Details" Link Not Working
**Root Cause:** Links were using incorrect URL format:
- Before: `/clients/${client_uuid || client_name}?tab=support`
- Missing `/v2` suffix and proper URL encoding

**Solution:** Updated to use proper format with `/v2` suffix:
```typescript
const clientLink = m.client_uuid
  ? `/clients/${m.client_uuid}/v2`
  : `/clients/${encodeURIComponent(m.canonical_name || m.client_name)}/v2`
```

### 4. Missing CSE Filter
**Solution:** Added CSE filter dropdown to the table header:
- API now returns `cseList` with unique CSE names
- API supports `?cse=<name>` query parameter for filtering
- Dropdown shows all CSEs assigned to clients with support metrics

### 5. Missing Client Logos
**Solution:** Added `ClientLogoDisplay` component to each table row:
- Uses canonical client name for logo lookup
- Falls back to initials with consistent colour

### 6. Not Using Canonical Client Names
**Solution:** API now enriches data with canonical names from `client_name_aliases` table:
- Added `canonical_name` field to response
- UI displays canonical name instead of raw support system name
- Shows CSE name below client name for easy identification

## Files Modified

### API Route
**`/src/app/api/support-metrics/route.ts`**
- Added `canonical_name` and `cse_name` to `SupportMetrics` interface
- Fetch and cache `client_name_aliases` for canonical name resolution
- Fetch `client_segmentation` for CSE assignments and `client_uuid`
- Added `?cse=<name>` filter parameter
- Return `cseList` array for filter dropdown

### Component
**`/src/components/support/SupportOverviewTable.tsx`**
- Added CSE filter dropdown using `Select` component
- Added `ClientLogoDisplay` to each table row
- Display canonical name with CSE name below
- Fixed client links to use `/v2` suffix and proper encoding

## Data Resolution Flow

```
support_sla_metrics.client_name
        ↓
client_name_aliases → canonical_name
        ↓
client_segmentation → cse_name, client_uuid
        ↓
Display: canonical_name with logo
Link: /clients/{uuid}/v2 or /clients/{encoded_name}/v2
```

## Verification

- TypeScript: Passed
- ESLint: Passed
- API Response: Includes `canonical_name`, `cse_name`, `client_uuid`, `cseList`

## Notes on Data Quality

The following data issues exist in the source data (not bugs):
- `resolution_sla_percent` is NULL for all clients
- `satisfaction_score` is NULL for Albury Wodonga Health

These fields display as "N/A" which is the correct behaviour for missing data.

## Related Files

- `/src/lib/client-logos-local.ts` - Client logo mapping
- `/src/components/ClientLogoDisplay.tsx` - Logo display component
- `/src/app/(dashboard)/clients/[clientId]/v2/page.tsx` - Client profile page
