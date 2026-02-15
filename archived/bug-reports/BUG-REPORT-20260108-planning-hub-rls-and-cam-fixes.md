# Bug Report: Planning Hub RLS Policies and CAM Data Fixes

**Date:** 8 January 2026
**Severity:** High
**Status:** Resolved

## Summary

Multiple issues were identified in the Planning Hub:
1. Plan deletions were not persisting after page refresh
2. CAM names in Account Plan were mock/incorrect data
3. CSE Partner selection was hardcoded and incorrect

## Issue 1: Plan Deletions Not Persisting

### Symptoms
- User clicks delete on a plan, confirmation modal appears
- After confirming delete, the plan disappears from the UI
- On page refresh, the deleted plans reappear

### Root Cause
Row Level Security (RLS) policies on `territory_strategies` and `account_plans` tables were not configured to allow DELETE operations for the anonymous key. Supabase silently fails (returns empty result, no error) when RLS blocks an operation.

### Evidence
```javascript
// Test with ANON key (same as frontend)
const { data: anonData, error: anonError } = await anonSupabase
  .from('territory_strategies')
  .delete()
  .eq('id', toDelete.id)
  .select();

// Result before fix:
// Response data: []
// Error: null  <-- No error returned!
// After check: Same number of records (delete didn't work)
```

### Solution
Applied proper RLS policies via direct PostgreSQL connection:

```sql
-- Territory Strategies
ALTER TABLE territory_strategies ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all for territory_strategies" ON territory_strategies;
CREATE POLICY "Allow all for territory_strategies" ON territory_strategies
  FOR ALL USING (true) WITH CHECK (true);

-- Account Plans
ALTER TABLE account_plans ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all for account_plans" ON account_plans;
CREATE POLICY "Allow all for account_plans" ON account_plans
  FOR ALL USING (true) WITH CHECK (true);
```

### Verification
After applying fix:
```
=== Before Delete ===
Before: 5 records

=== After Delete ===
After: 4 records
✅ DELETE WORKED - Record was removed
```

---

## Issue 2: Incorrect CAM Names

### Symptoms
- CAM dropdown showed mock names: "Ryan Patterson", "Simon Fryer"
- These are not real team members

### Root Cause
Placeholder/mock data was used during initial development and never updated with real team data.

### Solution
Updated `CAM_OPTIONS` with real team members from `cse_profiles` table:

**Before:**
```typescript
const CAM_OPTIONS = [
  { name: 'Ryan Patterson', csePartner: 'Tracey Bland' },
  { name: 'Simon Fryer', csePartner: 'John Salisbury' },
  { name: 'Nikki Wei', csePartner: 'Laura Messing' },
]
```

**After:**
```typescript
const CAM_OPTIONS = [
  { name: 'Anupama Pradhan', region: 'ANZ', csePartners: ['Tracey Bland', 'John Salisbury', 'Laura Messing'] },
  { name: 'Nikki Wei', region: 'Asia', csePartners: ['Kenny Gan', 'Nikki Wei'] },
]

const CSE_TERRITORIES: Record<string, string> = {
  'Tracey Bland': 'Victoria, NZ',
  'John Salisbury': 'WA, Western Health, Barwon',
  'Laura Messing': 'SA Health',
  'Kenny Gan': 'Singapore',
  'Nikki Wei': 'Asia (excluding Singapore)',
}
```

---

## Issue 3: CSE Partner Selection

### Symptoms
- CSE Partner was a read-only field that auto-populated based on CAM selection
- Incorrect pairings (e.g., Nikki Wei → Laura Messing)

### Solution
Changed CSE Partner from read-only input to a dropdown that:
1. Only activates after CAM is selected
2. Shows CSE partners available for that CAM's region
3. Displays territory information for each CSE

**New UI Flow:**
1. User selects CAM (e.g., "Anupama Pradhan (ANZ)")
2. CSE Partner dropdown enables with options:
   - Tracey Bland - Victoria, NZ
   - John Salisbury - WA, Western Health, Barwon
   - Laura Messing - SA Health

---

## Files Modified

| File | Changes |
|------|---------|
| `src/app/(dashboard)/planning/account/new/page.tsx` | Updated CAM_OPTIONS with real data, added CSE_TERRITORIES, changed CSE Partner to dropdown |
| Database: `territory_strategies` table | Added RLS policy for all operations |
| Database: `account_plans` table | Added RLS policy for all operations |

## Prevention

1. **Always verify RLS policies** after creating new tables
2. **Test CRUD operations with anon key** before deployment
3. **Use real data from database** for dropdowns, not hardcoded mock data
4. **Add automated tests** for critical operations like delete

---

## Issue 4: Client Dropdown Not Populating

### Symptoms
- Client dropdown in Account Plan showed only "Select client..."
- No clients appeared in the list

### Root Cause
The `clients` table RLS policy only allowed `authenticated` users to SELECT, but the Account Plan page uses the `anon` key.

### Solution
Added RLS policy to allow anonymous read access to clients:

```sql
CREATE POLICY clients_anon_read_policy ON clients
  FOR SELECT
  TO anon
  USING (true);
```

### Verification
After fix, dropdown shows 34 clients including: Albury Wodonga Health, Austin Health, Barwon Health, Changi General Hospital, Epworth Healthcare, GHA, SA Health, SingHealth, WA Health, Western Health, etc.

---

## Related Documentation

- `docs/bug-reports/BUG-REPORT-20260108-planning-hub-infinite-render-fix.md` - Related fixes for same page
