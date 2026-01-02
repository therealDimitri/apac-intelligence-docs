# Bug Report: NPS Alias Case Sensitivity and V1 Redirect

**Date:** 2026-01-02
**Status:** Fixed
**Severity:** Medium
**Component:** NPS Analysis, Client Profile Routing

## Issues Fixed

### 1. WA Health NPS Data Not Displaying

**Problem:** WA Health client profile showed no NPS data despite NPS responses existing in the database.

**Root Cause:** Case-sensitive mismatch in client name aliases:
- Database NPS records: `"Western Australia Department Of Health"` (capital 'Of')
- Alias table entry: `"Western Australia Department of Health"` (lowercase 'of')

The alias lookup was using `ilike` for case-insensitive matching, but the actual data retrieval was case-sensitive.

**Fix:** Added correct case alias to `client_name_aliases` table:
```sql
INSERT INTO client_name_aliases (display_name, canonical_name, is_active)
VALUES ('Western Australia Department Of Health', 'WA Health', true);
```

### 2. useNPSAnalysis Using Wrong Table Name

**Problem:** The `getAllClientNames` function in `useNPSAnalysis.ts` was referencing a non-existent `client_aliases` table.

**Root Cause:** Table was renamed to `client_name_aliases` during a previous cleanup, but this hook wasn't updated.

**Fix:** Updated `useNPSAnalysis.ts` to use correct table:
```typescript
// BEFORE
const { data: aliasMatches } = await supabase
  .from('client_aliases')  // ❌ Wrong table name
  .select('display_name, canonical_name')

// AFTER
const { data: aliasMatches } = await supabase
  .from('client_name_aliases')  // ✅ Correct table name
  .select('display_name, canonical_name')
  .or(`display_name.ilike.${clientName},canonical_name.ilike.${clientName}`)
  .eq('is_active', true)
```

### 3. V1 Client Profile Deprecated

**Problem:** V1 client profile page was still accessible, creating confusion about which view to use.

**Solution:** Simplified V1 page to automatically redirect to V2:
```typescript
export default function ClientProfilePage() {
  const params = useParams()
  const router = useRouter()
  const clientId = params.clientId as string

  useEffect(() => {
    router.replace(`/clients/${encodeURIComponent(clientId)}/v2`)
  }, [clientId, router])

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center">
      <div className="text-center">
        <div className="inline-flex items-center justify-center h-12 w-12 rounded-md bg-purple-100 mb-4">
          <div className="h-6 w-6 bg-purple-600 rounded-full animate-spin"></div>
        </div>
        <p className="text-gray-700 font-medium">Redirecting to client profile...</p>
      </div>
    </div>
  )
}
```

This removed ~250 lines of deprecated V1 code.

## Files Modified

1. **Database: `client_name_aliases` table**
   - Added: `"Western Australia Department Of Health"` → `"WA Health"`

2. **`src/hooks/useNPSAnalysis.ts`**
   - Fixed table reference from `client_aliases` to `client_name_aliases`
   - Simplified alias lookup logic

3. **`src/app/(dashboard)/clients/[clientId]/page.tsx`**
   - Replaced full V1 implementation with redirect to V2
   - Reduced from ~280 lines to ~30 lines

## Testing Verification

1. **WA Health NPS**: Now displays NPS score correctly
2. **V1 URL**: Automatically redirects to V2 view
3. **TypeScript compilation**: Passes

## Prevention

- Always verify exact case matching when dealing with client names
- Run `npm run validate-schema` to catch table name mismatches
- Consider consolidating all client name matching to use a single utility function
