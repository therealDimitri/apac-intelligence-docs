# Enhancement: CLV Parent-Child Client Consolidation

**Date**: 2026-01-19
**Type**: Enhancement
**Component**: Historical Revenue Dashboard - Client Lifetime Value Table
**Status**: Completed

## Description

The Client Lifetime Value (CLV) table was showing separate entries for parent and child client entities, making it difficult to see the true consolidated revenue for client relationships. For example, "SA Health (iPro)", "SA Health (Sunrise)", and "SA Health" were displayed as separate entries instead of being consolidated under "SA Health".

## Root Cause

The `getClientLifetimeValue()` function in the historical revenue API was aggregating data directly by `client_name` without considering parent-child relationships between related client entities.

## Solution

Added a `CLIENT_PARENT_MAP` constant and `getConsolidatedClientName()` helper function to map child client names to their parent company for CLV aggregation.

### Consolidated Client Families

| Parent Company | Child Entities |
|---------------|----------------|
| SA Health | SA Health (iPro), SA Health (Sunrise), SA Health (iQemo), Minister for Health AKA South Australia Health |
| SingHealth | Singapore Health Services, Singapore Health Services Pte Ltd |
| WA Health | Western Australia DoH, Western Australia Department Of Health |
| GHA | Gippsland Health Alliance, Gippsland Health Alliance (GHA) |
| GRMC | GRMC (Guam Regional Medical Centre), Guam Regional Medical City (GRMC), Guam Regional Medical City |
| SLMC | St Luke's Medical Center Global City Inc, Saint Luke's Medical Centre (SLMC), St. Luke's Medical Center |
| NCS/MinDef Singapore | Ministry of Defence, Singapore, NCS PTE Ltd, NCS Pte Ltd |

### Code Changes

```typescript
// Added parent-child mapping constant
const CLIENT_PARENT_MAP: Record<string, string> = {
  'SA Health (iPro)': 'SA Health',
  'Singapore Health Services Pte Ltd': 'SingHealth',
  // ... other mappings
}

// Helper function for consolidation
function getConsolidatedClientName(clientName: string): string {
  return CLIENT_PARENT_MAP[clientName] || clientName
}

// Updated aggregation logic
allData.forEach(row => {
  const rawClient = row.client_name
  if (!rawClient) return

  // Use consolidated parent name for aggregation
  const client = getConsolidatedClientName(rawClient)
  // ... rest of aggregation
})
```

## Files Modified

1. `src/app/api/analytics/burc/historical/route.ts` - Added CLIENT_PARENT_MAP, getConsolidatedClientName(), and updated aggregation logic

## Expected Result

After cache invalidation (server restart or cache clear), the CLV table will show:
- Consolidated revenue for parent companies
- Combined years active spanning all child entities
- Accurate trend data reflecting total client relationship value

## Commit

`7c266b2d` - feat: Add parent-child client consolidation in CLV table
