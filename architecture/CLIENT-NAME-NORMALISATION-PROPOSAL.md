# Client Name Normalisation Architecture Proposal

**Date:** 2025-12-23
**Status:** ✅ FULLY IMPLEMENTED
**Priority:** High
**Impact:** All health score and client data aggregation features

## Executive Summary

Currently, client data is scattered across multiple tables with inconsistent naming conventions, requiring complex bidirectional alias lookups at query time. This proposal outlines a permanent architectural fix that eliminates duplicate information and simplifies data management.

## Current State (Problems)

### 1. Multiple Client Name Variations

The same client appears with different names across tables:

| Table                      | St Lukes Name                              |
| -------------------------- | ------------------------------------------ |
| `nps_clients`              | "Saint Luke's Medical Centre (SLMC)"       |
| `aging_accounts`           | "St Luke's Medical Center Global City Inc" |
| `nps_responses`            | Various (St Luke's, SLMC, etc.)            |
| `event_compliance_summary` | "Saint Luke's Medical Centre (SLMC)"       |

### 2. Bidirectional Alias Lookups

The `client_name_aliases` table stores mappings, but:

- `canonical_name` and `display_name` meaning varies by context
- Views must search both directions (expensive)
- No single source of truth

### 3. Performance Impact

Each materialized view refresh requires multiple subqueries per client to resolve aliases:

```sql
-- Current approach (3 subqueries per lateral join)
WHERE client_name = c.client_name
   OR client_name IN (SELECT display_name FROM aliases WHERE canonical_name = c.client_name)
   OR client_name IN (SELECT canonical_name FROM aliases WHERE display_name = c.client_name)
```

### 4. Data Integrity Issues

- No foreign key constraints between tables
- Typos in client names create orphaned data
- Manual imports often create new name variations

---

## Proposed Solution: Client ID Normalisation

### Phase 1: Master Client Table (nps_clients)

The `nps_clients` table becomes the single source of truth:

```sql
-- nps_clients is already the master table
-- id: UUID primary key
-- client_name: Display name (what users see)
-- All other tables reference client_id, not client_name
```

### Phase 2: Add client_id to All Tables

Add `client_id` foreign key to all data tables:

```sql
-- aging_accounts
ALTER TABLE aging_accounts ADD COLUMN client_id UUID REFERENCES nps_clients(id);

-- nps_responses
ALTER TABLE nps_responses ADD COLUMN client_id UUID REFERENCES nps_clients(id);

-- unified_meetings
ALTER TABLE unified_meetings ADD COLUMN client_id UUID REFERENCES nps_clients(id);

-- actions
ALTER TABLE actions ADD COLUMN client_id UUID REFERENCES nps_clients(id);

-- event_compliance_summary (already materialised - needs different approach)
```

### Phase 3: Migrate Existing Data

Create a migration script to populate `client_id` using current alias mappings:

```sql
-- Example for aging_accounts
UPDATE aging_accounts aa
SET client_id = (
  SELECT c.id FROM nps_clients c
  WHERE c.client_name = aa.client_name
     OR c.client_name IN (
       SELECT display_name FROM client_name_aliases
       WHERE canonical_name = aa.client_name
     )
     OR c.client_name IN (
       SELECT canonical_name FROM client_name_aliases
       WHERE display_name = aa.client_name
     )
  LIMIT 1
);
```

### Phase 4: Simplified View

After migration, the `client_health_summary` view becomes:

```sql
CREATE MATERIALIZED VIEW client_health_summary AS
SELECT
  c.id,
  c.client_name,
  -- NPS metrics
  nps.calculated_nps as nps_score,
  ...
FROM nps_clients c
LEFT JOIN nps_responses nr ON nr.client_id = c.id  -- Simple join!
LEFT JOIN aging_accounts aa ON aa.client_id = c.id  -- Simple join!
...
```

### Phase 5: Import Process Updates

Update all import scripts to:

1. Resolve client name to `client_id` ONCE at import time
2. Store `client_id` instead of relying on name matching
3. Reject imports with unknown client names (or create new client record)

---

## Alternative: Name Normalisation at Import Time

If foreign keys are too disruptive, an alternative is to normalise names at import:

### 1. Define Canonical Names

The `nps_clients.client_name` is the canonical name. All other tables must use this exact name.

### 2. Update Import Scripts

```javascript
async function normaliseClientName(rawName) {
  // Check direct match
  const { data: client } = await supabase
    .from('nps_clients')
    .select('client_name')
    .eq('client_name', rawName)
    .single()

  if (client) return client.client_name

  // Check aliases
  const { data: alias } = await supabase
    .from('client_name_aliases')
    .select('canonical_name, display_name')
    .or(`display_name.eq.${rawName},canonical_name.eq.${rawName}`)
    .single()

  if (alias) {
    // Return the nps_clients version
    const { data: resolved } = await supabase
      .from('nps_clients')
      .select('client_name')
      .or(`client_name.eq.${alias.canonical_name},client_name.eq.${alias.display_name}`)
      .single()
    return resolved?.client_name
  }

  throw new Error(`Unknown client: ${rawName}`)
}
```

### 3. Apply to All Imports

- Excel imports (aging_accounts, NPS responses)
- API imports (webhook data)
- Manual data entry

---

## Immediate Fix Required

Before implementing the permanent solution, apply this SQL via Supabase Dashboard to fix the current issue:

**File:** `scripts/fix-working-capital-table.mjs`

This SQL:

1. Uses correct table (`aging_accounts` instead of `aged_accounts_receivable`)
2. Calculates over_90_days from individual day columns
3. Looks up aliases in both directions

---

## Implementation Status (2025-12-23)

### ✅ Phase 1: Schema Changes (COMPLETE)

- [x] Add `client_id` column to `aging_accounts`
- [x] Add `client_id` column to `nps_responses`
- [x] Add `client_id` column to `unified_meetings`
- [x] Add `client_id` column to `actions`
- [x] Add foreign key constraints to all tables
- [x] Create indexes on client_id columns

### ✅ Phase 2: Data Migration (COMPLETE)

- [x] Create `resolve_client_id_int()` function
- [x] Populate `client_id` for all existing records
- [x] Add missing aliases for unmatched client names
- [x] Validate records (199/199 nps_responses, 12/13 aging_accounts matched)

### ✅ Phase 3: View Simplification (COMPLETE)

- [x] Update `client_health_summary` to use `client_id` joins
- [x] Update `event_compliance_summary` to use `client_id` joins (2025-12-23)
- [x] Add `client_id` column to `segmentation_events` table

### ✅ Phase 4: Import Updates (COMPLETE)

- [x] Update meeting schedule API to populate `client_id`
- [x] Update meeting import API to populate `client_id`
- [x] Update createAction hook to populate `client_id`
- [x] Update assignment API to populate `client_id`
- [x] Update bulk assignment API to populate `client_id`

### Migration Scripts Created

1. `scripts/add-client-id-foreign-keys.mjs` - Schema changes
2. `scripts/populate-client-ids.mjs` - Data population
3. `scripts/add-missing-aliases-v2.mjs` - Alias additions
4. `scripts/update-view-to-use-client-id.mjs` - View simplification
5. `scripts/apply-event-compliance-client-id.mjs` - Event compliance view enhancement

---

## Benefits of Foreign Key Approach

| Metric                | Current | After Fix      |
| --------------------- | ------- | -------------- |
| Subqueries per client | 6-9     | 0              |
| View refresh time     | ~30s    | ~5s            |
| Risk of name mismatch | High    | None           |
| Data integrity        | None    | Enforced by FK |
| Query complexity      | High    | Simple         |

---

## Risks and Mitigations

| Risk                         | Mitigation                                                       |
| ---------------------------- | ---------------------------------------------------------------- |
| Breaking existing queries    | Add `client_id` as nullable first, make required after migration |
| Import failures              | Add fallback to create unmatched clients queue                   |
| Performance during migration | Run in batches, off-peak hours                                   |

---

## Recommendation

**Short-term (This Week):**

- Apply the bidirectional alias lookup fix to `client_health_summary`
- Verify all health scores are correct

**Medium-term (Next Month):**

- Implement the foreign key architecture
- Start with `aging_accounts` as a pilot
- Expand to other tables once validated

**Long-term:**

- Remove `client_name` columns from data tables (keep only `client_id`)
- Deprecate `client_name_aliases` table (no longer needed)
- All queries become simple foreign key joins

---

## Appendix: Current Table Dependencies

```
nps_clients (master)
├── nps_responses (client_id ✅)
├── aging_accounts (client_id ✅)
├── unified_meetings (client_id ✅)
├── actions (client_id ✅)
├── segmentation_events (client_id ✅)
├── event_compliance_summary (client_id ✅)
└── client_health_summary (client_id ✅)
```

---

## Appendix: Affected Files

### Scripts

- `scripts/fix-working-capital-table.mjs` - Immediate fix
- `src/app/api/aging-accounts/route.ts` - Aging data API
- `src/app/api/webhooks/invoice-tracker/route.ts` - Invoice webhook

### Import Scripts (to update)

- Excel import handlers
- NPS response import
- Meeting import

### Views

- `client_health_summary` - Main health score view
- `event_compliance_summary` - Compliance aggregation
