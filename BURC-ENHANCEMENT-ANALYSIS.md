# BURC Enhancement Analysis & Recommendations

**Date**: 2 January 2026
**Author**: Claude Code Analysis
**Status**: Strategic Planning Document
**Review Cadence**: Monthly (aligned with BURC cycle)

---

## Executive Summary

The BURC (Business Unit Review Committee) file is a **critical global performance document** that determines the success of the APAC business unit. This standardised process exists across all Harris/Altera global regions and provides the narrative on business health, profitability, and operational efficiency.

This document analyses the current BURC integration, identifies **untapped data opportunities**, and recommends enhancements to strengthen analytics, data integrity, and workflow automation.

**Key Findings (Comprehensive Analysis - 2 January 2026):**
- **247 BURC files** analysed (195 XLSX + 52 XLSB binary files)
- **28 Monthly Revenue & COGS Detail files** - critical foundation for NRR/GRR
- **6+ years of historical revenue data** (2019-2024) with customer-level detail
- **11 Cross-Charge allocation files** - essential for accurate cost attribution
- **20+ Pipeline & Sales Forecast files** - future revenue visibility
- **4 Attrition tracking files** - churn analysis and NRR denominator
- **8+ FX and Exchange Rate files** - multi-currency revenue analysis
- **52 XLSB files** require conversion - contain monthly consolidated BURC data
- **Industry gap**: Missing 8+ standard SaaS KPIs (NRR, GRR, Rule of 40, CAC, LTV)
- **Automation opportunity**: 80%+ of current analytics could be automated

---

## Part 0: BURC File Archive Inventory

### Primary Data Location

```
OneDrive-AlteraDigitalHealth(2)/APAC Leadership Team - General/Performance/Financials/BURC/
```

### File Inventory Summary

| Year | XLSX | XLSB | Total | Key Contents |
|------|------|------|-------|--------------|
| **2023** | 58 | 28 | 86 | Historical actuals, monthly BURC reports |
| **2024** | 52 | 18 | 70 | Full year performance, Dial 2 snapshots |
| **2025** | 75 | 6 | 81 | Current year tracking, attrition forecasts |
| **2026** | 10 | 0 | 10 | Budget planning, 3-year GAP analysis |
| **Multi-year** | 1 | 0 | 1 | APAC Revenue 2019-2024 |
| **Total** | **195** | **52** | **247** | Comprehensive financial archive |

### Sync Priority Tiers (Ranked by Business Impact)

#### TIER 1: CRITICAL - Foundation Analytics (63 files)
| Priority | File Type | Count | Purpose |
|----------|-----------|-------|---------|
| 1 | Historical Revenue (2019-2024) | 1 | NRR/GRR baseline, 6-year trending |
| 2 | Monthly Revenue & COGS Detail | 28 | Core revenue data, product-level P&L |
| 3 | Attrition & Client Retention | 4 | Churn tracking, NRR denominator |
| 4 | ARR Target files | 1 | ARR validation |
| 5 | 2024-2026 Performance files | 3 | Annual consolidated data |

#### TIER 2: HIGH PRIORITY - Revenue Analysis (34+ files)
| Priority | File Type | Count | Purpose |
|----------|-----------|-------|---------|
| 6 | Product-line revenue (Opal, PS, Hosting) | 15+ | Product profitability |
| 7 | PS Revenue & Backlog | 8+ | PS margin analysis |
| 8 | Cross-charge & Allocation | 11 | Cost attribution accuracy |
| 9 | Support Metrics & Incidents | 5 | Support economics |

#### TIER 3: MEDIUM PRIORITY - Forecasting (60+ files)
| Priority | File Type | Count | Purpose |
|----------|-----------|-------|---------|
| 10 | Budget & Planning files | 35+ | Budget vs actual trending |
| 11 | Pipeline & Forecast files | 20+ | Future revenue visibility |
| 12 | Baseline & Variance files | 6 | Monthly performance tracking |
| 13 | FX & Period-end files | 8+ | Multi-currency analysis |

### Critical Monthly Revenue & COGS Files (28 files)

**2025 Files (9 files):**
- `2025/Mar/2025 03 Rev and COGS Details.xlsx`
- `2025/Feb/2025 YTD Rev & COGS APAC.xlsx`
- `2025/Aug/2025 08 Rev and COGS Detail.xlsx`
- `2025/Jul/2025 07 Rev and COGS Detail.xlsx`
- `2025/Oct/2025 10 Rev and COGS Detail.xlsx`
- `2025/May/2025 05 Rev and COGs Detail.xlsx`
- `2025/Apr/25 04 Rev and COGS detail.xlsx`
- `2025/Sep/APAC Sep Actual & COGS.xlsx`
- `2025/Nov/2025 11 Rev and COGS detail.xlsx`

**2024 Files (11 files):**
- `2024/Mar/24 04 APAC Rev and COGS Detail.xlsx`
- `2024/Feb/24 02 APAC Rev COGS Details.xlsx`
- `2024/Aug/2024 08 Rev and COGS Detail.xlsx`
- `2024/Sep/2024 09 Rev and COGS Actuals.xlsx`
- `2024/Jul/YTD APAC Rev & COGS Detail.xlsx`
- `2024/Oct/24 10 APAC YTD Rev and COGS detail.xlsx`
- `2024/May/2024 May Rev and COGS Details.xlsx`
- `2024/Apr/2024 04 Rev and COGS Detail.xlsx`
- `2024/Dec/2024 12 Rev and COGS Actuals.xlsx`
- `2024/Nov/2024 11 APAC Rev COGS Detail.xlsx`
- `2024/Jun/APAC YTD Rev and COGS detail.xlsx`

**2023 Files (8 files):**
- `2023/Aug 23/Actual/Aug APAC Rev and COGS Detail.xlsx`
- `2023/Sep 23/2023 09 Actuals APAC Rev and COGS detail.xlsx`
- `2023/Dec 23/2023 Dec APAC Rev and COGS detail.xlsx`
- `2023/Nov 23/23 Nov APAC Rev and COGS Detail.xlsx`
- `2023/July 23/Actuals/APAC July 2023 Revenue Detail.xlsx`
- `2023/Oct 23/ANZ RevCOGS - Oct23.xlsx`

### Cross-Charge Allocation Files (11 files)

Essential for accurate cost attribution to products/BUs:
- `2023/April 23/Actuals/23 04 PS Cross Charges.xlsx`
- `2023/Aug 23/Actual/2023 08 APAC PS Cross Charges.xlsx`
- `2023/June 23/Actuals/2023 06 PS Cross Charges.xlsx`
- `2023/July 23/Actuals/2023 07 PS Cross Charges.xlsx`
- `2023/Nov 23/2023 Nov PS Cross Charges.xlsx`
- `2024/Feb/2024 02 PS Cross Charges.xlsx`
- `2024/Sep/APAC PS YTD Cross-Charge Summary - 2024-10-25.xlsx`
- `2024/Sep/APAC PS YTD Cross-Charge Summary - 2024-10-16.xlsx`
- `2025/02/2025 02 Support Cross Charge Info.xlsx`
- `2025/Oct/25 10 APAC YTD Cross Charge Detail.xlsx`

### Major Client Contract Files

**WA Health (10-Year Agreement - Critical):**
- `2025/May/WA Health Support Rev 10 yr.xlsx` - 10-year billing schedule
- `2025/May/WA Health Support Rev 10 yr - billing schedule draft.xlsx`
- `2025/May/WA Health Whole of state Opal pricing Working Version 1.2.xlsx`

### Key Files by Purpose

| Purpose | File | Sheets | Data Available |
|---------|------|--------|----------------|
| **Current Year Budget** | 2026 APAC Performance.xlsx | 35 | EBITA, CSI ratios, contracts, attrition |
| **Prior Year Actual** | 2025 APAC Performance.xlsx | 51 | Full actuals, variance analysis |
| **Historical Baseline** | 2024 APAC Performance.xlsx | 36 | YoY comparison baseline |
| **Revenue History** | APAC Revenue 2019-2024.xlsx | 3 | 6 years customer-level revenue |
| **3-Year Plan** | APAC 3 yrs EBITA GAP Analysis.xlsx | 2 | Multi-year EBITA projections |
| **Budget Gap** | APAC 2026 Budget GAP_ver3.xlsx | 3 | Budget variance analysis |

### 2024 Performance File - Full Sheet List (36 sheets)

Sheets not currently synced that contain valuable data:
1. **PS Margins** - Professional services profitability
2. **Support Renewals** - Contract renewal tracking
3. **Revenue by Product** - Product-level breakdown
4. **Headcount Summary/Pivot** - FTE data for revenue-per-FTE
5. **iQemo** - Product-specific performance
6. **Sunrise Support %** - Support allocation
7. **BU Cross Charge to APAC 5%** - Inter-company charges
8. **Dial 2 Risk Profile (07, 08, 09, 10, 2024)** - Monthly pipeline snapshots

### Historical Revenue Data Structure (2019-2024)

```
Customer Level Summary sheet contains:
- Parent Company → Customer Name → Revenue Type → Year columns
- Revenue types: Hardware, License, Maintenance, Professional Services
- 91 rows of customer-level data
- 6 years of historical trending
```

**Example data:**
| Parent Company | Customer | Revenue Type | 2019 | 2020 | 2021 | 2022 | 2023 |
|----------------|----------|--------------|------|------|------|------|------|
| ADHI | SA Health | Maintenance | $4.6M | $4.4M | $4.6M | $5.0M | $5.8M |
| ADHI | SA Health | PS Revenue | $3.1M | $3.6M | $4.0M | $4.1M | $1.6M |

---

## Part 1: BURC Context & Importance

### What is BURC?

The BURC file is a monthly financial performance report that:
- Tracks **EBITA** (Earnings Before Interest, Tax, and Amortisation) vs targets
- Monitors **5 CSI Operating Ratios** (cost efficiency metrics)
- Reports **revenue streams** (License, PS, Maintenance, Hardware)
- Forecasts **pipeline and business cases**
- Identifies **attrition risks** and client health

### Global Standardisation

| Aspect | Detail |
|--------|--------|
| **Frequency** | Monthly review, quarterly deep-dive |
| **Audience** | Regional leadership, Global finance, Executive team |
| **Format** | Excel workbook with standardised sheet structure |
| **Regions** | APAC, EMEA, Americas (same process) |
| **Purpose** | Performance narrative, variance explanation, forecast accuracy |

### Why This Matters

The BURC determines:
1. **Budget allocation** for next fiscal year
2. **Headcount approvals** and hiring plans
3. **Investment decisions** in products and initiatives
4. **Performance bonuses** for leadership
5. **Strategic priorities** for the region

**Any enhancement to BURC analytics directly impacts business decisions.**

---

## Part 2: Current Integration Status

### Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    BURC Excel File                               │
│  Location: OneDrive/.../BURC/2026/2026 APAC Performance.xlsx    │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│              Sync Script (sync-burc-data-supabase.mjs)          │
│  - Runs on schedule via launchd                                  │
│  - Parses 6 sheets currently                                     │
│  - Uses Supabase REST API                                        │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Supabase Database                             │
│  Tables: burc_ebita_monthly, burc_quarterly, burc_waterfall,    │
│          burc_client_maintenance, burc_ps_pipeline,              │
│          burc_revenue_streams, burc_csi_opex, burc_sync_log     │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    API Endpoints                                 │
│  /api/analytics/burc/          - Main data                       │
│  /api/analytics/burc/csi-ratios - CSI Operating Ratios          │
│  /api/analytics/burc/csi-insights - AI-powered analysis         │
│  /api/analytics/burc/financial-health - KPI dashboard           │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    UI Components                                 │
│  /financials page with 5 tabs:                                   │
│  BURC | CSI Ratios | Analysis | Scenario Planning | Actions     │
└─────────────────────────────────────────────────────────────────┘
```

### Currently Synced Sheets (6 of 11+)

| Sheet Name | Database Table | Records | Status |
|------------|----------------|---------|--------|
| APAC BURC - Monthly EBITA | burc_ebita_monthly | 12/month | Active |
| 26 vs 25 Q Comparison | burc_quarterly | Variable | Active |
| Waterfall Data | burc_waterfall | 13 rows | Active |
| Maint Pivot | burc_client_maintenance | ~50 clients | Active |
| PS Pivot | burc_ps_pipeline | ~30 projects | Active |
| Revenue Streams | burc_revenue_streams | 7 rows | Active |

### CSI Operating Ratios (Fully Implemented)

| Ratio | Formula | Target | Current |
|-------|---------|--------|---------|
| **PS Ratio** | Net PS Revenue ÷ PS OPEX | ≥ 2.0 | Calculated |
| **Sales Ratio** | (70% × License) ÷ S&M OPEX | ≥ 1.0 | Calculated |
| **Maintenance Ratio** | (85% × Maint) ÷ Maint OPEX | ≥ 4.0 | Calculated |
| **R&D Ratio** | (30% License + 15% Maint) ÷ R&D OPEX | ≥ 1.0 | Calculated |
| **G&A Ratio** | G&A OPEX ÷ Total Revenue × 100 | ≤ 20% | Calculated |

---

## Part 3: Unused Data Opportunities

### High-Value Sheets NOT Being Synced

#### 1. Opal Maint Contracts and Value (Priority: Critical)

**What it contains:**
- Contract renewal dates
- CPI escalation clauses
- Contract values and terms
- Auto-renewal flags

**Current state:** Hardcoded renewal list in `seed-financial-alerts-from-burc.mjs`

**Opportunity:**
```
Estimated development: 4 hours
Business impact: HIGH
- Automated renewal pipeline dashboard
- 90/60/30 day renewal alerts
- CPI escalation tracking (potential revenue uplift)
- Contract terms analysis for negotiation prep
```

**Proposed table: `burc_contracts`**
```sql
CREATE TABLE burc_contracts (
  id SERIAL PRIMARY KEY,
  client_name TEXT NOT NULL,
  solution TEXT,
  renewal_date DATE NOT NULL,
  current_annual_value DECIMAL(12,2),
  cpi_percentage NUMERIC(4,2),
  auto_renewal BOOLEAN DEFAULT false,
  next_review_date DATE,
  contract_term_months INTEGER,
  status TEXT DEFAULT 'active',
  last_synced TIMESTAMPTZ DEFAULT NOW()
);
```

#### 2. Attrition Sheet (Priority: Critical)

**What it contains:**
- Client attrition risks (full/partial)
- Multi-year revenue impact (2025-2028)
- Forecast dates
- Total revenue at risk

**Current state:** Only ONE entry hardcoded (Healthscope - $1.8M)

**Opportunity:**
```
Estimated development: 4 hours
Business impact: CRITICAL
- Full attrition risk trending over time
- Multi-year revenue impact modelling
- Risk type pattern analysis
- Retention intervention tracking
- Predictive churn models
```

**Proposed table: `burc_attrition_risk`**
```sql
CREATE TABLE burc_attrition_risk (
  id SERIAL PRIMARY KEY,
  client_name TEXT NOT NULL,
  risk_type TEXT CHECK (risk_type IN ('full', 'partial')),
  forecast_date DATE,
  revenue_2025 DECIMAL(12,2),
  revenue_2026 DECIMAL(12,2),
  revenue_2027 DECIMAL(12,2),
  revenue_2028 DECIMAL(12,2),
  total_at_risk DECIMAL(12,2),
  status TEXT DEFAULT 'open',
  snapshot_date DATE DEFAULT CURRENT_DATE,
  mitigation_notes TEXT,
  last_synced TIMESTAMPTZ DEFAULT NOW()
);
```

#### 3. Dial 2 Risk Profile Summary (Priority: High)

**What it contains:**
- Business case pipeline opportunities
- Deal stages and probabilities
- Risk profiles
- Estimated values

**Current state:** Only records >$1M extracted in analysis script

**Opportunity:**
```
Estimated development: 6 hours
Business impact: HIGH
- Full pipeline visibility (all deal sizes)
- Stage distribution analysis
- Deal velocity tracking
- Win rate by segment/solution
- Probability-weighted forecasts
```

**Proposed table: `burc_business_cases`**
```sql
CREATE TABLE burc_business_cases (
  id SERIAL PRIMARY KEY,
  client_name TEXT NOT NULL,
  opportunity_name TEXT,
  solution_category TEXT,
  estimated_value DECIMAL(12,2),
  probability NUMERIC(3,2),
  stage TEXT,
  entered_pipeline_date DATE,
  expected_close_date DATE,
  risk_profile TEXT,
  owner TEXT,
  last_updated TIMESTAMPTZ DEFAULT NOW()
);
```

#### 4. Opal Maintenance Detail (Priority: Medium)

**What it contains:**
- Run Rate vs New Business vs At Risk breakdown
- Client-level maintenance dynamics
- Revenue momentum indicators

**Current state:** Pivot only (aggregated), not granular tracking

**Opportunity:**
```
Estimated development: 3 hours
Business impact: MEDIUM
- Early warning for Run Rate → At Risk transitions
- Client mix shift analysis
- Maintenance growth trends
- Upsell opportunity identification
```

#### 5. Waterfall Variance Notes (Priority: Medium)

**What it contains:**
- Column 3 has explanations for each variance line
- Why numbers changed month-over-month
- FX impact, pipeline shifts, cost changes

**Current state:** Notes column discarded during sync

**Opportunity:**
```
Estimated development: 2 hours
Business impact: MEDIUM
- Forecast accuracy improvement
- Variance explanation tracking
- Pattern recognition for better predictions
- Executive narrative support
```

---

## Part 4: Industry Best Practices Gap Analysis

Based on [industry research](https://www.venasolutions.com/blog/saas-kpis-metrics), the following SaaS KPIs are standard but **missing from BURC analytics**:

### Missing Financial KPIs

| KPI | Definition | Why It Matters | Priority |
|-----|------------|----------------|----------|
| **Net Revenue Retention (NRR)** | (Starting MRR + Expansion - Contraction - Churn) / Starting MRR | Shows if existing customers are growing | Critical |
| **Gross Revenue Retention (GRR)** | (Starting MRR - Contraction - Churn) / Starting MRR | Core retention health (excludes upsells) | Critical |
| **Customer Acquisition Cost (CAC)** | Total S&M Cost / New Customers | Already have data, not calculated | High |
| **CAC Payback Period** | CAC / (ARPU × Gross Margin) | Months to recover acquisition cost | High |
| **LTV:CAC Ratio** | Customer Lifetime Value / CAC | Should be >3:1 for healthy SaaS | High |
| **Rule of 40** | Revenue Growth % + EBITDA Margin % | Industry benchmark (should be >40%) | Medium |
| **Magic Number** | (QoQ ARR Growth × 4) / Prior Q S&M Spend | Sales efficiency indicator | Medium |
| **Burn Multiple** | Net Burn / Net New ARR | Capital efficiency | Medium |

### Missing Operational KPIs

| KPI | Definition | Data Source | Priority |
|-----|------------|-------------|----------|
| **PS Utilisation Rate** | Billable Hours / Available Hours | Exists in BURC, not displayed | High |
| **Revenue per FTE** | Total Revenue / Employee Count | Have both data points | High |
| **Support Ticket Trends** | Volume, resolution time, CSAT | Could integrate from Opal | Medium |
| **Implementation Backlog** | PS pipeline aging analysis | PS Pivot data available | Medium |

### Recommended KPI Dashboard Additions

```
┌─────────────────────────────────────────────────────────────────┐
│                    Financial Health Dashboard v2                 │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │ NRR: 108%   │  │ GRR: 94%    │  │ Rule of 40  │              │
│  │ ▲ +3% YoY   │  │ ▲ +2% YoY   │  │    42%      │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
│                                                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │ CAC: $45K   │  │ Payback: 14m│  │ LTV:CAC 4.2 │              │
│  │ ▼ -8% QoQ   │  │ ▼ -2m QoQ   │  │ ▲ +0.3 QoQ  │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
│                                                                  │
│  Revenue per FTE: $285K    PS Utilisation: 72%                  │
│  Magic Number: 0.8         Burn Multiple: N/A (profitable)      │
└─────────────────────────────────────────────────────────────────┘
```

---

## Part 5: Data Integrity & Validation Recommendations

### Current Gaps

1. **No validation on sync** - Data imported without schema validation
2. **No duplicate detection** - Same month could be imported twice
3. **No referential integrity** - Client names don't link to master client list
4. **Hardcoded exchange rate** - AUD→USD at fixed 0.65
5. **Missing audit trail** - Only sync timestamp logged, not what changed

### Recommended Improvements

#### 1. Schema Validation Layer

```typescript
// Add to sync script
const validateEBITARow = (row: any): boolean => {
  const required = ['month', 'baseline', 'target', 'actual'];
  return required.every(field => row[field] !== undefined && row[field] !== null);
};

const validateNumericRange = (value: number, min: number, max: number): boolean => {
  return value >= min && value <= max;
};
```

#### 2. Duplicate Prevention

```sql
-- Add unique constraints
ALTER TABLE burc_ebita_monthly
ADD CONSTRAINT unique_month_year UNIQUE (month, year);

-- Use UPSERT instead of INSERT
INSERT INTO burc_ebita_monthly (...)
VALUES (...)
ON CONFLICT (month, year) DO UPDATE SET ...;
```

#### 3. Client Name Normalisation

```typescript
// Create client name mapping table
const CLIENT_NAME_MAP = {
  'SA Health (iPro)': 'SA Health',
  'SA Health (iQemo)': 'SA Health',
  'SA Health (Sunrise)': 'SA Health',
  // ... more mappings
};

const normalizeClientName = (name: string): string => {
  return CLIENT_NAME_MAP[name] || name;
};
```

#### 4. Dynamic Exchange Rate

```typescript
// Fetch from API or config
const getExchangeRate = async (from: string, to: string): Promise<number> => {
  // Option 1: Use environment variable (updated monthly)
  if (process.env.AUD_USD_RATE) {
    return parseFloat(process.env.AUD_USD_RATE);
  }
  // Option 2: Fetch from exchange rate API
  // Option 3: Default fallback
  return 0.65;
};
```

#### 5. Audit Trail Enhancement

```sql
CREATE TABLE burc_sync_audit (
  id SERIAL PRIMARY KEY,
  sync_id UUID REFERENCES burc_sync_log(id),
  table_name TEXT NOT NULL,
  operation TEXT CHECK (operation IN ('insert', 'update', 'delete')),
  record_id INTEGER,
  old_values JSONB,
  new_values JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Part 6: Workflow Enhancement Recommendations

### Current Workflow

```
Day 1-5:   Finance team updates Excel
Day 5-10:  Regional review and adjustments
Day 10-15: Global consolidation
Day 15+:   Executive presentation
```

### Enhanced Workflow with Automation

```
┌────────────────────────────────────────────────────────────────┐
│                    BURC Workflow 2.0                            │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Day 1-3: Finance updates Excel                                 │
│     │                                                           │
│     ▼                                                           │
│  ┌─────────────────────────────────────────┐                   │
│  │ AUTO: File watcher detects changes      │                   │
│  │ AUTO: Validation runs on new data       │                   │
│  │ AUTO: Sync to database                  │                   │
│  │ AUTO: Anomaly detection flags issues    │                   │
│  └─────────────────────────────────────────┘                   │
│     │                                                           │
│     ▼                                                           │
│  Day 4-5: Regional review with live dashboards                 │
│     │                                                           │
│     ▼                                                           │
│  ┌─────────────────────────────────────────┐                   │
│  │ AUTO: Variance explanations prompted    │                   │
│  │ AUTO: AI narrative draft generated      │                   │
│  │ AUTO: Action items created from alerts  │                   │
│  └─────────────────────────────────────────┘                   │
│     │                                                           │
│     ▼                                                           │
│  Day 6-8: Approval workflow                                     │
│     │                                                           │
│     ▼                                                           │
│  ┌─────────────────────────────────────────┐                   │
│  │ AUTO: PDF report generated              │                   │
│  │ AUTO: Email to stakeholders             │                   │
│  │ AUTO: Archive snapshot for trending     │                   │
│  └─────────────────────────────────────────┘                   │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

### Specific Automations to Build

| Automation | Effort | Impact | Priority |
|------------|--------|--------|----------|
| File watcher auto-sync | 2h | High | P1 |
| Validation alerts on bad data | 4h | High | P1 |
| Anomaly detection (vs prior month) | 6h | High | P2 |
| AI narrative generation | 8h | Medium | P2 |
| Variance explanation prompts | 4h | Medium | P2 |
| Automated PDF + email distribution | 6h | Medium | P3 |
| Historical snapshot archiving | 4h | Low | P3 |

---

## Part 7: Implementation Roadmap

### Phase 1: Quick Wins (Week 1-2)

**Effort: 16 hours | Impact: High**

1. **Sync contract renewals sheet** (4h)
   - Parse "Opal Maint Contracts and Value"
   - Create `burc_contracts` table
   - Add renewal pipeline widget to dashboard

2. **Sync full attrition data** (4h)
   - Parse "Attrition" sheet completely
   - Create `burc_attrition_risk` table
   - Replace hardcoded alerts with dynamic queries

3. **Add NRR/GRR calculations** (4h)
   - Calculate from existing maintenance data
   - Add to financial health dashboard
   - Include in CSI insights context

4. **Waterfall notes capture** (4h)
   - Store variance explanations
   - Display in waterfall chart tooltips
   - Include in AI narrative context

### Phase 2: Analytics Enhancement (Week 3-4)

**Effort: 24 hours | Impact: Medium-High**

1. **Business case pipeline sync** (6h)
   - Parse "Dial 2 Risk Profile Summary"
   - Create `burc_business_cases` table
   - Build pipeline health dashboard

2. **CAC/LTV calculations** (6h)
   - Derive from BURC cost and revenue data
   - Add to financial KPI section
   - Calculate payback period

3. **Rule of 40 and Magic Number** (4h)
   - Simple calculations from existing data
   - Add benchmark comparisons
   - Historical trending

4. **PS utilisation display** (4h)
   - Data exists, not shown
   - Add to CSI ratios section
   - Link to PS ratio context

5. **Data validation layer** (4h)
   - Schema validation on sync
   - Duplicate prevention
   - Error alerting

### Phase 3: Workflow Automation (Week 5-6)

**Effort: 24 hours | Impact: Medium**

1. **Enhanced file watcher** (4h)
   - Immediate sync on file change
   - Validation before commit
   - Slack/Teams notification

2. **Anomaly detection** (8h)
   - Compare to prior month
   - Flag significant variances
   - Require explanation for large changes

3. **AI narrative enhancement** (8h)
   - Include all new data sources
   - Generate executive summary
   - Suggest action items

4. **Audit trail implementation** (4h)
   - Track all changes
   - Enable rollback capability
   - Compliance support

### Phase 4: Future Vision (Month 2+)

1. **Predictive forecasting** - ML models for revenue prediction
2. **Scenario modelling** - What-if analysis for business cases
3. **Cross-region comparison** - When other regions adopt similar systems
4. **Real-time Excel integration** - Live connection to OneDrive
5. **Mobile dashboard** - Executive view on mobile devices

---

## Part 8: Success Metrics

### How We'll Measure Improvement

| Metric | Current | Target | Timeline |
|--------|---------|--------|----------|
| Data freshness | Manual sync | <1 hour from Excel change | Phase 1 |
| Hardcoded alerts | 8 alerts | 0 (all dynamic) | Phase 1 |
| KPIs tracked | 12 | 20+ | Phase 2 |
| Forecast accuracy | Unknown | ±5% MRR | Phase 3 |
| Report generation time | 2 hours manual | 5 minutes auto | Phase 3 |
| Executive prep time | 4 hours/month | 1 hour/month | Phase 3 |

---

## Part 9: Risk Considerations

### Data Security
- BURC contains sensitive financial data
- Ensure RLS policies on all new tables
- Audit access logs monthly

### Change Management
- Finance team needs training on new dashboards
- Gradual rollout with feedback loops
- Maintain Excel as source of truth

### Technical Debt
- Document all calculations clearly
- Keep sync scripts maintainable
- Version control all changes

---

## Appendix A: Database Schema Additions

```sql
-- New tables for Phase 1-2

-- Contract renewals
CREATE TABLE burc_contracts (
  id SERIAL PRIMARY KEY,
  client_name TEXT NOT NULL,
  solution TEXT,
  renewal_date DATE NOT NULL,
  current_annual_value DECIMAL(12,2),
  cpi_percentage NUMERIC(4,2),
  auto_renewal BOOLEAN DEFAULT false,
  contract_term_months INTEGER,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_synced TIMESTAMPTZ DEFAULT NOW()
);

-- Attrition risk tracking
CREATE TABLE burc_attrition_risk (
  id SERIAL PRIMARY KEY,
  client_name TEXT NOT NULL,
  risk_type TEXT CHECK (risk_type IN ('full', 'partial')),
  forecast_date DATE,
  revenue_2025 DECIMAL(12,2),
  revenue_2026 DECIMAL(12,2),
  revenue_2027 DECIMAL(12,2),
  revenue_2028 DECIMAL(12,2),
  total_at_risk DECIMAL(12,2),
  status TEXT DEFAULT 'open',
  mitigation_notes TEXT,
  snapshot_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Business case pipeline
CREATE TABLE burc_business_cases (
  id SERIAL PRIMARY KEY,
  client_name TEXT NOT NULL,
  opportunity_name TEXT,
  solution_category TEXT,
  estimated_value DECIMAL(12,2),
  probability NUMERIC(3,2),
  stage TEXT,
  entered_pipeline_date DATE,
  expected_close_date DATE,
  risk_profile TEXT,
  owner TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_updated TIMESTAMPTZ DEFAULT NOW()
);

-- Sync audit trail
CREATE TABLE burc_sync_audit (
  id SERIAL PRIMARY KEY,
  sync_id UUID,
  table_name TEXT NOT NULL,
  operation TEXT CHECK (operation IN ('insert', 'update', 'delete')),
  record_count INTEGER,
  old_values JSONB,
  new_values JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_contracts_renewal ON burc_contracts(renewal_date);
CREATE INDEX idx_attrition_status ON burc_attrition_risk(status);
CREATE INDEX idx_business_cases_stage ON burc_business_cases(stage);
```

---

## Appendix B: Sources & References

- [SaaS KPIs Best Practices - Vena Solutions](https://www.venasolutions.com/blog/saas-kpis-metrics)
- [21 Financial KPIs for SaaS - CloudZero](https://www.cloudzero.com/blog/financial-kpis/)
- [Financial Dashboard Examples - ThoughtSpot](https://www.thoughtspot.com/data-trends/dashboard/financial-kpis-and-metrics-dashboard-examples)
- [SaaS Metrics Guide - Phoenix Strategy Group](https://www.phoenixstrategy.group/blog/ultimate-guide-to-saas-dashboard-metrics)

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2 Jan 2026 | Claude Code | Initial analysis |

**Next Review**: February 2026 (aligned with next BURC cycle)
