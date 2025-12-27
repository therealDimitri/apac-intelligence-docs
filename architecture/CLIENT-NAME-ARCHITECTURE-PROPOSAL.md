# Client Name Architecture Proposal

**Date**: 2025-12-27
**Status**: Proposal
**Priority**: High

---

## Executive Summary

The current client naming system has significant issues causing data mismatches across the platform. This document proposes a unified client master table with proper foreign key relationships to eliminate naming inconsistencies permanently.

---

## Current State Analysis

### Problem Statement

Client names are stored inconsistently across **11 tables** with **101 unique name variations** representing approximately **25-30 actual clients**. This causes:

1. **Data Silos**: Same client appears differently in different tables
2. **Join Failures**: Queries fail to match related records
3. **Duplicate Alias Tables**: Two overlapping alias systems (`client_aliases`, `client_name_aliases`)
4. **Partial Foreign Keys**: Only 13-60% of records have `client_id` populated

### Tables with Client References

| Table | Column | Has client_id | Population % |
|-------|--------|---------------|--------------|
| `nps_responses` | `client_name` | ✅ | 100% |
| `client_segmentation` | `client_name` | ✅ | 0% |
| `unified_meetings` | `client_name` | ✅ | 13% |
| `actions` | `client` | ✅ | 61% |
| `aging_accounts` | `client_name` + `client_name_normalized` | ✅ | 60% |
| `portfolio_initiatives` | `client_name` | ❌ | N/A |
| `client_health_history` | `client_name` | ❌ | N/A |
| `health_status_alerts` | `client_name` | ❌ | N/A |
| `chasen_folders` | `client_name` | ❌ | N/A |
| `chasen_conversations` | `client_name` | ❌ | N/A |
| `nps_clients` | `client_name` | ❌ | N/A (is the "master" but empty!) |

### Key Issues Found

#### 1. Naming Inconsistencies
```
"Epworth HealthCare" vs "Epworth Healthcare" (case difference)
"MINDEF" vs "MinDef" (case difference)
"Gippsland Health Alliance" vs "Gippsland Health Alliance (GHA)" (suffix)
"WA Health" vs "Western Australia Department Of Health" (abbreviation)
```

#### 2. Orphaned References
- 16 client names in `nps_responses` have no matching `nps_clients` entry
- 18 client names in `client_segmentation` have no matching `nps_clients` entry
- `nps_clients` table is **empty** (0 rows!) despite being referenced as a "master"

#### 3. Multiple Alias Systems
- `client_aliases`: 0 entries (abandoned)
- `client_name_aliases`: 49 entries (actively used but incomplete)

#### 4. Query Patterns (80+ locations)
```typescript
// Pattern 1: Direct string match (brittle)
.eq('client_name', clientName)

// Pattern 2: Alias resolution before query (better but inconsistent)
const resolved = resolveClientName(displayName)
.eq('client_name', resolved)

// Pattern 3: client_id match (best but rarely used)
.eq('client_id', clientId)
```

---

## Proposed Architecture

### Design Principles

1. **Single Source of Truth**: One master `clients` table with unique IDs
2. **Foreign Keys Everywhere**: All tables reference `clients.id`
3. **Aliases as Lookup Only**: Alias table for import/display mapping, not storage
4. **Parent-Child Support**: Built-in hierarchy for client groups (e.g., SingHealth entities)
5. **Backward Compatible**: Keep `client_name` columns but deprecate for queries

### New Schema

#### 1. Master Clients Table

```sql
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Canonical name (the "official" name used everywhere)
    canonical_name TEXT NOT NULL UNIQUE,

    -- Short display name for UI (e.g., "SingHealth" instead of full legal name)
    display_name TEXT NOT NULL,

    -- Parent client for hierarchies (SingHealth → multiple hospitals)
    parent_id UUID REFERENCES clients(id),

    -- Client metadata
    segment TEXT,  -- Sleeping Giant, Steady State, etc.
    tier TEXT,     -- T1, T2, T3
    country TEXT,
    region TEXT,   -- APAC sub-region

    -- Assigned CSE
    cse_id UUID REFERENCES cse_profiles(id),
    cse_name TEXT, -- Denormalized for convenience

    -- Status
    is_active BOOLEAN DEFAULT true,

    -- Audit
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),

    -- Search optimization
    search_vector tsvector GENERATED ALWAYS AS (
        to_tsvector('english', canonical_name || ' ' || display_name)
    ) STORED
);

CREATE INDEX idx_clients_canonical ON clients(canonical_name);
CREATE INDEX idx_clients_display ON clients(display_name);
CREATE INDEX idx_clients_parent ON clients(parent_id);
CREATE INDEX idx_clients_segment ON clients(segment);
CREATE INDEX idx_clients_search ON clients USING gin(search_vector);
```

#### 2. Client Aliases Table (Unified)

```sql
CREATE TABLE client_aliases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- The client this alias maps to
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,

    -- The alias string (e.g., "SingHealth", "Singapore Health Services Pte Ltd")
    alias TEXT NOT NULL,

    -- Alias type for categorization
    alias_type TEXT DEFAULT 'display' CHECK (alias_type IN (
        'display',      -- UI display variation
        'legal',        -- Legal/contract name
        'abbreviation', -- Short form (GHA, RVEEH)
        'historical',   -- Previous name
        'import'        -- Used during data import matching
    )),

    -- Is this the primary display alias?
    is_primary BOOLEAN DEFAULT false,

    -- Source of this alias
    source TEXT, -- 'manual', 'nps_import', 'invoice_import', etc.

    created_at TIMESTAMPTZ DEFAULT now(),

    UNIQUE(alias)  -- Each alias string must be unique across all clients
);

CREATE INDEX idx_client_aliases_alias ON client_aliases(alias);
CREATE INDEX idx_client_aliases_client ON client_aliases(client_id);
```

#### 3. Migration of Existing Tables

For each table with client references, add a proper foreign key:

```sql
-- Example: unified_meetings
ALTER TABLE unified_meetings
    ADD COLUMN client_id_new UUID REFERENCES clients(id);

-- Example: actions (note: column is 'client', not 'client_name')
ALTER TABLE actions
    ADD COLUMN client_id_new UUID REFERENCES clients(id);

-- After backfill, rename and drop old columns
ALTER TABLE unified_meetings DROP COLUMN client_name;
ALTER TABLE unified_meetings RENAME COLUMN client_id_new TO client_id;
```

### Client Resolution Function

```sql
CREATE OR REPLACE FUNCTION resolve_client(input_name TEXT)
RETURNS UUID AS $$
DECLARE
    resolved_id UUID;
BEGIN
    -- 1. Try exact match on canonical_name
    SELECT id INTO resolved_id
    FROM clients
    WHERE canonical_name = input_name;

    IF resolved_id IS NOT NULL THEN
        RETURN resolved_id;
    END IF;

    -- 2. Try exact match on display_name
    SELECT id INTO resolved_id
    FROM clients
    WHERE display_name = input_name;

    IF resolved_id IS NOT NULL THEN
        RETURN resolved_id;
    END IF;

    -- 3. Try alias lookup
    SELECT client_id INTO resolved_id
    FROM client_aliases
    WHERE alias = input_name;

    IF resolved_id IS NOT NULL THEN
        RETURN resolved_id;
    END IF;

    -- 4. Try case-insensitive alias match
    SELECT client_id INTO resolved_id
    FROM client_aliases
    WHERE LOWER(alias) = LOWER(input_name);

    RETURN resolved_id; -- May be NULL if no match
END;
$$ LANGUAGE plpgsql;
```

### API Changes

#### New Hook: `useClient()`

```typescript
interface Client {
  id: string
  canonicalName: string
  displayName: string
  parentId: string | null
  segment: string | null
  tier: string | null
  cseName: string | null
  isActive: boolean
  children?: Client[] // Populated for parent clients
  aliases?: string[]  // All known aliases
}

function useClient(identifier: string): {
  client: Client | null
  loading: boolean
  error: Error | null
}

// Usage - works with ANY alias or ID
const { client } = useClient('SingHealth')
const { client } = useClient('Singapore Health Services Pte Ltd')
const { client } = useClient('abc-123-uuid')
```

#### Resolution API

```typescript
// POST /api/clients/resolve
// Body: { names: ['SingHealth', 'WA Health', 'Unknown Corp'] }
// Response: {
//   resolved: {
//     'SingHealth': { id: '...', canonicalName: '...', confidence: 1.0 },
//     'WA Health': { id: '...', canonicalName: '...', confidence: 1.0 }
//   },
//   unresolved: ['Unknown Corp']
// }
```

---

## Migration Strategy

### Phase 1: Create New Tables (Week 1)

1. Create `clients` table
2. Create unified `client_aliases` table
3. Populate from existing data:
   - Extract unique clients from `client_segmentation`
   - Import aliases from `client_name_aliases`
   - Add parent-child relationships for known hierarchies

### Phase 2: Backfill Foreign Keys (Week 2)

1. For each table with `client_name`:
   - Add `client_id` column (nullable)
   - Run backfill script using `resolve_client()` function
   - Log unresolved names for manual review

### Phase 3: Update Application Code (Week 3-4)

1. Update all Supabase queries to use `client_id` instead of `client_name`
2. Update hooks to work with client IDs
3. Add client resolution to import flows (NPS, Outlook, Invoice Tracker)

### Phase 4: Enforce Constraints (Week 5)

1. Make `client_id` columns NOT NULL (after confirming 100% backfill)
2. Add foreign key constraints
3. Deprecate direct `client_name` usage in queries
4. Remove old `client_aliases` table (if exists)

### Phase 5: Cleanup (Week 6)

1. Drop redundant `client_name` columns (optional, can keep for display)
2. Drop old `client_name_aliases` table
3. Update documentation

---

## Known Client Hierarchies

Based on the audit, these clients need parent-child relationships:

### SingHealth Group
```
Singapore Health Services Pte Ltd (parent)
├── Changi General Hospital
├── Sengkang General Hospital Pte. Ltd.
├── Singapore General Hospital Pte Ltd
├── KK Women's and Children's Hospital
├── National Cancer Centre Of Singapore Pte Ltd
└── National Heart Centre Of Singapore Pte Ltd
```

### SA Health Group
```
SA Health (parent)
├── SA Health (iPro)
├── SA Health (iQemo)
└── SA Health (Sunrise)
```

### Ministry of Defence Singapore
```
Ministry of Defence, Singapore (parent)
└── NCS PTE Ltd
```

---

## Benefits

1. **Zero Ambiguity**: Every client has one ID, queries always match
2. **Easy Renaming**: Update `canonical_name` in one place, all references follow
3. **Import Resilience**: New aliases auto-resolve during import
4. **Hierarchy Support**: Parent-child rollups for reporting
5. **Performance**: UUID foreign keys faster than string comparisons
6. **Auditability**: Clear lineage of which alias resolved to which client

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Backfill misses edge cases | Manual review queue for unresolved names |
| Breaks existing reports | Keep `client_name` columns as denormalized display values |
| Import flows break | Add client resolution step before insert |
| Performance during migration | Run backfills during off-peak hours |

---

## Success Metrics

- [ ] 100% of records have valid `client_id` foreign keys
- [ ] Zero "client not found" errors in production logs
- [ ] All queries use `client_id` for joins (no string matching)
- [ ] Single alias table with complete coverage
- [ ] Parent-child relationships correctly modelled

---

## Appendix: Full Client Inventory

See audit output for complete list of 101 unique client name variations that need to be consolidated into ~25-30 canonical clients.

---

## Next Steps

1. **Review & Approve**: Team review of this proposal
2. **Refine Hierarchy**: Confirm parent-child relationships with business
3. **Create Migration Scripts**: SQL scripts for each phase
4. **Test Environment**: Run full migration on staging first
5. **Rollout Plan**: Schedule production migration with rollback plan
