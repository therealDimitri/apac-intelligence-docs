# Bug Report: Client Dropdown Issues in Action Detail Modal

**Date:** 22 December 2024
**Status:** Fixed
**Component:** ActionDetailModal.tsx

---

## Problems Identified

### Issue 1: Duplicate "Internal" Entry

When editing an action, "Internal" appeared twice in the Client dropdown.

### Issue 2: Missing Clients

The dropdown only showed 18 clients from `client_health_summary` view, but actions contained 24 unique client names. Clients like "SA Health", "Ministry of Defence, Singapore", etc. were missing.

## Root Causes

### Issue 1

"Internal" was hardcoded AND loaded from database, causing duplication.

### Issue 2

The `useClients` hook fetched from `client_health_summary` materialized view which only contains clients with health metrics. Clients referenced only in actions but not in the health summary were missing.

## Solution

1. Replaced `useClients` hook with direct query to actions table
2. Changed from `<input>` + `<datalist>` to proper `<select>` dropdown (datalist only shows suggestions when typing, not a full list)

```tsx
// Fetch unique clients from actions table
useEffect(() => {
  async function fetchUniqueClients() {
    const { data, error } = await supabase
      .from('actions')
      .select('client')
      .not('client', 'is', null)

    const clientNames = [...new Set(data?.map(a => a.client).filter(Boolean))] as string[]
    clientNames.sort((a, b) => a.localeCompare(b))

    const filteredClients = clientNames.filter(c => c.toLowerCase() !== 'internal')
    setUniqueClients(['Internal', ...filteredClients])
  }
  fetchUniqueClients()
}, [])

// Changed from datalist to select dropdown
<select value={editClient} onChange={e => setEditClient(e.target.value)}>
  {uniqueClients.map(clientName => (
    <option key={clientName} value={clientName}>{clientName}</option>
  ))}
</select>
```

## Files Modified

- `src/components/ActionDetailModal.tsx`
  - Removed `useClients` hook import
  - Added `uniqueClients` state with direct Supabase query
  - Changed `<input list="...">` + `<datalist>` to `<select>` dropdown

## Testing

- Open Action Detail Modal in edit mode
- Click the Client dropdown
- All 24 clients from action cards now appear
- "Internal" appears only once at the top
- Build passes successfully

## Prevention

When populating dropdowns that reference data from multiple sources, query the actual source of the data (in this case, the actions table) rather than a derived view that may not contain all values.
