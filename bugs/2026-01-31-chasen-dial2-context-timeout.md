# Bug Report: ChaSen Not Displaying BURC Dial 2 Pipeline Data

**Date:** 31 January 2026
**Status:** Fixed
**Commit:** e9ba84a4
**Severity:** Medium

## Summary

ChaSen AI was not displaying BURC Dial 2 pipeline opportunity data even though the data was being correctly fetched from the database and added to the context.

## Symptoms

- User asks "What are our Best Case opportunities?"
- ChaSen responds: "information regarding 'Best Case' opportunities is not currently within my accessible data sources"
- Server logs showed data WAS being fetched (66 records)
- Server logs showed context WAS being built with Dial 2 data

## Root Cause

The `getLiveDashboardContext()` function in `src/app/api/chasen/stream/route.ts` now has 25+ sequential database queries. With a 15-second `Promise.race` timeout, the race condition was being hit before all queries completed.

```typescript
// Before (15 seconds was not enough)
Promise.race([
  getLiveDashboardContext(clientName),
  new Promise<string>(resolve => setTimeout(() => resolve(''), 15000)),
])
```

When the timeout resolved first with an empty string, the actual dashboard context (including Dial 2 data) was discarded, even though the function eventually completed successfully.

## Fix

1. Increased the timeout from 15 seconds to 25 seconds
2. Added a warning log when timeout is exceeded for future debugging

```typescript
// After
Promise.race([
  getLiveDashboardContext(clientName),
  new Promise<string>(resolve =>
    setTimeout(() => {
      console.warn('[ChaSen Stream] Dashboard context TIMEOUT - 25s exceeded')
      resolve('')
    }, 25000)
  ),
])
```

## Files Changed

- `src/app/api/chasen/stream/route.ts` - Increased timeout and added warning log

## Verification

After the fix:
- ChaSen correctly displays Best Case Green/Yellow/Red opportunities
- Response includes specific project names and close dates
- Data confidence shows "High" with source "BURC Dial 2 Pipeline Overview"

## Lessons Learned

1. Sequential database queries can accumulate significant latency
2. `Promise.race` timeouts should be generous when many async operations are involved
3. Always verify the context is actually being received by the LLM, not just built
4. Adding timeout warning logs helps diagnose race conditions in production

## Related

- `burc_dial2_opportunities` table created in previous session
- `scripts/sync-burc-dial2.mjs` syncs data from BURC Excel file
