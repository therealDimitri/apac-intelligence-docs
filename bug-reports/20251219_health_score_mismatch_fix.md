# Bug Report: Health Score Mismatch Between Database and UI

**Date:** 2025-12-19
**Status:** Fixed
**Severity:** High
**Affected Clients:** All clients (especially Te Whatu Ora Waikato, SingHealth, Royal Victorian Eye and Ear Hospital)

## Problem Description

Health scores displayed on client profiles did not match the calculated breakdown shown in the Health Score modal. For example:
- Te Whatu Ora Waikato: Main card showed 71, modal breakdown totalled 96
- SingHealth: Database showed 46, but with correct compliance data should be 69
- Royal Victorian Eye and Ear Hospital: Database showed 55, should be 73

### Symptoms

1. Health score on client profile card differed from sum of components in modal
2. Compliance percentage showed incorrect values (100% when no data existed)
3. Many clients showed 50% compliance default even when they had compliance data

## Root Cause

Three interconnected issues:

### Issue 1: Client Name Mismatch Between Tables

Different tables used different names for the same client:
- `nps_clients`: "Te Whatu Ora Waikato", "SingHealth", etc.
- `segmentation_event_compliance`: "Waikato", "Singapore Health (SingHealth)", etc.

The materialized view joined on exact `client_name` match, missing compliance data stored under variant names.

### Issue 2: Alias Table Lookup Direction

The `client_name_aliases` table existed with correct mappings, but the SQL only looked for aliases where `canonical_name = nps_clients.client_name`. Many nps_clients names existed as `display_name` values, not `canonical_name` values.

Example:
- "SingHealth" exists in aliases as display_name → canonical_name "Singapore Health Services Pte Ltd"
- "Singapore Health (SingHealth)" also exists as display_name → same canonical_name
- The original SQL couldn't find this relationship

### Issue 3: Inconsistent Default Values

The `compliance_percentage` column showed raw NULL or 100% values, while the health score formula used a 50% default. This caused UI mismatch.

### Issue 4: NPS Calculation Period Mismatch (Second Fix - 19 Dec)

After the initial fix, scores still didn't match because:
- **Database**: Calculated NPS from ALL-TIME responses
- **UI**: Calculated NPS from MOST RECENT QUARTER only (via `useNPSTrend` hook)

Example for SingHealth:
- All-time NPS: -25 (from all historical responses)
- Most recent quarter NPS: 0 (no responses in Q4 2025)
- This caused database score of 69 vs UI calculation of 74

## Fix Applied

### 1. Database Migration (`docs/migrations/20251219_fix_health_score_with_aliases.sql`)

Updated the materialized view with:

#### Bidirectional Alias Lookup for Compliance
```sql
-- Match via aliases where c.client_name IS the canonical_name
ec.client_name IN (
  SELECT display_name FROM client_name_aliases
  WHERE canonical_name = c.client_name AND is_active = true
)
OR
-- Match via aliases where c.client_name IS a display_name
-- Find all OTHER display_names that share the same canonical_name
ec.client_name IN (
  SELECT a2.display_name
  FROM client_name_aliases a1
  JOIN client_name_aliases a2 ON a1.canonical_name = a2.canonical_name
  WHERE a1.display_name = c.client_name
    AND a1.is_active = true
    AND a2.is_active = true
)
```

#### Consistent Default Values
```sql
-- compliance_percentage column now uses same default as health_score formula
LEAST(100, COALESCE(compliance_metrics.compliance_percentage, 50)) as compliance_percentage,
```

#### NPS Calculation from Most Recent Quarter Only
```sql
-- Filter to MOST RECENT QUARTER only (matches UI useNPSTrend calculation)
AND r.response_date >= (
  -- Find the start of the most recent quarter that has data
  SELECT DATE_TRUNC('quarter', MAX(r2.response_date))
  FROM nps_responses r2
  WHERE r2.client_name = c.client_name
    OR r2.client_name IN (
      SELECT display_name FROM client_name_aliases
      WHERE canonical_name = c.client_name AND is_active = true
    )
    -- SA Health aggregation
    OR (c.client_name LIKE 'SA Health%' AND r2.client_name LIKE 'SA Health%')
)
```

This ensures the database calculates NPS from only the most recent quarter that has responses, matching the UI calculation in `useNPSTrend`.

### 2. Added Missing Self-Reference Aliases

Added aliases to `client_name_aliases` table for clients that didn't have entries:
- "Western Health" → "Western Health"
- "Gippsland Health Alliance (GHA)" → "Gippsland Health Alliance (GHA)"

## Results After Fix

### Final Results (After NPS Quarterly Fix)

| Client | Original | Final | NPS (Recent Qtr) | Compliance | WC |
|--------|----------|-------|------------------|------------|-----|
| Te Whatu Ora Waikato | 71 | **64** | 0 | 67.7% | 100% |
| SingHealth | 46 | **74** | 0 | 95.1% | 61% |
| Royal Victorian Eye and Ear Hospital | 55 | **73** | 0 | 86.1% | 100% |
| SA Health variants | 46-55 | **44** | -55 | 50% (no data) | 100% |
| Gippsland Health Alliance (GHA) | - | **100** | 100 | 100% | 100% |
| Epworth Healthcare | - | **60** | -100 | 100% | 100% |

All 18 clients now have health scores that **exactly match** their calculated component breakdown in the UI modal.

## Files Modified

- `docs/migrations/20251219_fix_health_score_with_aliases.sql` (updated from aging fix migration)
- `client_name_aliases` table (added 2 entries)

## Technical Details

### How Alias Lookup Works Now

1. **Direct match**: `ec.client_name = c.client_name`
2. **Canonical lookup**: If nps_clients.client_name IS a canonical_name, find all display_names for it
3. **Peer lookup**: If nps_clients.client_name IS a display_name, find the canonical_name, then find ALL OTHER display_names with the same canonical_name

This ensures that regardless of how the client name appears in nps_clients vs compliance tables, the correct data is matched.

### Health Score Formula (v3.1 - with Quarterly NPS)

```
Health Score = NPS (40 pts) + Compliance (50 pts) + Working Capital (10 pts)

NPS Component:      ((nps_score + 100) / 200) * 40
                    ⚠️ NPS calculated from MOST RECENT QUARTER only
Compliance:         (min(100, compliance_%) / 100) * 50
Working Capital:    (min(100, wc_%) / 100) * 10

Defaults:
- NPS: 0 (neutral) - also when no recent quarter data
- Compliance: 50% (if no data)
- Working Capital: 100% (no aging data = no problem)
```

**Important**: NPS is calculated from the most recent quarter that has responses, not from all-time historical data. This matches the UI calculation in `useNPSTrend` hook.

## Testing Checklist

- [x] All 18 clients have matching calculated vs stored health scores
- [x] Te Whatu Ora Waikato shows correct compliance from "Waikato" data
- [x] SingHealth shows correct compliance from "Singapore Health (SingHealth)" data
- [x] RVEEH shows correct compliance from "Royal Victorian Eye and Ear Hospital (RVEEH)" data
- [x] SA Health variants correctly default to 50% (no matching compliance data)
- [x] UI breakdown modal totals match database health_score field

## Prevention

1. When adding new clients to `nps_clients`, ensure corresponding entries exist in `client_name_aliases`
2. When adding compliance data, use names that match existing aliases or add new alias entries
3. Refer to `src/lib/client-name-mapper.ts` for canonical display name mappings
4. The bidirectional alias lookup handles most variations automatically

## Related Issues

- Previous fix: `20251219_working_capital_aggregation_fix.md` - Fixed Working Capital display for multi-entity clients
- Follow-up fix: `20251219_compliance_mismatch_fix.md` - Fixed compliance data source to use event_compliance_summary (same day)
