# Bug Report: ChaSen Returning Empty Portfolio Data

## Date

2025-12-24

## Severity

**Critical** - ChaSen AI returns empty/zero data for legitimate portfolio queries

## Summary

ChaSen was incorrectly classifying queries about portfolio data as "simple queries" and skipping the database fetch entirely. This resulted in responses showing 0 clients, $0 revenue, and no insights despite real data existing in the dashboard.

## Symptom

When asking ChaSen about portfolio status, the response showed:

- "0 Focus Clients"
- "$0 USD Renewal Opportunities"
- "No high-priority risks identified"
- Generic "healthy portfolio" language despite actual issues existing

## Root Cause

The "fast path" optimisation (added to prevent Netlify timeouts) was too aggressive. The keyword detection regex on line 789-790 only checked for:

```typescript
;/client|nps|health|meeting|action|risk|revenue|arr|aging|renewal/i
```

**Missing keywords included:**

- `portfolio` - The most common way users ask about their data
- `summary`, `overview`, `insight`
- `dashboard`, `report`, `status`
- `score`, `compliance`, `segment`
- `performance`, `metric`, `trend`
- `alert`, `priority`, `focus`
- `week`, `month`, `quarter`

Additionally, the length threshold was 20 characters, which caught many legitimate short queries like "show my portfolio" (17 chars).

## Fix Applied

1. **Expanded keyword list** to include all business-relevant terms:

```typescript
const dataKeywords =
  /client|nps|health|meeting|action|risk|revenue|arr|aging|renewal|portfolio|summary|overview|insight|data|dashboard|report|status|score|compliance|segment|performance|metric|trend|alert|priority|focus|week|month|quarter/i
```

2. **Reduced length threshold** from 20 to 15 characters

3. **Tightened greeting/help patterns** to be more specific (must match entire query, not just start)

## Files Modified

- `src/app/api/chasen/chat/route.ts`

## Testing

- [x] TypeScript compilation passes
- [ ] Test: "show my portfolio" → should fetch real data
- [ ] Test: "what's my health score" → should fetch real data
- [ ] Test: "weekly summary" → should fetch real data
- [ ] Test: "hi" → should use fast path (no data fetch)
- [ ] Test: "hello!" → should use fast path (no data fetch)

## Prevention

When adding performance optimisations that skip data fetching:

1. Log extensively which path was taken
2. Include ALL business domain keywords in exclusion lists
3. Test with real user queries before deploying
4. Consider a whitelist approach (only skip for exact greeting matches) rather than blacklist
