# Bug Report: Pipeline Opportunity Dropdown Empty in Risk & Recovery

**Date:** 2026-01-19
**Severity:** Medium
**Status:** Fixed
**Component:** Risk & Recovery Step (Account Planning Coach)

## Summary

The Pipeline Opportunity dropdown in the Add Risk form was not displaying any opportunities when a client was selected, even though opportunities existed for that client.

## Symptoms

- User selects a client (e.g., "SA Health") in the Add Risk form
- Pipeline Opportunity dropdown shows "Select opportunity..." with no options
- Opportunities for that client exist in the `sales_pipeline_opportunities` table

## Root Cause

The `clientOpportunities` filter in `RiskRecoveryStep.tsx` was not using the client alias resolution system (`useClientAliases`), while the `allClients` list did use it.

**Before (broken):**
```typescript
const clientOpportunities = useMemo(() => {
  if (!selectedClient) return []
  const normalizedSelected = selectedClient
    .replace(/\s*⚠️\s*$/, '')
    .toLowerCase()
    .trim()
  return opportunities.filter(o => {
    if (!o.client_name) return false
    const normalizedOppClient = o.client_name.toLowerCase().trim()
    // Only direct string matching - no alias resolution!
    return (
      normalizedOppClient === normalizedSelected ||
      normalizedOppClient.includes(normalizedSelected) ||
      normalizedSelected.includes(normalizedOppClient)
    )
  })
}, [selectedClient, opportunities])
```

This caused mismatches when:
- Portfolio client name: "SA Health"
- Pipeline opportunity client name: "South Australia Health"
- These should match via the `client_name_aliases` table, but didn't

## Fix Applied

Added `resolveClientName` from `useClientAliases` hook to the filter logic:

**After (fixed):**
```typescript
const clientOpportunities = useMemo(() => {
  if (!selectedClient) return []
  const normalizedSelected = selectedClient
    .replace(/\s*⚠️\s*$/, '')
    .toLowerCase()
    .trim()
  // Resolve the canonical name for the selected client
  const canonicalSelected = resolveClientName(
    selectedClient.replace(/\s*⚠️\s*$/, '')
  ).toLowerCase().trim()

  return opportunities.filter(o => {
    if (!o.client_name) return false
    const normalizedOppClient = o.client_name.toLowerCase().trim()
    // Resolve the canonical name for the opportunity's client
    const canonicalOppClient = resolveClientName(o.client_name).toLowerCase().trim()

    // Match using multiple strategies:
    // 1. Direct match (exact or contains)
    // 2. Canonical name match (after alias resolution)
    return (
      // Direct matching
      normalizedOppClient === normalizedSelected ||
      normalizedOppClient.includes(normalizedSelected) ||
      normalizedSelected.includes(normalizedOppClient) ||
      // Canonical name matching (via alias table)
      canonicalOppClient === canonicalSelected ||
      canonicalOppClient.includes(canonicalSelected) ||
      canonicalSelected.includes(canonicalOppClient)
    )
  })
}, [selectedClient, opportunities, resolveClientName])
```

## Files Changed

| File | Change |
|------|--------|
| `src/app/(dashboard)/planning/strategic/new/steps/RiskRecoveryStep.tsx` | Added alias resolution to clientOpportunities filter |

## Data Flow

```
User selects "SA Health" in Client dropdown
    ↓
clientOpportunities filter runs
    ↓
resolveClientName("SA Health") → "South Australia Health" (canonical)
    ↓
Compare against opportunities:
  - opportunity.client_name = "South Australia Health"
  - resolveClientName("South Australia Health") → "South Australia Health"
    ↓
Match found! Opportunity appears in dropdown
```

## Related Issues

- Previous bug fix: `BUG-REPORT-20260119-risk-dropdown-duplicate-clients.md` - Similar alias resolution issue for client dropdown

## Testing

1. Navigate to Account Planning Coach
2. Go to Step 5 (Risk & Recovery)
3. Click "Add Risk"
4. Select a client that has pipeline opportunities
5. Verify Pipeline Opportunity dropdown shows matching opportunities

## Prevention

- Always use `useClientAliases` hook when comparing client names across different data sources
- The codebase has multiple tables with client names that may use different formats:
  - `clients` table: canonical names
  - `sales_pipeline_opportunities`: `account_name` field (from Excel imports)
  - `unified_meetings`: `client_name` (user-entered)
  - `nps_responses`: `client_name` (from NPS system)

## Commit

```
Fix Pipeline Opportunity dropdown not showing opportunities in Risk & Recovery

The clientOpportunities filter was not using client alias resolution,
causing it to miss opportunities when the client name in the portfolio
differs from the client name in the pipeline.

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```
