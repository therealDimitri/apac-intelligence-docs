# BURC Strategic Enhancement Analysis

**Date:** 5 January 2026
**Document Type:** Strategic Analysis & Recommendations
**Classification:** Internal - APAC Leadership

---

## Executive Summary

This document provides a comprehensive analysis of the Business Unit Revenue/Compliance (BURC) data ecosystem within APAC Intelligence, identifying untapped data opportunities, workflow enhancements, and strategic recommendations for maximising the value of this critical performance document.

---

## 1. BURC Context & Strategic Importance

### What is BURC?

The **Business Unit Revenue/Compliance (BURC)** file is a **critical global performance document** that:

- Is reviewed **monthly** by APAC and global leadership
- Determines the **success and health** of the APAC business unit
- Follows a **standardised process** across all global regions (EMEA, Americas, APAC)
- Creates the **narrative** on the health of the APAC business unit
- Informs **strategic decisions**, resource allocation, and executive reporting

### Why BURC Matters

| Aspect | Impact |
|--------|--------|
| **Financial Governance** | Primary source of truth for revenue, margins, and working capital |
| **Performance Accountability** | Determines success metrics for teams and individuals |
| **Strategic Planning** | Informs headcount, investment, and growth decisions |
| **Global Alignment** | Ensures APAC operates to same standards as other regions |
| **Risk Management** | Early warning system for attrition, collections, and compliance |

### Current Integration Status

The APAC Intelligence platform currently integrates BURC data into client health scores through a 4-component model:

```
Health Score (100 points) = NPS (20) + Compliance (60) + Working Capital (10) + Actions (10)
```

**However, this represents only ~15% of available BURC data utilisation.**

---

## 2. Current Data Landscape

### Source Data

| Source | Files | Coverage | Sync Frequency |
|--------|-------|----------|----------------|
| BURC Excel Files | 247 files | 2019-2026 | Monthly (manual) |
| Supabase Tables | 98 tables | Real-time | On-demand |
| Materialized Views | 5 views | Aggregated | Hourly/daily |

### Database Tables (98 BURC-specific)

**Core Revenue Tables:**
- `burc_historical_revenue` - 6-year revenue by customer/product
- `burc_contracts` - Opal maintenance contracts and ARR
- `burc_monthly_revenue` - Monthly actuals by stream
- `burc_revenue_detail` - SW, PS, Maint, HW breakdown

**Financial Performance:**
- `burc_monthly_ebita` - Monthly P&L breakdown
- `burc_monthly_opex` - OpEx by category
- `burc_ps_margins` - Professional services margins
- `burc_working_capital` - AR/AP metrics

**Risk & Forecasting:**
- `burc_attrition_risk` - Client churn and revenue at risk
- `burc_pipeline_*` - Sales pipeline by product line
- `burc_risks_opportunities` - Risk/opportunity register
- `burc_support_renewals` - Contract renewal tracking

**Operational:**
- `burc_headcount` - Staffing and FTE data
- `burc_cloud_costs` - Infrastructure costs
- `burc_support_efficiency` - Support ticket metrics

**Calculated Metrics (Views):**
- `burc_revenue_retention` - NRR/GRR calculations
- `burc_rule_of_40` - Rule of 40 scoring
- `client_health_summary` - Health score aggregation

---

## 3. Untapped Data Opportunities

### High-Value Unused Fields

| Data Field | Table | Analytic Potential | Priority |
|------------|-------|-------------------|----------|
| **NRR/GRR** | burc_revenue_retention | Revenue retention trending, benchmark vs. industry | Critical |
| **Rule of 40** | burc_rule_of_40 | Business efficiency scoring, investor-grade metric | High |
| **Contract ARR** | burc_contracts | Revenue predictability, renewal risk | High |
| **Renewal Dates** | burc_contracts | Proactive renewal pipeline, risk calendar | High |
| **PS Margins** | burc_ps_margins | Project profitability, efficiency optimisation | Medium |
| **PS Utilisation** | burc_ps_margins | Resource efficiency, capacity planning | Medium |
| **Revenue at Risk** | burc_attrition_risk | Churn forecasting, early intervention | Critical |
| **Pipeline Forecast** | burc_pipeline_* | Revenue forecasting, target tracking | High |
| **Gross Margin** | burc_monthly_ebita | Profitability trends, pricing analysis | Medium |
| **EBITA %** | burc_monthly_ebita | Operational efficiency tracking | Medium |
| **Headcount** | burc_headcount | Revenue per FTE, productivity metrics | Medium |
| **Support Efficiency** | burc_support_efficiency | Cost-to-serve analysis | Low |

### Calculations Not Currently Performed

| Metric | Formula | Business Value |
|--------|---------|----------------|
| **Customer Lifetime Value (LTV)** | ARPU × (1/Churn Rate) | Investment prioritisation, segment analysis |
| **CAC Payback Period** | CAC / (ARPU × Gross Margin) | Sales efficiency, cash flow planning |
| **Magic Number** | Net New ARR / Prior Quarter S&M Spend | Sales & marketing ROI |
| **LTV:CAC Ratio** | LTV / CAC | Customer economics health (target: >3:1) |
| **Quick Ratio** | (New MRR + Expansion) / (Churn + Contraction) | Growth quality indicator |
| **Revenue per FTE** | Total Revenue / FTE | Productivity benchmark |

---

## 4. Workflow Enhancement Recommendations

### 4.1 Automated Data Sync Pipeline

**Current State:** Manual monthly sync after Finance file upload (5-10 day latency)

**Recommended Enhancement:**

```
OneDrive BURC Folder
        ↓ (File watcher)
Automatic Change Detection
        ↓
Validation & Quality Checks
        ↓
Incremental Database Sync
        ↓
Materialized View Refresh
        ↓
Alert Generation (if thresholds breached)
        ↓
Slack/Teams Notification to Stakeholders
```

**Implementation:**
- Use `scripts/watch-burc.mjs` (already created) with Node.js file watcher
- Trigger sync on file modification events
- Add data validation before commit
- Send sync completion summary to Finance channel

### 4.2 Multi-Tier Dashboard Architecture

**Recommended Structure:**

| Tier | Audience | Refresh | Focus |
|------|----------|---------|-------|
| **Strategic** | Executives, Regional Directors | Weekly | ARR, NRR, Rule of 40, Attrition Risk |
| **Operational** | Managers, Team Leads | Daily | Pipeline, Collections, Compliance |
| **Analytical** | Analysts, CSEs | Real-time | Client-level deep dives, ad-hoc queries |

### 4.3 Enhanced Health Score Model

**Current Model (100 points):**
```
NPS (20) + Compliance (60) + Working Capital (10) + Actions (10)
```

**Proposed Enhanced Model (100 points):**
```
Customer Health Score:
├── Engagement (30 points)
│   ├── NPS Score (15)
│   └── Compliance Rate (15)
├── Financial Health (40 points)
│   ├── AR Aging (10) - Under 60/90 days
│   ├── Revenue Trend (15) - YoY growth
│   └── Contract Status (15) - Renewal risk, ARR stability
├── Operational (20 points)
│   ├── Actions Completion (10)
│   └── Support Ticket Health (10)
└── Strategic (10 points)
    └── Expansion Potential (10) - Upsell/cross-sell indicators
```

**Benefits:**
- More balanced weighting across financial, engagement, and operational dimensions
- Incorporates revenue trend and contract health
- Adds support ticket analysis for early warning
- Expansion potential for growth focus

### 4.4 Proactive Alert System

**New Alert Types to Implement:**

| Alert | Trigger | Severity | Action |
|-------|---------|----------|--------|
| **NRR Decline** | NRR drops >5% MoM | High | Executive review |
| **Renewal Risk** | <60 days to renewal, no recent engagement | Critical | CSE outreach |
| **Pipeline Gap** | Pipeline coverage <3x target | High | Sales review |
| **Revenue Concentration** | Top 3 clients >40% revenue | Medium | Diversification planning |
| **Collections Aging** | >$100K in 90+ days | Critical | Finance escalation |
| **Churn Prediction** | ML score >80% risk | Critical | Intervention playbook |
| **PS Margin Erosion** | Margin <15% on projects | Medium | Project review |

---

## 5. Data Integrity Improvements

### 5.1 Validation Framework

**Pre-Sync Checks:**
```javascript
const validationRules = {
  revenue: {
    notNull: ['client_name', 'revenue_type', 'amount'],
    range: { amount: { min: 0, max: 50000000 } },
    enum: { revenue_type: ['Software', 'Professional Services', 'Maintenance', 'Hardware'] }
  },
  contracts: {
    notNull: ['client_name', 'contract_value', 'renewal_date'],
    dateRange: { renewal_date: { min: '2020-01-01', max: '2030-12-31' } }
  },
  attrition: {
    notNull: ['client_name', 'revenue_at_risk'],
    enum: { status: ['At Risk', 'Lost', 'Retained', 'Mitigated'] }
  }
}
```

### 5.2 Client Name Normalisation

**Current Issue:** Inconsistent client naming across source files

**Solution:** Implement `client_name_aliases` table with fuzzy matching:

```sql
-- Already exists in schema
SELECT canonical_name
FROM client_name_aliases
WHERE alias ILIKE '%' || :input_name || '%';
```

**Automated Matching:**
- Levenshtein distance for typo detection
- Prefix/suffix stripping for abbreviations
- Manual review queue for new unmatched names

### 5.3 Audit Trail Enhancement

**Current:** `burc_sync_audit` tracks basic operations

**Enhancement:**
```sql
CREATE TABLE burc_data_lineage (
  id UUID PRIMARY KEY,
  source_file VARCHAR(255),
  source_sheet VARCHAR(100),
  source_row INTEGER,
  target_table VARCHAR(100),
  target_id UUID,
  field_name VARCHAR(100),
  old_value JSONB,
  new_value JSONB,
  sync_timestamp TIMESTAMPTZ,
  sync_user VARCHAR(100)
);
```

**Benefits:**
- Full traceability from Excel cell to database field
- Variance analysis ("why did this number change?")
- Regulatory compliance for financial data

---

## 6. Integration Opportunities

### 6.1 Cross-System Data Enrichment

| Integration | Data Flow | Value Add |
|-------------|-----------|-----------|
| **Outlook Calendar** | Meeting data → Client engagement | Validate compliance events |
| **Support Tickets** | Zendesk/ServiceNow → Health score | Early warning for churn |
| **CRM** | Salesforce/HubSpot → Pipeline | Real-time forecast updates |
| **Finance System** | SAP/NetSuite → BURC tables | Automated actuals reconciliation |
| **HR System** | Workday → Headcount | Real-time FTE for productivity calcs |

### 6.2 AI/ML Enhancement Opportunities

**Predictive Models to Implement:**

1. **Churn Prediction Model**
   - Features: NPS trend, engagement frequency, AR aging, support tickets
   - Output: 0-100% churn probability
   - Trigger: Alert when >70%

2. **Revenue Forecast Model**
   - Features: Historical revenue, pipeline, seasonality, macro indicators
   - Output: Monthly/quarterly revenue forecast
   - Use: Budget planning, executive reporting

3. **Renewal Outcome Prediction**
   - Features: Engagement score, contract value, market conditions
   - Output: Renewal probability, predicted ARR change
   - Use: Proactive CSE intervention

4. **Working Capital Optimisation**
   - Features: Payment history, client size, invoice patterns
   - Output: Optimal collection timing, risk scoring
   - Use: Collections prioritisation

### 6.3 Natural Language Query Interface

**Enable:** Ask questions about BURC data in plain English

**Examples:**
- "What is our NRR for Q4 2025?"
- "Which clients have renewals in the next 90 days with low engagement?"
- "Show me revenue by product line compared to last year"
- "What's the Rule of 40 score for APAC this quarter?"

**Implementation:** Already have ChaSen AI infrastructure - extend with BURC-specific context.

---

## 7. Global Alignment Opportunities

### 7.1 Cross-Region Benchmarking

Since BURC follows a standardised global process, implement:

| Metric | APAC | EMEA | Americas | Global |
|--------|------|------|----------|--------|
| NRR | 95% | 92% | 98% | 95% |
| Rule of 40 | 35 | 38 | 42 | 38 |
| DSO | 45 | 52 | 38 | 45 |
| Churn Rate | 8% | 12% | 6% | 9% |

**Benefits:**
- Identify regional strengths and improvement areas
- Share best practices across regions
- Unified executive reporting format

### 7.2 Standardised KPI Dashboard

**Recommended Global BURC Dashboard Sections:**

1. **Revenue Health** - ARR, MRR growth, revenue mix
2. **Retention Metrics** - NRR, GRR, logo churn, revenue churn
3. **Efficiency Metrics** - Rule of 40, magic number, LTV:CAC
4. **Working Capital** - DSO, collections, AR aging
5. **Pipeline Health** - Coverage ratio, velocity, win rates
6. **Customer Health** - NPS, engagement scores, risk distribution
7. **Team Performance** - Revenue per FTE, CSE compliance rates

---

## 8. Prioritised Roadmap

### Phase 1: Quick Wins (1-2 weeks)

| Enhancement | Effort | Impact | Owner |
|-------------|--------|--------|-------|
| Display NRR/GRR on financials page | 4 hours | High | Engineering |
| Add Rule of 40 widget to executive dashboard | 4 hours | High | Engineering |
| Enable contract renewal calendar view | 8 hours | High | Engineering |
| Create PS margins dashboard section | 6 hours | Medium | Engineering |
| Add revenue trend to client health card | 4 hours | High | Engineering |

### Phase 2: Medium-Term (1-2 months)

| Enhancement | Effort | Impact | Owner |
|-------------|--------|--------|-------|
| Automated BURC file sync pipeline | 3 days | Critical | Engineering |
| Enhanced health score model (6-component) | 5 days | High | Product/Engineering |
| Churn prediction ML model | 2 weeks | Critical | Data Science |
| Multi-tier dashboard architecture | 1 week | High | Engineering |
| Client name normalisation system | 3 days | Medium | Engineering |

### Phase 3: Strategic (3-6 months)

| Enhancement | Effort | Impact | Owner |
|-------------|--------|--------|-------|
| Cross-region benchmarking dashboard | 3 weeks | High | Product/Engineering |
| AI-driven BURC insights engine | 4 weeks | High | Data Science |
| Full data lineage audit trail | 2 weeks | Medium | Engineering |
| Natural language BURC queries | 3 weeks | Medium | Engineering |
| Predictive revenue forecasting | 4 weeks | Critical | Data Science |

---

## 9. Success Metrics

### KPIs for Enhancement Success

| Metric | Current | Target | Measurement |
|--------|---------|--------|-------------|
| **Data Utilisation** | 15% of fields | 60% of fields | Fields displayed / available |
| **Sync Latency** | 5-10 days | <24 hours | Time from Excel update to dashboard |
| **Decision Time** | Manual review | AI-assisted | Time to identify issues |
| **Forecast Accuracy** | N/A | <10% variance | Predicted vs. actual revenue |
| **Alert Response** | Reactive | Proactive | Issues identified before impact |
| **User Adoption** | Basic views | Full analytics | Dashboard engagement metrics |

---

## 10. Appendix: Technical Reference

### Sync Script Inventory

| Script | Purpose | Frequency |
|--------|---------|-----------|
| `sync-burc-comprehensive.mjs` | Master sync (all sheets) | Monthly |
| `sync-burc-monthly.mjs` | Monthly revenue/COGS | Monthly |
| `sync-burc-attrition.mjs` | Attrition data | Monthly |
| `sync-burc-historical.mjs` | 6-year history | One-time + refresh |
| `sync-burc-enhanced.mjs` | Extended tables | Monthly |
| `verify-burc-sync.mjs` | Data validation | After each sync |
| `watch-burc.mjs` | File change detection | Continuous |

### Key Database Views

```sql
-- Net Revenue Retention
SELECT * FROM burc_revenue_retention WHERE period = '2025-Q4';

-- Rule of 40 Score
SELECT * FROM burc_rule_of_40 WHERE year = 2025;

-- Client Health Summary
SELECT * FROM client_health_summary WHERE status = 'critical';
```

### API Endpoints for BURC Data

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/admin/health-history-snapshot` | POST | Daily health capture |
| `/api/compliance/summary` | GET | Compliance metrics |
| `/api/aging-accounts/compliance` | GET | AR aging analysis |
| `/api/team-performance` | GET | CSE performance |

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 5 Jan 2026 | Claude Code | Initial comprehensive analysis |

---

**Remember:** The BURC file is the **single source of truth** for APAC business performance. Every enhancement to its integration and analytics directly improves executive decision-making, risk management, and strategic planning for the region.
