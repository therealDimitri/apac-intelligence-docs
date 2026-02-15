# BURC Historical Data Enhancement Recommendations

**Date:** 2 January 2026
**Author:** Claude Code
**Status:** Recommendations
**Components:** BURC Executive Dashboard, Financials Page

---

## Executive Summary

We now have **74,757 historical BURC records** synced to Supabase, including 5+ years of detailed revenue data (2019-2024). This document outlines specific recommendations for leveraging this data in the BURC Executive and Financials pages.

---

## Current Data Available

### New Tables (synced today)

| Table | Records | Data Span |
|-------|---------|-----------|
| `burc_historical_revenue_detail` | **74,400** | 2019-2024 |
| `burc_critical_suppliers` | **357** | Current |
| `burc_monthly_ebita` | Ready | For monthly sync |
| `burc_risk_profile` | Ready | Dial 2 data |
| `burc_quarterly_comparison` | Ready | YoY analysis |
| `burc_exchange_rates` | Ready | FX hedging |
| `burc_sales_forecast` | Ready | Forecast accuracy |

### Existing Tables

| Table | Records |
|-------|---------|
| `burc_historical_revenue` | 4 |
| `burc_ps_pipeline` | 14 |
| `burc_attrition_risk` | 9 |
| `burc_contracts` | 8 |
| `burc_alert_thresholds` | 6 |

---

## Recommendations for BURC Executive Dashboard

### 1. Multi-Year Revenue Trend Chart

**What:** Add an interactive line/area chart showing revenue trends from 2019-2024

**Data Source:** `burc_historical_revenue_detail`

**SQL Query:**
```sql
SELECT
  fiscal_year,
  SUM(CASE WHEN revenue_type = 'SW' THEN amount_usd ELSE 0 END) as sw_revenue,
  SUM(CASE WHEN revenue_type = 'PS' THEN amount_usd ELSE 0 END) as ps_revenue,
  SUM(CASE WHEN revenue_type = 'Maint' THEN amount_usd ELSE 0 END) as maint_revenue,
  SUM(CASE WHEN revenue_type = 'HW' THEN amount_usd ELSE 0 END) as hw_revenue,
  SUM(amount_usd) as total_revenue
FROM burc_historical_revenue_detail
GROUP BY fiscal_year
ORDER BY fiscal_year;
```

**UI Component:**
- Recharts AreaChart with stacked revenue types
- Toggle between AUD/USD
- Click to drill into specific year

---

### 2. Client Lifetime Value Card

**What:** Show top clients by lifetime revenue with YoY growth

**Data Source:** `burc_historical_revenue_detail`

**SQL Query:**
```sql
SELECT
  client_name,
  parent_company,
  SUM(amount_usd) as lifetime_revenue,
  SUM(CASE WHEN fiscal_year = 2024 THEN amount_usd ELSE 0 END) as revenue_2024,
  SUM(CASE WHEN fiscal_year = 2023 THEN amount_usd ELSE 0 END) as revenue_2023,
  COUNT(DISTINCT fiscal_year) as years_active
FROM burc_historical_revenue_detail
GROUP BY client_name, parent_company
ORDER BY lifetime_revenue DESC
LIMIT 20;
```

**UI Component:**
- Sortable table with sparklines showing yearly trend
- Click to navigate to client detail page
- Highlight clients with declining revenue

---

### 3. Revenue Mix Evolution

**What:** Stacked bar chart showing how revenue mix has changed over years

**Data Source:** `burc_historical_revenue_detail`

**Insights to Surface:**
- Is maintenance revenue growing as a percentage? (recurring revenue health)
- PS revenue trend (utilisation indicator)
- SW revenue volatility (deal dependency)

---

### 4. Critical Suppliers Dashboard

**What:** New panel showing supplier risk and spend analysis

**Data Source:** `burc_critical_suppliers` (357 vendors)

**Features:**
- Supplier criticality heatmap
- Annual spend by category
- Contract renewal timeline
- Risk assessment indicators

---

### 5. Historical NRR/GRR Trends

**What:** Show how NRR and GRR have evolved over time

**Calculation:**
```sql
WITH yearly_totals AS (
  SELECT
    fiscal_year,
    SUM(amount_usd) as total_revenue
  FROM burc_historical_revenue_detail
  GROUP BY fiscal_year
)
SELECT
  y2.fiscal_year,
  y2.total_revenue,
  y1.total_revenue as prior_year,
  CASE
    WHEN y1.total_revenue > 0
    THEN (y2.total_revenue / y1.total_revenue * 100)
    ELSE 0
  END as yoy_growth_pct
FROM yearly_totals y2
LEFT JOIN yearly_totals y1 ON y1.fiscal_year = y2.fiscal_year - 1
ORDER BY y2.fiscal_year;
```

---

## Recommendations for Financials Page

### 1. Enhanced BURC Waterfall

**Current:** Shows committed, best case, pipeline
**Enhancement:** Add historical comparison column showing same period last year

**Data Source:** Compare `burc_waterfall` with `burc_historical_revenue_detail` for prior year

---

### 2. Revenue by Product Breakdown

**What:** Expand the maintenance section to show all products

**Data Source:** `burc_historical_revenue_detail`

**Features:**
- Product-level revenue trends
- Top growing vs declining products
- Product contribution to total revenue

---

### 3. Client Revenue Heatmap

**What:** Visual grid showing client revenue by month/quarter

**Data Source:** `burc_historical_revenue_detail`

```sql
SELECT
  client_name,
  fiscal_year,
  fiscal_month,
  SUM(amount_usd) as revenue
FROM burc_historical_revenue_detail
WHERE fiscal_year >= 2023
GROUP BY client_name, fiscal_year, fiscal_month
ORDER BY client_name, fiscal_year, fiscal_month;
```

**UI:** Calendar heatmap similar to GitHub contribution graph

---

### 4. Revenue Concentration Risk

**What:** Show how revenue is concentrated across clients

**Data Source:** `burc_historical_revenue_detail`

**Metrics:**
- Top 10 clients as % of total revenue
- Pareto analysis (80/20 rule)
- Client concentration trend over years
- Risk indicator if concentration is increasing

---

### 5. YoY Variance Analysis

**What:** Compare current period to same period in prior years

**Data Source:** `burc_quarterly_comparison` + `burc_historical_revenue_detail`

**Features:**
- Q1 2026 vs Q1 2025 vs Q1 2024 vs Q1 2023
- Variance explanations
- Drill down to client level

---

## ChaSen AI Integration

### New Query Patterns

With 74,400 historical records, ChaSen can now answer:

1. **"What was our total revenue in 2021?"**
   - Query `burc_historical_revenue_detail` for fiscal_year = 2021

2. **"Which clients have grown the most since 2020?"**
   - Compare client revenue across years

3. **"How has our maintenance revenue trended?"**
   - Filter by revenue_type = 'Maint' and group by year

4. **"What's our revenue from WA Health over the years?"**
   - Filter by client_name and show yearly progression

5. **"Compare our PS revenue to 3 years ago"**
   - Direct YoY comparison

### Context Update

Update `src/lib/chasen-burc-context.ts` to include:

```typescript
export async function getBURCHistoricalContext(): Promise<string> {
  const { data } = await supabase
    .from('burc_historical_revenue_detail')
    .select('fiscal_year, amount_usd')
    .order('fiscal_year')

  const yearlyTotals = data?.reduce((acc, row) => {
    acc[row.fiscal_year] = (acc[row.fiscal_year] || 0) + row.amount_usd
    return acc
  }, {} as Record<number, number>)

  return `Historical revenue available: ${JSON.stringify(yearlyTotals)}`
}
```

---

## Implementation Priority

### Phase 1: Quick Wins (1-2 hours each)

1. ✅ Add yearly revenue trend chart to BURC dashboard
2. ✅ Add top clients by lifetime value table
3. ✅ Add critical suppliers panel

### Phase 2: Enhanced Analytics (2-4 hours each)

4. Revenue mix evolution chart
5. Client revenue heatmap
6. Revenue concentration risk indicator

### Phase 3: Advanced Features (4-8 hours each)

7. Historical NRR/GRR trends with forecasting
8. YoY variance analysis with drill-down
9. ChaSen AI historical query support

---

## API Endpoints Needed

### 1. GET /api/analytics/burc/historical-trend

Returns yearly revenue aggregates for trend charts.

### 2. GET /api/analytics/burc/client-lifetime

Returns client lifetime value with yearly breakdown.

### 3. GET /api/analytics/burc/revenue-mix

Returns revenue composition by type per year.

### 4. GET /api/analytics/burc/concentration

Returns client concentration metrics.

---

## Hooks to Create

```typescript
// src/hooks/useBURCHistorical.ts
export function useBURCHistorical() {
  // Fetch historical revenue trends
}

export function useClientLifetimeValue(clientName?: string) {
  // Fetch client LTV data
}

export function useRevenueMix(year?: number) {
  // Fetch revenue composition
}
```

---

## Summary

With **74,400+ historical records** now available, the BURC dashboard can transform from a current-period view to a comprehensive multi-year analytics platform. The recommendations above would enable:

- 📈 5-year revenue trend analysis
- 👥 Client lifetime value tracking
- 📊 Revenue mix evolution
- ⚠️ Concentration risk monitoring
- 🤖 AI-powered historical insights

These enhancements would significantly increase the strategic value of the BURC Executive Dashboard for leadership decision-making.
