# Bug Report: BURC ARR by Client Showing FY2025 Data Due to RLS Policy

**Date:** 3 February 2026
**Status:** Fixed
**Severity:** High
**Affected Components:** BURC Executive Dashboard, burc_revenue_detail table

## Summary

The ARR by Client breakdown on the BURC Executive Dashboard was showing FY2025 data (from `burc_historical_revenue_detail`) instead of FY2026 data (from `burc_revenue_detail`) due to a missing Row Level Security (RLS) policy for anonymous access.

## Symptoms

- ARR by Client list showed incorrect entries:
  - "(blank)" - $188.5K
  - "dbM to APAC Profit Share" - $150.0K
  - "MS to APAC Profit Share" - $70.2K
  - "Parkway Hospitals" - $674.3K
- These were FY2025 values from `burc_historical_revenue_detail`
- FY2026 data existed in `burc_revenue_detail` (92 rows) but wasn't accessible

## Root Cause

The `burc_revenue_detail` table had RLS enabled with only an `authenticated` policy:

```sql
-- Existing policy (insufficient)
CREATE POLICY "Allow authenticated read" ON burc_revenue_detail
FOR SELECT TO authenticated USING (true);
```

The dashboard's Supabase client uses the **anon key** (not authenticated), so queries returned 0 rows, triggering the fallback to FY2025 data.

## Resolution

Added an `anon` RLS policy to allow browser access:

```sql
CREATE POLICY "Allow anon read access" ON burc_revenue_detail
FOR SELECT TO anon USING (true);
```

## Verification

After adding the policy:

**Before (FY2025 fallback):**
- Minister for Health: $8.8M
- Singapore Health Services: $7.5M
- Parkway Hospitals: $674.3K

**After (correct FY2026 data):**
- SA Health: $6.6M
- Sing Health: $4.7M
- St Luke's Medical Centre: $1.4M
- Grampians Health: $1.0M
- (14 clients with positive net ARR)

## Additional Fixes Applied

1. **Deploy restore**: A manual Netlify deploy had overwritten the code fix - restored to commit `26f6294e`
2. **ARR formula**: Implemented `Backlog + Best Case + Bus Case - Lost` calculation
3. **Aggregate filtering**: Excluded entries like "APAC Total", "Baseline", "Hosting to APAC Profit Share"

## Lessons Learned

1. **Always check RLS policies when browser queries return empty**: Service role key works but anon key fails = RLS issue
2. **Test with anon key locally**: Use `NEXT_PUBLIC_SUPABASE_ANON_KEY` to simulate browser behaviour
3. **Monitor deploy history**: Manual deploys can overwrite git-triggered deploys

## Debugging Commands

```javascript
// Test with anon key (simulates browser)
const supabase = createClient(url, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY);
const { data } = await supabase.from('burc_revenue_detail').select('*').limit(1);
// If data is empty but service key returns data = RLS issue
```

```sql
-- Check RLS policies on a table
SELECT policyname, cmd, roles FROM pg_policies WHERE tablename = 'burc_revenue_detail';
```
