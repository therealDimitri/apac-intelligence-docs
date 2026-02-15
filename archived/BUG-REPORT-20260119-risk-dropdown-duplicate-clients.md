# Bug Report: Duplicate Clients in Risk & Recovery Dropdown

**Status:** Fixed

## Date
2026-01-19

## Summary
The "Select a client" dropdown in the Risk & Recovery step was showing duplicate clients due to case-sensitive name matching when merging portfolio clients with pipeline opportunities.

## Root Cause
The `allClients` useMemo in `RiskRecoveryStep.tsx` (lines 612-629) was combining two data sources:
1. `portfolio` - clients from the clients table
2. `opportunities` - pipeline opportunities from sales_pipeline_opportunities table

The original code used exact string matching (`clientMap.has(o.client_name)`), which caused duplicates when:
- Clients table had: `Epworth Healthcare` (lowercase 'c')
- Pipeline table had: `Epworth HealthCare` (uppercase 'C')

## Examples of Duplicates Found

| Clients Table | Pipeline Table | Issue |
|--------------|----------------|-------|
| `Epworth Healthcare` | `Epworth HealthCare` | Case mismatch |
| `Barwon Health` (display) | `Barwon Health Australia` | Different format |
| `WA Health` | `Western Australia Department Of Health` | Different names |

## Fix Applied
Updated `RiskRecoveryStep.tsx` to use case-insensitive matching when checking if a client already exists:

```typescript
// Before: Exact string matching
if (o.client_name && !clientMap.has(o.client_name)) {
  clientMap.set(o.client_name, ...)
}

// After: Case-insensitive matching
const lowerCaseNames = new Map<string, string>()
// ... track lowercase names from portfolio
if (!lowerCaseNames.has(o.client_name.toLowerCase())) {
  // Only add if no case-insensitive match exists
}
```

Portfolio clients take priority over pipeline clients when there's a match.

## Files Modified
- `/src/app/(dashboard)/planning/strategic/new/steps/RiskRecoveryStep.tsx`

## Remaining Issues
Some duplicates may persist where names are genuinely different (not just case):
- "Barwon Health" vs "Barwon Health Australia" - these are different name formats
- "WA Health" vs "Western Australia Department Of Health" - completely different names

These would require fuzzy matching or data normalisation at the source.

## Recommendations
1. **Short-term**: The case-insensitive fix addresses the most common duplicate scenario
2. **Medium-term**: Normalise client names in the pipeline import to match the clients table exactly
3. **Long-term**: Use client IDs (UUIDs) instead of name matching for data joins

## Testing
- Build passes with zero TypeScript errors
- Dropdown should now show "Epworth Healthcare" only once (from portfolio)
