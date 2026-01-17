# Bug Report: Segment Column Not Displaying in Client Gap Diagnosis Table

**Date:** 17 January 2026
**Severity:** Medium
**Component:** Account Plan / Strategic Planning
**Status:** Fixed

## Summary

All clients in the Client Gap Diagnosis table (Account Plan page) displayed "Unknown" for the segment column, despite segment data existing in the database.

## Root Cause

The Supabase query in `loadPortfolioForOwner()` function was selecting the `tier` column but **not** the `segment` column from the `clients` table.

### File Affected
`/src/app/(dashboard)/planning/strategic/new/page.tsx`

### Before (Line 1331)
```typescript
const { data: ownerClients, error: clientsError } = await supabase
  .from('clients')
  .select('id, canonical_name, display_name, parent_id, tier')  // Missing 'segment'
  .eq('cse_name', ownerName)
  .eq('is_active', true)
```

### Fallback Chain (Line 1396)
```typescript
segment: health?.segment || c.tier || 'Unknown',  // c.tier was NULL
```

**Why it failed:**
1. `health?.segment` - May be null if `client_health_summary` join fails or no match found
2. `c.tier` - Was NULL in the database (column exists but not populated)
3. Falls through to `'Unknown'`

The `clients.segment` column **does** have data (Leverage, Steady State, etc.) but wasn't being selected in the query.

## Fix Applied

### Change 1: Added `segment` to select clause (Line 1331)
```typescript
.select('id, canonical_name, display_name, parent_id, segment, tier')
```

### Change 2: Updated fallback chain (Line 1396)
```typescript
segment: health?.segment || c.segment || c.tier || 'Unknown',
```

## Verification

- Build passes with no TypeScript errors
- ESLint passes
- Pre-commit hooks pass
- Deployed to production via Vercel auto-deploy

## Commit

```
74ca341c - Fix segment column not being displayed in Client Gap Diagnosis table
```

## Prevention

When writing Supabase queries:
1. Always verify ALL required columns are in the `select()` clause
2. Check the database schema before assuming column values
3. Test fallback chains with actual data, not just type correctness
