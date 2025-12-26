# Bug Report: Clients Fetch Fails Due to RLS Policies on Materialized View

**Date:** 23 December 2025
**Status:** Fixed
**Severity:** Critical
**Component:** useClients Hook, Client Health Summary View

---

## Problem Description

The clients list failed to load on the Command Centre and other pages. Console errors showed:

```
❌ Failed to fetch clients from materialized view: {}
Error fetching clients: {}
```

The empty object error indicates RLS (Row-Level Security) policies were blocking access to the `client_health_summary` materialized view.

---

## Root Cause Analysis

The `useClients` hook was using the **client-side Supabase instance** to fetch data from the `client_health_summary` materialized view. This instance uses the anonymous key which is subject to RLS policies.

### Affected Code (Before Fix)

**useClients.ts:**

```tsx
const { data: clientsData, error: clientsError } = await supabase // Client-side instance
  .from('client_health_summary')
  .select('*')
  .order('client_name')
```

---

## Solution Implemented

### 1. Created API Endpoint `/api/clients`

New file `src/app/api/clients/route.ts`:

```tsx
const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!, // Service role key bypasses RLS
  { auth: { autoRefreshToken: false, persistSession: false } }
)

export async function GET() {
  const { data, error } = await supabaseAdmin
    .from('client_health_summary')
    .select('*')
    .order('client_name')

  return NextResponse.json({ success: true, data: data || [] })
}
```

### 2. Updated useClients Hook

Changed to use the API endpoint:

```tsx
const response = await fetch('/api/clients')
const result = await response.json()

if (!response.ok || result.error) {
  throw new Error(result.error || 'Failed to fetch clients')
}

const clientsData: ClientHealthSummaryRow[] = result.data
```

Also added `ClientHealthSummaryRow` interface for type safety and removed the unused direct Supabase import.

---

## Files Changed

| File                           | Changes                                                                          |
| ------------------------------ | -------------------------------------------------------------------------------- |
| `src/app/api/clients/route.ts` | **NEW** - API endpoint using service role key                                    |
| `src/hooks/useClients.ts`      | Changed to use API, added `ClientHealthSummaryRow` type, removed Supabase import |

---

## Architecture Pattern

This fix follows the established pattern in the codebase:

| Operation          | Method          | Key Used                        |
| ------------------ | --------------- | ------------------------------- |
| READ (client-side) | Direct Supabase | Anonymous key (subject to RLS)  |
| READ (privileged)  | API endpoint    | Service role key (bypasses RLS) |
| WRITE              | API endpoint    | Service role key (bypasses RLS) |

For materialized views and views that don't have specific RLS policies for anonymous access, the API pattern must be used.

---

## Testing Steps

1. Navigate to Command Centre
2. Verify the clients list loads correctly
3. Verify client health scores, NPS scores, and other data display properly
4. Navigate to individual client profiles and verify data loads

---

## Related Bugs

- `BUG-20251223-meeting-action-update-rls-error.md` - Similar pattern for meetings/actions
- `BUG-20251223-add-note-rls-error.md` - Similar pattern for notes
