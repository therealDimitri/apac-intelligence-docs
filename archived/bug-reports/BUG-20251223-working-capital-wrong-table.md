# Bug Report: Working Capital Using Wrong Table and Unidirectional Alias Lookup

**Date:** 2025-12-23
**Severity:** High
**Status:** ✅ RESOLVED
**Component:** Database / Materialized View / client_health_summary

## Summary

Health scores show "No aging data (full points)" for clients that have significant aging data. The Working Capital component was giving default 10/10 points instead of calculating from actual data.

## Affected Clients

| Client | Has Aging Data | Working Capital Shown | Correct Value |
|--------|---------------|----------------------|---------------|
| Saint Luke's Medical Centre (SLMC) | Yes ($143,716) | NULL (default 100%) | ~96% |
| Te Whatu Ora Waikato | No | NULL (default 100%) | Correct (no data) |
| Gippsland Health Alliance | Yes ($480) | NULL (default 100%) | 100% |
| Epworth Healthcare | Yes ($54,692) | NULL (default 100%) | 100% |
| + 10 other clients | Yes | NULL | Various |

## Root Causes

### 1. Wrong Table Reference

The `client_health_summary` materialized view referenced a non-existent table:

```sql
-- BEFORE (wrong)
FROM aged_accounts_receivable aar
WHERE aar.client_name = c.client_name

-- AFTER (correct)
FROM aging_accounts aa
WHERE aa.client_name = c.client_name
```

### 2. Wrong Column Names

The view assumed an `over_90_days` column existed:

```sql
-- BEFORE (column doesn't exist)
COALESCE(SUM(over_90_days), 0)

-- AFTER (calculate from actual columns)
COALESCE(SUM(
  days_91_to_120 + days_121_to_180 + days_181_to_270 +
  days_271_to_365 + days_over_365
), 0)
```

### 3. Unidirectional Alias Lookup

The view only searched aliases in one direction:

```sql
-- BEFORE (only canonical → display)
WHERE canonical_name = c.client_name

-- AFTER (bidirectional)
WHERE canonical_name = c.client_name
   OR display_name = c.client_name
```

This failed for St Lukes because:
- `nps_clients.client_name`: "Saint Luke's Medical Centre (SLMC)"
- `aging_accounts.client_name`: "St Luke's Medical Center Global City Inc"
- `client_name_aliases.canonical_name`: "St Luke's Medical Center Global City Inc"
- `client_name_aliases.display_name`: "Saint Luke's Medical Centre (SLMC)"

The view searched for `canonical_name = 'Saint Luke's Medical Centre (SLMC)'` which returned no matches.

## Resolution

### SQL Migration

File: `docs/migrations/20251223_fix_working_capital_source.sql`

Execute in Supabase Dashboard > SQL Editor.

Key changes:
1. Uses correct table: `aging_accounts`
2. Calculates over_90_days from individual day columns
3. Bidirectional alias lookup for ALL lateral joins
4. Filters inactive accounts with `aa.is_inactive = false`

### Actual Results After Fix (Verified 2025-12-23)

| Client | Working Capital % | Total Outstanding | Health Score |
|--------|-------------------|-------------------|--------------|
| Saint Luke's Medical Centre (SLMC) | 96% | $143,716.20 | 55 ✅ |
| Te Whatu Ora Waikato | NULL (no data) | NULL | 100 ✅ |
| Epworth Healthcare | NULL | NULL | 45 |
| SingHealth | 74% | $219,099.11 | 44 ✅ |
| Royal Victorian Eye and Ear Hospital | 100% | $17,590.34 | 88 ✅ |
| Western Health | 100% | $27,644.77 | 54 ✅ |

**Note:** St Lukes health score dropped from 80 to 55 because:
- Previously: 10/10 Working Capital points (default, no data matched)
- After fix: 9.6/10 Working Capital points (actual calculation)
- NPS contribution is 0 (no NPS data for this client)

### Verification Query

```sql
SELECT
  client_name,
  nps_score,
  nps_period,
  working_capital_percentage,
  total_outstanding,
  health_score
FROM client_health_summary
WHERE client_name ILIKE '%luke%'
   OR client_name ILIKE '%waikato%'
   OR client_name ILIKE '%epworth%';
```

## Architectural Recommendation

This bug is a symptom of a larger architectural issue: client names are scattered across tables with inconsistent naming conventions, requiring complex alias lookups.

See: `docs/architecture/CLIENT-NAME-NORMALISATION-PROPOSAL.md`

Recommended permanent fix:
1. Add `client_id` foreign key to all data tables
2. Reference clients by ID, not name
3. Eliminate alias lookups from materialized views

## Related Bug Reports

- `BUG-20251223-health-score-nps-reconciliation.md` - NPS using all-time instead of latest quarter

## Files Created

- `docs/migrations/20251223_fix_working_capital_source.sql` - Migration SQL
- `scripts/fix-working-capital-table.mjs` - Node.js migration script
- `docs/architecture/CLIENT-NAME-NORMALISATION-PROPOSAL.md` - Permanent fix proposal

## Additional Fix: Working Capital Cap (2025-12-23)

A follow-up issue was discovered where negative aging values (credits/adjustments) caused working_capital_percentage to exceed 100%.

**Example:** GHA had `days_91_to_120 = -$23,106.36` (credit), causing:
- Raw calculation: 4904%
- Health score: 580 (should be 100)

**Fix:** Added `LEAST(100, GREATEST(0, ...))` to cap working capital between 0-100%.

**Script:** `scripts/fix-working-capital-cap.mjs`

## Prevention

1. **Schema documentation** - Document which tables exist and their column names
2. **Foreign key constraints** - Use client_id references instead of name matching
3. **Bidirectional alias lookups** - Always search aliases in both directions
4. **Integration tests** - Test that all clients with data show correct values
5. **Value bounds checking** - Always cap percentage values between 0-100%
