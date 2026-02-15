# Bug Report: ChaSen NPS Insights 404 Error for Valid Clients

**Date:** 2026-01-05
**Status:** ✅ RESOLVED
**Severity:** Medium
**Component:** ChaSen AI / NPS Insights API

---

## Problem Description

The ChaSen NPS Insights API was returning 404 errors for valid client names that exist in the `nps_responses` table:

```
[ChaSen NPS Insights] API error: 404 {}
Client "Epworth Healthcare" not found
Client "Ministry of Defence, Singapore" not found
```

This prevented NPS trend analysis from being generated for these clients, even though they had valid NPS data.

---

## Root Cause

The `nps-insights` API route was attempting to resolve client names to UUIDs using infrastructure that doesn't exist:

1. **Missing `clients` table**: The code expected a `clients` table with `id`, `canonical_name`, `display_name` columns
2. **Missing `client_aliases` table**: The code expected a `client_aliases` table for alias lookups
3. **Missing `resolve_client_id` RPC function**: The code called a PostgreSQL function that was never created

The `client-resolver.ts` library was designed for a unified client system that was never fully implemented, causing all UUID resolution attempts to fail.

---

## Solution

Updated the NPS insights API (`src/app/api/chasen/nps-insights/route.ts`) to:

1. **Remove dependency on client-resolver**: Removed unused imports for `resolveClientUUID` and `getClientByUUID`
2. **Validate directly against NPS responses**: Changed to case-insensitive lookup against the `nps_responses` table
3. **Use canonical name from database**: Use the exact client name from the database to ensure cache matching

### Code Changes

**Before:**
```typescript
import { resolveClientUUID, getClientByUUID } from '@/lib/client-resolver'
// ...
const clientUUID = await resolveClientUUID(clientName)
if (!clientUUID) {
  return NextResponse.json({ error: `Client "${clientName}" not found` }, { status: 404 })
}
const clientInfo = await getClientByUUID(clientUUID)
const canonicalName = clientInfo?.canonical_name || clientName
```

**After:**
```typescript
// Validate client exists in NPS responses (case-insensitive match)
const { data: clientCheck, error: clientCheckError } = await supabase
  .from('nps_responses')
  .select('client_name')
  .ilike('client_name', clientName.trim())
  .limit(1)
  .maybeSingle()

if (clientCheckError) {
  console.error('[ChaSen NPS Insights] Client validation error:', clientCheckError.message)
}

// Use the canonical client name from the database, or the provided name
const canonicalName = clientCheck?.client_name || clientName.trim()
```

---

## Files Modified

| File | Change |
|------|--------|
| `src/app/api/chasen/nps-insights/route.ts` | Replaced UUID resolution with direct NPS table lookup |

---

## Testing

Verified fix with both problematic clients:

```bash
node scripts/test-nps-insights.mjs

=== Testing: Epworth Healthcare ===
Status: 200
Response: { trend: "stable", confidence: "low", ... }

=== Testing: Ministry of Defence, Singapore ===
Status: 200
Response: { trend: "stable", confidence: "low", ... }
```

---

## Future Considerations

1. **Client UUID System**: If a unified client system is needed in the future, the `clients` and `client_aliases` tables should be created along with the `resolve_client_id` RPC function
2. **Client Resolver Cleanup**: The `src/lib/client-resolver.ts` file is now orphaned and could be removed or updated when the unified client system is implemented
3. **Cross-table Consistency**: Consider adding `client_uuid` foreign keys to related tables (`nps_responses`, `actions`, `unified_meetings`) when the client system is implemented

---

## Lessons Learned

- Always verify that dependent infrastructure (tables, functions) exists before deploying code that relies on them
- Console errors should be investigated promptly as they indicate production issues
- Case-insensitive matching (`ilike`) is important for client name lookups to handle variations
