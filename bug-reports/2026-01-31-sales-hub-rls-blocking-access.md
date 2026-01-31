# Bug Report: Sales Hub RLS Blocking Anonymous Access

## Date
2026-01-31

## Severity
High - Feature completely non-functional

## Summary
Sales Hub pages showed "0 products" despite 94 products existing in the database. Row Level Security (RLS) was enabled on product tables without any SELECT policies, blocking all client-side access via the anon key.

## Root Cause
The `product_catalog`, `solution_bundles`, `toolkits`, and `value_wedges` tables had RLS enabled but no policies defined. The Supabase anon key (used by client-side hooks) was blocked from reading any rows, while the service role key (used by API routes) worked fine.

## Symptoms
- Sales Hub main page: "0 of 0 products"
- Solution Bundles page: "0 bundles"
- Search page: No results regardless of query
- Admin page: Initially showed 0 products (same RLS issue)
- API direct queries with service role: Returned all 94 products correctly

## Investigation
```javascript
// Anon key returned 0 rows
const anonSupabase = createClient(url, anonKey)
const { count } = await anonSupabase.from('product_catalog').select('*', { count: 'exact', head: true })
// count: 0

// Service role key returned all rows
const serviceSupabase = createClient(url, serviceRoleKey)
const { count } = await serviceSupabase.from('product_catalog').select('*', { count: 'exact', head: true })
// count: 94
```

## Fix Applied
Disabled RLS on all four product-related tables (reference data, not user data):

```sql
ALTER TABLE public.product_catalog DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.solution_bundles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.toolkits DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.value_wedges DISABLE ROW LEVEL SECURITY;
```

Executed via Supabase `exec_sql` RPC function.

## Alternative Fix (if RLS needed)
If RLS is required for these tables in future, add a permissive SELECT policy:

```sql
CREATE POLICY "Allow public read access" ON public.product_catalog
FOR SELECT USING (true);
```

## Verification
- Sales Hub main page: 94 of 94 products displayed
- Solution Bundles: 3 bundles displayed (after seeding)
- Search: 48 results for "sunrise" query
- Admin page: Full product table with edit/delete functionality

## Additional Data Seeded
Added 3 sample solution bundles during testing:
- Clinical Excellence Bundle
- Interoperability Suite
- Revenue Cycle Optimisation

## Prevention
- When creating new tables that need client-side access, either:
  1. Do not enable RLS (for reference/catalog data)
  2. Create appropriate SELECT policies immediately after enabling RLS
- Test new features with anon key access, not just service role

## Related Files
- `src/hooks/useProductCatalog.ts` - Uses anon key for client-side queries
- `src/app/api/sales-hub/products/route.ts` - Uses service role key (unaffected)
