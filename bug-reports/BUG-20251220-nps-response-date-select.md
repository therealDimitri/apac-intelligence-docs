# Bug Report: Missing response_date in NPS Analytics Query

**Date:** 20 December 2025
**Status:** Fixed
**Component:** Analytics Dashboard API

## Issue

TypeScript build error in `src/app/api/analytics/dashboard/route.ts`:

```
Property 'response_date' does not exist on type '{ score: any; client_name: any; feedback: any; period: any; }'.
```

## Root Cause

The Supabase select query for `nps_responses` did not include the `response_date` column, but the code was attempting to access it as a fallback for trend grouping.

## Fix Applied

Added `response_date` to the select query:

**Before:**

```typescript
.select('score, client_name, feedback, period')
```

**After:**

```typescript
.select('score, client_name, feedback, period, response_date')
```

## File Modified

- `src/app/api/analytics/dashboard/route.ts` (line 218)

## Prevention

Always verify that all columns accessed in code are included in the Supabase select query. Reference `docs/database-schema.md` for available columns.
