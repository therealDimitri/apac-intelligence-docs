# Bug Report: Planning Hub Infinite Re-render and Database Column Errors

**Date:** 8 January 2026
**Severity:** Critical
**Status:** Resolved
**Commit:** `3d70598e`

## Summary

The Planning Hub pages were failing to load data, showing an "Error loading data: {}" message in the console. Investigation revealed two root causes that were causing cascading failures.

## Symptoms

- Territory Strategy wizard stuck on loading spinner
- Console error: `Error loading data: {}`
- Page continuously re-rendering (visible through React DevTools)
- After fixing re-render: `column clients.client_name does not exist` error

## Root Causes

### Issue 1: Supabase Client Recreation on Every Render

The Supabase client was being created inside React components:

```typescript
// BAD - Inside component
function NewTerritoryStrategyPage() {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );

  useEffect(() => {
    // ... load data
  }, [supabase]); // supabase changes on every render!
}
```

This caused:
1. New supabase instance created on every render
2. `useEffect` dependency array included `supabase`
3. Effect triggered on every render → state update → re-render → infinite loop

### Issue 2: Incorrect Database Column Name

The planning pages queried a non-existent column:

```typescript
// BAD - column doesn't exist
const { data: clients } = await supabase
  .from('clients')
  .select('id, client_name')  // client_name doesn't exist!
```

The actual columns in the `clients` table are:
- `canonical_name` - internal normalised name
- `display_name` - human-readable display name

## Solution

### Fix 1: Move Supabase Client to Module Level

```typescript
// GOOD - Outside component at module level
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);

function NewTerritoryStrategyPage() {
  useEffect(() => {
    // ... load data
  }, []); // Empty deps - runs once on mount
}
```

### Fix 2: Use Correct Column Names

```typescript
// GOOD - correct columns
const { data: clients } = await supabase
  .from('clients')
  .select('id, canonical_name, display_name')
  .order('canonical_name');

// Map to interface-compatible format
const enrichedClients = (clients || []).map(client => ({
  id: client.id,
  client_name: client.display_name || client.canonical_name,
  // ... other fields
}));
```

### Fix 3: React Purity Rules for Date.now()

React's strict purity rules flag `Date.now()` as impure even inside `useMemo`. Solution: use `useState` with lazy initialiser:

```typescript
// BAD - flagged by React purity rules
const isRecent = useMemo(() => {
  return Date.now() - updatedDate.getTime() < 24 * 60 * 60 * 1000;
}, [updatedDate]);

// GOOD - lazy initialiser runs only once
const [isRecent] = useState(() => {
  return Date.now() - updatedDate.getTime() < 24 * 60 * 60 * 1000;
});
```

## Files Modified

| File | Changes |
|------|---------|
| `/planning/page.tsx` | Module-level supabase, useState for Date.now() |
| `/planning/territory/new/page.tsx` | Module-level supabase, correct column names |
| `/planning/territory/[id]/page.tsx` | Module-level supabase |
| `/planning/account/new/page.tsx` | Module-level supabase, correct column names |
| `/planning/account/[id]/page.tsx` | Module-level supabase |

## Prevention

1. **Always check `docs/database-schema.md`** before writing queries
2. **Run `npm run validate-schema`** to catch column mismatches
3. **Create Supabase client at module level** - never inside components
4. **Use empty dependency arrays** for one-time data fetching effects
5. **Use `useState` with lazy initialisers** for time-based calculations

## Verification

After applying fixes:
- Planning Hub loads successfully
- Territory Strategy wizard displays client data
- No console errors
- No infinite re-renders
- ESLint and TypeScript checks pass

## Related Documentation

- `docs/DATABASE_STANDARDS.md` - Column naming conventions
- `docs/database-schema.md` - Complete schema reference
