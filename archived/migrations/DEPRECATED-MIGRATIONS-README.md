# ⚠️ DEPRECATED MATERIALIZED VIEW MIGRATIONS

**Date**: 2025-12-03
**Status**: DEPRECATED - DO NOT USE

---

## ✅ Current Canonical Version

**USE THIS ONLY:**
- `20251203_CANONICAL_event_compliance_view.sql` (v3.0.0)

This is the **single source of truth** for the `event_compliance_summary` materialized view.

---

## ❌ Deprecated Migrations (DO NOT USE)

The following migration files are **DEPRECATED** and should not be used. They contain errors and have been superseded by the canonical version:

### 1. `20251202_create_event_compliance_materialized_view.sql`
**Issues:**
- References non-existent `is_mandatory` column
- Uses wrong column name for frequency
- Creates duplicates for clients with segment changes

### 2. `20251202_fix_event_compliance_view_segment_changes.sql`
**Issues:**
- Doesn't fully fix segment change aggregation
- Still has column name mismatches
- Partial fix only

### 3. `20251202_final_fix_single_record_per_client.sql`
**Issues:**
- Claims to be "final" but wasn't
- Still has bugs in GROUP BY logic
- No unique constraint

### 4. `20251202_update_compliance_view_for_tier_requirements.sql`
**Issues:**
- References `required_count` instead of `frequency`
- Incorrect JOIN logic for tier requirements

### 5. `20251203_compliance_view_latest_segment_only.sql`
**Issues:**
- Hardcoded year filters (2025 only)
- Won't work for 2026+
- Missing aggregation across segments

### 6. `20251203_fix_materialized_view_column_name.sql`
**Issues:**
- Attempted to fix column names
- Still references `is_mandatory` which doesn't exist
- Incomplete fix

### 7. `scripts/apply-final-materialized-view.mjs`
**Issues:**
- Was a temporary fix
- Not a proper migration file
- Superseded by canonical version

---

## Why These Were Deprecated

All 7 versions had one or more of these critical issues:

1. **Column Name Mismatches**
   - Referenced `is_mandatory` (doesn't exist)
   - Referenced `required_count` (actual column is `frequency`)
   - Referenced `required_count_per_year` (doesn't exist)

2. **Aggregation Errors**
   - Created multiple rows per client-year
   - Didn't properly aggregate across segment changes
   - Wrong GROUP BY clauses

3. **Missing Constraints**
   - No unique constraint on (client_name, year)
   - Allowed duplicates

4. **Incomplete Fixes**
   - Each migration tried to fix previous issues
   - Created more problems than they solved
   - No single source of truth

---

## Migration History

```
20251202_create_event_compliance_materialized_view.sql
    ↓ (had bugs)
20251202_fix_event_compliance_view_segment_changes.sql
    ↓ (still had bugs)
20251202_final_fix_single_record_per_client.sql
    ↓ (not actually final)
20251202_update_compliance_view_for_tier_requirements.sql
    ↓ (more bugs)
20251203_compliance_view_latest_segment_only.sql
    ↓ (still buggy)
20251203_fix_materialized_view_column_name.sql
    ↓ (incomplete)
scripts/apply-final-materialized-view.mjs
    ↓ (temporary)
20251203_CANONICAL_event_compliance_view.sql ✅ (CORRECT)
```

---

## What Changed in Canonical Version

### ✅ Fixed Column References
```sql
-- BEFORE (WRONG):
BOOL_OR(tr.is_mandatory) as is_mandatory          -- ❌ Column doesn't exist
MAX(tr.required_count) as required_count           -- ❌ Column doesn't exist

-- AFTER (CORRECT):
MAX(tr.expected_frequency) as expected_count       -- ✅ Uses actual 'frequency' column
TRUE as is_mandatory                                -- ✅ Default value
```

### ✅ Fixed Aggregation Logic
```sql
-- BEFORE (WRONG):
GROUP BY csp.client_name, csp.segment, csp.year   -- ❌ Creates duplicates

-- AFTER (CORRECT):
GROUP BY csp.client_name, csp.year                 -- ✅ Single row per client-year
-- Uses latest_segment CTE for display
```

### ✅ Added Unique Constraint
```sql
-- NEW in canonical version:
CREATE UNIQUE INDEX idx_event_compliance_unique_client_year
  ON event_compliance_summary(client_name, year);
```

### ✅ Comprehensive Documentation
- Rollback instructions
- Verification queries
- Maintenance guidelines
- Business rule comments

---

## Action Items

### For Developers

1. **DO NOT run** any of the deprecated migrations
2. **USE ONLY** the canonical version: `20251203_CANONICAL_event_compliance_view.sql`
3. **Reference** the code review: `docs/SEGMENTATION-CODE-REVIEW-2025-12-03.md`

### For DevOps

1. **Archive** deprecated migrations to `docs/migrations/deprecated/` folder
2. **Update** deployment scripts to use canonical version only
3. **Monitor** for duplicate rows (should be impossible now)

### For Future Changes

If you need to modify the materialized view:

1. **DO NOT** create a new migration file
2. **UPDATE** the canonical version: `20251203_CANONICAL_event_compliance_view.sql`
3. **INCREMENT** version number (e.g., v3.0.0 → v3.1.0)
4. **DOCUMENT** changes in header comments
5. **TEST** thoroughly before deploying

---

## Verification Commands

After deploying canonical version, verify it's working:

```bash
# Check no duplicates
node scripts/verify-no-duplicates.mjs

# Check Epworth data
node scripts/debug-epworth-missing-events.mjs

# Deploy canonical version
node scripts/deploy-canonical-view.mjs
```

---

## Questions?

See:
- `docs/SEGMENTATION-CODE-REVIEW-2025-12-03.md` - Full code review
- `docs/migrations/20251203_CANONICAL_event_compliance_view.sql` - Canonical version
- `scripts/deploy-canonical-view.mjs` - Deployment script

---

**Last Updated**: 2025-12-03
**Status**: These migrations are PERMANENTLY DEPRECATED
