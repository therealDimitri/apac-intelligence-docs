# Feature: BURC-to-Planning Financials Sync Job

**Date**: 2026-01-09
**Type**: Feature Implementation
**Status**: Complete
**Author**: Claude Opus 4.5

## Summary

Created a comprehensive sync job that aggregates BURC financial data and populates the Account Planning Hub v2 tables at multiple levels of the organisation hierarchy.

## Files Created/Modified

### New Files
- `/scripts/sync-planning-financials.mjs` - Main sync script

### Modified Files
- `/package.json` - Added npm scripts:
  - `planning:sync:financials` - Run full sync
  - `planning:sync:financials:dry-run` - Run in dry-run mode

## Implementation Details

### Data Flow

The script reads from existing BURC source tables and aggregates data to planning tables:

```
BURC Source Tables                    Planning Target Tables
--------------------                  ----------------------
burc_client_revenue_detail  ────┐
burc_arr_tracking           ────┤
burc_nrr_metrics            ────┼──► account_plan_financials (Client Level)
burc_attrition_risk         ────┤            │
burc_pipeline_deals         ────┤            ▼
burc_contracts              ────┤    territory_strategy_financials (Territory Level)
aging_accounts              ────┤            │
client_health_history       ────┘            ▼
                                     business_unit_planning (BU Level)
                                             │
                                             ▼
                                     apac_planning_goals (APAC Level)
```

### Aggregation Levels

1. **Client Level (`account_plan_financials`)**
   - Current ARR and MRR
   - Revenue breakdown (Software, PS, Maintenance, Hardware)
   - Target ARR and growth percentage
   - Expansion pipeline and weighted pipeline
   - 3-year NRR/GRR calculations
   - Lifetime value and tenure
   - AR balance, overdue, DSO
   - Collection risk assessment
   - Renewal date, value, and risk

2. **Territory Level (`territory_strategy_financials`)**
   - Aggregated ARR from clients
   - Target ARR and gap to target
   - Revenue breakdown (Runrate, Business Cases, Pipeline)
   - Portfolio NRR/GRR (weighted average)
   - Quarterly targets and actuals
   - Client distribution and concentration risk
   - Renewal pipeline by quarter
   - BU contribution percentage

3. **BU Level (`business_unit_planning`)**
   - Aggregated metrics from territories
   - Territory count and data (JSONB)
   - KPIs: NRR, GRR, EBITA margin, Rule of 40
   - Segment distribution (Giant, Large, Medium, Small)
   - Planning coverage and compliance
   - Health metrics and at-risk accounts
   - Gap analysis and pipeline

4. **APAC Level (`apac_planning_goals`)**
   - Aggregated from all BUs
   - Revenue targets and actuals
   - BU contributions (JSONB)
   - KPI targets vs actuals
   - Gap closure pipeline
   - Risk summary
   - Planning status and deadline

### Key Features

- **Dry-run mode**: Use `--dry-run` flag to preview changes without database modifications
- **Verbose logging**: Use `--verbose` or `-v` for detailed logging
- **Idempotent**: Safe to run multiple times - uses upserts where possible
- **Error handling**: Graceful error handling with detailed logging
- **Statistics tracking**: Reports insert/update/error counts for each table

### Territory and BU Mapping

```javascript
// CSE to Territory mapping
const CSE_TERRITORY_MAPPING = {
  'Tracey Bugeja': 'Victoria',
  'Jess Gawler': 'New South Wales',
  'John Bugeja': 'South Australia / Western Australia',
  'Jimmy Leimonitis': 'Singapore / SEA',
  'Boon Koh': 'Singapore / SEA'
}

// Territory to BU mapping
const TERRITORY_BU_MAPPING = {
  'Victoria': 'ANZ',
  'New South Wales': 'ANZ',
  'Queensland': 'ANZ',
  'South Australia / Western Australia': 'ANZ',
  'New Zealand': 'ANZ',
  'Singapore / SEA': 'SEA',
  'Malaysia': 'SEA',
  'Thailand': 'SEA',
  'Hong Kong': 'Greater China',
  'China': 'Greater China',
  'Taiwan': 'Greater China'
}
```

## Usage

### Run Full Sync
```bash
npm run planning:sync:financials
```

### Run Dry-Run (No Changes)
```bash
npm run planning:sync:financials:dry-run
```

### Run with Verbose Logging
```bash
node scripts/sync-planning-financials.mjs --verbose
```

## Output Example

```
======================================================================
BURC-to-Planning Financials Sync
======================================================================
Started: 2026-01-09T10:30:00.000Z
Fiscal Year: 2026
Mode: LIVE

Step 1: Fetching source data...
Found 150 unique clients in BURC data

Step 2: Aggregating client financials...
Aggregated 150 client financial records

Step 3: Aggregating territory financials...
Aggregated 5 territory financial records

Step 4: Aggregating BU financials...
Aggregated 3 BU financial records

Step 5: Aggregating APAC goals...
Aggregated APAC goals

Step 6: Syncing to database...
  Inserted: 12, Updated: 138, Errors: 0
  Inserted: 0, Updated: 5, Errors: 0
  Updated: 3, Errors: 0
  Updated APAC goals for FY2026

======================================================================
SYNC SUMMARY
======================================================================
Account Plan Financials: 12 inserted, 138 updated, 0 errors
Territory Financials:    0 inserted, 5 updated, 0 errors
Business Unit Planning:  3 updated, 0 errors
APAC Goals:              1 updated, 0 errors

Completed in 4.52s
Finished: 2026-01-09T10:30:04.520Z

Key Metrics:
  Total APAC ARR: $48,200,000
  Target ARR:     $52,000,000
  Gap to Target:  $3,800,000
  NRR:            98.1%
  GRR:            76.2%
```

## Dependencies

The script requires the following BURC tables to exist (created by prior migrations):
- `burc_client_revenue_detail`
- `burc_arr_tracking`
- `burc_nrr_metrics`
- `burc_attrition_risk`
- `burc_pipeline_deals`
- `burc_contracts`
- `aging_accounts`
- `client_health_history`
- `clients`
- `client_segmentation`
- `burc_monthly_forecast`

And the following target tables (from `20260109_planning_hub_enhancements.sql`):
- `account_plan_financials`
- `territory_strategy_financials`
- `business_unit_planning`
- `apac_planning_goals`

## Future Enhancements

1. **Schedule automation**: Add to cron or GitHub Actions for daily sync
2. **Incremental updates**: Only update changed records for better performance
3. **Client-territory mapping**: Add database table for dynamic mapping instead of hardcoded
4. **Health score integration**: Pull real-time health scores from `client_health_history`
5. **Segment-based calculations**: Use actual segmentation data from `client_segmentation`

## Related Documentation

- Planning Hub Enhancements: `/docs/features/account-planning-hub-enhancements-v2.md`
- BURC Migration: `/docs/migrations/20260109_planning_hub_enhancements.sql`
- BURC Comprehensive Tables: `/docs/migrations/20260103_comprehensive_burc_data.sql`
