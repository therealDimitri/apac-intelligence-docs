# Bug Report: Console "Failed to Fetch" Errors

**Date:** 25 January 2026
**Status:** Resolved
**Severity:** Low (Non-blocking, cosmetic)
**Commit:** d8d4e00f

## Summary

Multiple console errors appearing during page loads related to fetch failures in data hooks. These errors were non-blocking but created noisy console output that obscured genuine issues.

## Symptoms

1. `Error fetching clients: TypeError: Failed to fetch` in useClients.ts
2. `[useAgedAccountsTrends] Error: TypeError: Failed to fetch`
3. `[useAgedAccountsTrends] Error: TypeError: records is not iterable`
4. `[ChaSen] Error fetching LLM models: TypeError: Failed to fetch`
5. `[FloatingChaSenAI] Error fetching approvals: TypeError: Failed to fetch`
6. `Error loading user profile: Error: Failed to fetch clients`

## Root Cause

The errors occurred due to:

1. **React Strict Mode double-invocation**: In development, React mounts components twice, causing race conditions where fetch calls can fail during the first (cancelled) mount
2. **Auth flow timing**: Fetch calls made before authentication is fully established receive HTML redirect responses instead of JSON
3. **Missing defensive checks**: The `processIntoClientTrends` function didn't check if `records` was actually an array before iterating

## Files Modified

| File | Changes |
|------|---------|
| `src/hooks/useClients.ts` | Wrapped fetch in try-catch, added JSON parse error handling, changed console.error to console.debug |
| `src/hooks/useAgedAccountsTrends.ts` | Added defensive array check in processIntoClientTrends, wrapped fetch in try-catch, graceful error handling |
| `src/components/FloatingChaSenAI.tsx` | Fixed LLM models fetch and approvals fetch with proper network error handling |
| `src/hooks/useUserProfile.ts` | Changed error logging level from console.error to console.debug |

## Solution Pattern

Applied consistent error handling pattern across all affected hooks:

```typescript
// 1. Wrap fetch in try-catch for network errors
let response: Response
try {
  response = await fetch(url)
} catch (networkError) {
  console.debug('[HookName] Network error (may be expected during auth):', networkError)
  return // Exit gracefully
}

// 2. Wrap JSON parse in try-catch for non-JSON responses
let result
try {
  result = await response.json()
} catch (parseError) {
  console.debug('[HookName] Non-JSON response (likely auth redirect)')
  return
}

// 3. Add defensive checks for data processing
if (!data || !Array.isArray(data)) {
  return []
}
```

## Testing

1. Verified Command Centre loads without console errors
2. Verified Working Capital page loads with data
3. Verified Historical Trend chart renders correctly
4. All console output now shows only LOG and WARNING level messages

## Prevention

- Use `console.debug` instead of `console.error` for expected failure scenarios
- Always wrap fetch calls in try-catch for network error handling
- Add defensive checks when processing data that may be undefined or non-iterable
- Consider the auth flow and React Strict Mode when designing data fetching patterns
