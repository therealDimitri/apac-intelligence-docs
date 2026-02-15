# Bug Report: ChaSen Natural Language Parser Using Incorrect Client List

**Date:** 27 December 2025
**Status:** ✅ Fixed
**Severity:** Medium
**Component:** ChaSen AI Meeting Scheduler

---

## Problem Description

The ChaSen natural language meeting parser was using a different client data source than the standard client dropdown, causing inconsistent client matching.

### Symptoms
- ChaSen AI could not match some client names that appeared in the manual dropdown
- Client name suggestions from ChaSen differed from the dropdown options
- Fuzzy matching produced inconsistent results between the two input methods

### Root Cause

The parse-natural-language API endpoint was querying the `nps_clients` table:

```typescript
// BEFORE (incorrect)
const { data: clients } = await supabase
  .from('nps_clients')
  .select('id, name')
  .order('name')

const clientNames = clients?.map(c => c.name) || []
```

However, the standard client dropdown (used across the application) queries the `client_health_summary` materialised view via the `/api/clients` endpoint.

---

## Solution Applied

Updated the parse-natural-language API to use the same data source as the standard client dropdown:

**File:** `src/app/api/meetings/parse-natural-language/route.ts`

```typescript
// AFTER (fixed)
const { data: clients } = await supabase
  .from('client_health_summary')
  .select('id, client_name')
  .order('client_name')

const clientNames = clients?.map(c => c.client_name).filter(Boolean) || []
```

### Changes Made
1. Changed table from `nps_clients` to `client_health_summary` view
2. Changed column from `name` to `client_name`
3. Added `.filter(Boolean)` to handle any null values
4. Added comment explaining the data source consistency

---

## Verification

**Test Input:** "QBR with Epworth next Tuesday at 2pm"

**Expected Result:**
- Client should match "Epworth Healthcare" from the standard list

**Actual Result (after fix):**
- ✅ Client correctly matched to "Epworth Healthcare"
- ✅ Meeting type correctly identified as "Quarterly Business Review"
- ✅ Date correctly calculated as 2025-12-30
- ✅ Time correctly parsed as 14:00
- ✅ All fields show "High confidence"

---

## Files Modified

| File | Change |
|------|--------|
| `src/app/api/meetings/parse-natural-language/route.ts` | Changed client data source from `nps_clients` to `client_health_summary` |

---

## Related Components

- `src/hooks/useClients.ts` - Uses `/api/clients` for standard client data
- `src/app/api/clients/route.ts` - Queries `client_health_summary` view
- `src/components/QuickScheduleInput.tsx` - ChaSen natural language input component
- `src/components/UniversalMeetingModal.tsx` - Meeting creation modal

---

## Prevention Measures

To prevent similar data source inconsistencies in the future:

1. **Single Source of Truth:** All client-related queries should use the `client_health_summary` materialised view
2. **Code Review Checklist:** When adding new client-related features, verify the data source matches existing patterns
3. **Documentation:** The `client_health_summary` view is the canonical source for client data across the application
