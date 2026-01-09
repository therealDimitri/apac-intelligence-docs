# Bug Report: Planning Hub Tables Not Accessible via REST API

**Date:** 2026-01-09
**Status:** RESOLVED
**Severity:** High
**Component:** Database / Supabase PostgREST

## Issue Description

The Planning Hub database migration tables existed in the PostgreSQL database but were not accessible via the Supabase REST API. Queries returned `PGRST205` errors indicating the tables could not be found in the schema cache.

## Root Cause

The tables were either:
1. Not yet created in the database, OR
2. Created but PostgREST's schema cache had not been refreshed to recognise them

Investigation revealed the tables did **not exist** in the database - the migration had not been applied.

## Affected Tables (13 total)

1. `account_plan_ai_insights` - AI-generated insights for account plans
2. `next_best_actions` - Recommended actions for CSEs/CAMs
3. `stakeholder_relationships` - Stakeholder mapping data
4. `stakeholder_influences` - Relationships between stakeholders
5. `predictive_health_scores` - Predicted health scores with churn risk
6. `meddpicc_scores` - MEDDPICC methodology scoring
7. `engagement_timeline` - Denormalised timeline of all touchpoints
8. `account_plan_event_requirements` - Segmentation event requirements
9. `territory_compliance_summary` - Territory-level compliance rollups
10. `account_plan_financials` - BURC financial integration per account
11. `territory_strategy_financials` - Territory-level financial rollups
12. `business_unit_planning` - BU-level planning data (ANZ, SEA, Greater China)
13. `apac_planning_goals` - APAC-wide goals and KPIs

## Resolution Steps

### 1. Applied Migration via exec_sql RPC Function

Used the `exec_sql` RPC function with `sql_query` parameter to execute each table creation statement:

```sql
-- Example for one table
CREATE TABLE IF NOT EXISTS apac_planning_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL UNIQUE,
  target_revenue DECIMAL(15,2),
  current_revenue DECIMAL(15,2),
  gap DECIMAL(15,2),
  -- ... additional columns
);
```

### 2. Created Performance Indexes

Added indexes for common query patterns:
- Client lookups
- Plan associations
- Date-based filtering
- Status filtering

### 3. Enabled Row Level Security (RLS)

All tables have RLS enabled with:
- **Authenticated users**: Full access (SELECT, INSERT, UPDATE, DELETE)
- **Anonymous users**: Read-only access (SELECT)

### 4. Triggered Schema Cache Reload

```sql
NOTIFY pgrst, 'reload schema'
```

### 5. Inserted Seed Data for FY26

**APAC Planning Goals:**
- Target Revenue: $52,000,000
- Current Revenue: $48,200,000
- Gap: $3,800,000
- Growth Target: 7.9%
- Target NRR: 105%
- Target GRR: 95%

**Business Unit Planning:**
| BU | Target ARR | Current ARR | Gap | APAC % |
|---|---|---|---|---|
| ANZ | $31,000,000 | $28,400,000 | $2,600,000 | 59.6% |
| SEA | $13,000,000 | $12,100,000 | $900,000 | 25.0% |
| Greater China | $8,000,000 | $7,700,000 | $300,000 | 15.4% |

## Verification

All 13 tables now respond correctly to REST API queries:

```bash
curl -s "https://usoyxsunetvxdjdglkmn.supabase.co/rest/v1/apac_planning_goals?select=*" \
  -H "apikey: [SERVICE_ROLE_KEY]" \
  -H "Authorization: Bearer [SERVICE_ROLE_KEY]"
```

Returns FY26 goals data successfully.

## Prevention

1. **Migration File:** The complete migration is stored at:
   `supabase/migrations/20260109_planning_hub_enhancements.sql`

2. **Schema Documentation:** Update `docs/database-schema.md` with new table definitions

3. **Schema Cache:** After any DDL changes, always trigger:
   ```sql
   NOTIFY pgrst, 'reload schema'
   ```

## Related Files

- Migration: `/supabase/migrations/20260109_planning_hub_enhancements.sql`
- API Integration: Components using these tables for Planning Hub v2

## Notes

- The `pg_notify` RPC function does not exist; use `exec_sql` with `NOTIFY pgrst, 'reload schema'` instead
- The `exec_sql` function uses parameter name `sql_query`, not `query`
