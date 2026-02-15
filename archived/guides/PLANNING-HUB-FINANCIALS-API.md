# Planning Hub Financials API Guide

**Created**: 2026-01-09
**Status**: Implemented
**Routes**: 4 new API endpoints

---

## Overview

This guide documents the Planning Hub financial data API routes that provide access to account-level, territory-level, business unit-level, and APAC-wide financial planning data.

All routes support graceful fallback to existing BURC tables when the new planning tables don't have data yet.

---

## API Endpoints

### 1. Account-Level Financials

**Endpoint**: `GET /api/planning/financials/account`

**Description**: Fetches account-level BURC financial data for individual client accounts.

**Query Parameters**:
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `fiscal_year` | number | No | Current year | Fiscal year to query |
| `client_id` | string | No | - | Filter by client UUID |
| `client_name` | string | No | - | Filter by client name (partial match) |
| `plan_id` | string | No | - | Filter by account plan UUID |

**Response Structure**:
```typescript
{
  data: AccountPlanFinancials[],
  summary: {
    total_arr: number,
    total_target_arr: number,
    gap_to_target: number,
    avg_nrr: number,
    avg_grr: number,
    total_at_risk_arr: number,
    accounts_count: number
  },
  fiscal_year: number,
  generated_at: string,
  fallback_data_used: boolean
}
```

**Data Source Priority**:
1. `account_plan_financials` table (new)
2. `burc_revenue_detail` table (fallback)

---

### 2. Territory-Level Financials

**Endpoint**: `GET /api/planning/financials/territory`

**Description**: Fetches territory-level financial rollups for CSE portfolios.

**Query Parameters**:
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `fiscal_year` | number | No | Current year | Fiscal year to query |
| `territory` | string | No | - | Filter by territory name (partial match) |
| `cse_name` | string | No | - | Filter by CSE name (partial match) |
| `bu_name` | string | No | - | Filter by business unit |

**Response Structure**:
```typescript
{
  data: TerritoryStrategyFinancials[],
  summary: {
    total_arr: number,
    total_target_arr: number,
    gap_to_target: number,
    avg_nrr: number,
    avg_grr: number,
    territories_count: number,
    total_client_count: number
  },
  quarterly_performance: {
    q1: { target: number, actual: number, variance: number },
    q2: { target: number, actual: number, variance: number },
    q3: { target: number, actual: number, variance: number },
    q4: { target: number, actual: number, variance: number }
  },
  fiscal_year: number,
  generated_at: string,
  fallback_data_used: boolean
}
```

**Data Source Priority**:
1. `territory_strategy_financials` table (new)
2. `burc_quarterly_data` + `client_segmentation` (fallback)

---

### 3. Business Unit-Level Financials

**Endpoint**: `GET /api/planning/financials/business-unit`

**Description**: Fetches business unit planning data with KPIs and territory breakdown.

**Query Parameters**:
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `bu` | string | No | 'ANZ' | Business unit: 'ANZ', 'SEA', 'Greater China' |
| `fiscal_year` | number | No | Current year | Fiscal year to query |

**Response Structure**:
```typescript
{
  data: {
    businessUnit: string,
    summary: {
      currentARR: number,
      fy26Target: number,
      gapToClose: number,
      progressPercent: number,
      clientCount: number,
      avgARRPerClient: number
    },
    apacContribution: {
      arrPercent: number,
      targetPercent: number,
      clientPercent: number
    },
    kpis: {
      nrr: number,
      grr: number,
      ebitaMargin: number,
      ruleOf40: number,
      complianceRate: number,
      healthScore: number,
      nrrTrend: 'up' | 'down' | 'stable',
      grrTrend: 'up' | 'down' | 'stable',
      ruleOf40Status: 'passing' | 'at-risk' | 'failing'
    },
    territories: Array<TerritoryBreakdown>,
    segments: Array<SegmentDistribution>,
    strategicInitiatives: Array<Initiative>
  },
  source: 'business_unit_planning' | 'fallback',
  fiscal_year: number
}
```

**Data Source Priority**:
1. `business_unit_planning` table (new)
2. Multi-table aggregation from BURC tables (fallback)

---

### 4. APAC-Level Planning Goals

**Endpoint**: `GET /api/planning/financials/apac`

**Description**: Fetches APAC-wide planning goals and progress metrics.

**Query Parameters**:
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `fiscal_year` | number | No | Current year | Fiscal year to query |

**Response Structure**:
```typescript
{
  data: APACPlanningGoals,
  kpi_summary: {
    nrr: { target: number, actual: number, variance: number, status: string },
    grr: { target: number, actual: number, variance: number, status: string },
    ebita_margin: { target: number, actual: number, variance: number, status: string },
    rule_of_40: { target: number, actual: number, variance: number, status: string },
    health_score: { target: number, actual: number, variance: number, status: string },
    compliance: { target: number, actual: number, variance: number, status: string }
  },
  planning_progress: {
    account_plans: { required: number, approved: number, percentage: number },
    territory_strategies: { required: number, approved: number, percentage: number },
    days_to_deadline: number | null
  },
  risk_overview: {
    total_at_risk_arr: number,
    total_at_risk_accounts: number,
    churn_risk_arr: number,
    declining_health_arr: number,
    below_compliance_arr: number
  },
  fiscal_year: number,
  generated_at: string,
  fallback_data_used: boolean
}
```

**Data Source Priority**:
1. `apac_planning_goals` table (new)
2. Multi-table aggregation from BURC + BU tables (fallback)

---

## Database Tables

### New Tables (from migration 20260109_planning_hub_enhancements.sql)

| Table | Purpose |
|-------|---------|
| `account_plan_financials` | Client-level financial data linked to account plans |
| `territory_strategy_financials` | Territory-level rollups linked to territory strategies |
| `business_unit_planning` | BU-level planning targets and KPIs |
| `apac_planning_goals` | APAC regional goals and progress tracking |

### Fallback Tables

| Table | Used For |
|-------|----------|
| `burc_revenue_detail` | Client revenue breakdown by type |
| `burc_quarterly_data` | Quarterly metrics |
| `burc_annual_financials` | Annual financial summaries |
| `burc_waterfall` | Pipeline and forecasting data |
| `client_segmentation` | Client-CSE mapping |
| `client_health_history` | Health score trends |

---

## Type Definitions

All types are defined in `/src/types/planning-financials.ts`:

- `AccountPlanFinancials`
- `AccountFinancialsResponse`
- `TerritoryStrategyFinancials`
- `TerritoryFinancialsResponse`
- `BusinessUnitPlanning`
- `BusinessUnitResponse`
- `APACPlanningGoals`
- `APACGoalsResponse`
- `BUContribution`
- `TerritoryData`

---

## Caching

All endpoints implement a 5-minute in-memory cache with cache keys based on query parameters.

Response includes `cache_hit: true` when returning cached data.

---

## Usage Examples

### Fetch ANZ BU Financial Data

```typescript
const response = await fetch('/api/planning/financials/business-unit?bu=ANZ&fiscal_year=2026')
const data = await response.json()
```

### Fetch Client-Specific Financial Data

```typescript
const response = await fetch('/api/planning/financials/account?client_name=Barwon&fiscal_year=2026')
const data = await response.json()
```

### Fetch APAC Goals

```typescript
const response = await fetch('/api/planning/financials/apac?fiscal_year=2026')
const data = await response.json()
```

---

## File Locations

| File | Purpose |
|------|---------|
| `/src/app/api/planning/financials/account/route.ts` | Account-level API |
| `/src/app/api/planning/financials/territory/route.ts` | Territory-level API |
| `/src/app/api/planning/financials/business-unit/route.ts` | BU-level API |
| `/src/app/api/planning/financials/apac/route.ts` | APAC goals API |
| `/src/types/planning-financials.ts` | TypeScript type definitions |
