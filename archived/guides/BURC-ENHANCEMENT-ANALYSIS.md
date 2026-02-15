# BURC Enhancement Analysis & Recommendations

**Date:** 3 January 2026
**Author:** Claude AI Analysis
**Status:** Active Enhancement Roadmap

---

## Executive Summary

The **Business Unit Revenue & Cost (BURC)** file is a critical performance document that determines the success of the APAC business unit. This is a globally standardised monthly review process used across all Harris Computer regions to create a narrative on business unit health.

This analysis identifies:
- **8 unused data columns** in the current schema
- **15+ data sources** in BURC files not being imported
- **6 enhancement opportunities** for additional analytics layers
- **4 workflow improvements** for ongoing data evolution

---

## Current State Analysis

### Tables in Use

| Table | Records | Purpose | Data Freshness |
|-------|---------|---------|----------------|
| `burc_historical_revenue_detail` | 84,932 | Historical revenue by client/type/year | 2019-2025 |
| `burc_ebita_monthly` | 12 | EBITA performance tracking | Monthly |
| `burc_waterfall` | 13 | Revenue waterfall analysis | Current |
| `burc_quarterly` | 24 | Quarterly revenue by stream | 2026 |
| `burc_client_maintenance` | 25 | Client maintenance revenue | Current |
| `burc_ps_pipeline` | 14 | Professional Services pipeline | Current |
| `burc_revenue_streams` | 7 | Revenue stream breakdown | Current |
| `burc_sync_log` | 95 | Sync audit trail | Ongoing |

### Column Population Analysis

**Well Populated (>90%):**
- `client_name`, `parent_company`, `product`, `revenue_type`
- `fiscal_year`, `fiscal_month`, `amount_aud`, `amount_usd`
- `cogs_aud`, `cogs_usd` (all zeros - not imported)

**Not Populated (<10%) - Enhancement Opportunities:**
- `revenue_category` - Could classify revenue (Recurring vs Non-recurring)
- `calendar_year`, `calendar_month` - Useful for calendar-year reporting
- `cost_centre` - Enable departmental analysis
- `gl_account` - Finance system integration
- `invoice_number` - Transaction-level tracking
- `transaction_date` - Precise timing analysis
- `source_file` - Data lineage tracking

---

## Unused Data in BURC Files

### 2025 APAC Performance.xlsx (41 sheets)

| Sheet Name | Current Status | Enhancement Opportunity |
|------------|----------------|------------------------|
| **Attrition** | ❌ Not imported | Customer churn analysis, at-risk identification |
| **Dial 2 Risk Profile Summary** | ❌ Not imported | Risk scoring for revenue confidence |
| **Support Renewals** | ❌ Not imported | Renewal tracking, timing predictions |
| **OPAL BURC** | ❌ Not imported | OPAL-specific business unit analysis |
| **Headcount Summary** | ❌ Not imported | Revenue per head, utilisation metrics |
| **Revenue by Product** | ❌ Not imported | Product-level performance analysis |
| **Third Party PS COGS Data** | ❌ Not imported | Margin analysis by engagement type |
| **BU Cross Charge to APAC 5%** | ❌ Not imported | Inter-BU revenue allocation |

### 2025 11 Rev and COGS detail.xlsx (9 sheets)

| Sheet Name | Current Status | Enhancement Opportunity |
|------------|----------------|------------------------|
| **APAC COGS** | ❌ Not imported | True gross margin calculation |
| **APAC Support COGS** | ❌ Not imported | Support business profitability |
| **support cogs fcst** | ❌ Not imported | Forecasting vs actuals comparison |

### Critical Supplier List APAC.xlsx

| Data | Current Status | Enhancement Opportunity |
|------|----------------|------------------------|
| **Vendor List** | Partially imported | Full vendor risk analysis, contract expiry alerts |

### MA and PS Plans.xlsx

| Sheet Name | Current Status | Enhancement Opportunity |
|------------|----------------|------------------------|
| **PS Annual Data** | ❌ Not imported | PS resource planning integration |
| **MA** (Maintenance) | ❌ Not imported | Maintenance service planning |

---

## Enhancement Recommendations

### Phase 1: Data Enrichment (High Impact, Low Effort)

#### 1.1 Import COGS Data
**Priority:** Critical
**Impact:** Enables true gross margin analysis

```sql
-- Example: Update existing records with COGS
UPDATE burc_historical_revenue_detail
SET cogs_usd = (
  SELECT cogs FROM burc_cogs_import
  WHERE client_name = burc_historical_revenue_detail.client_name
    AND fiscal_year = burc_historical_revenue_detail.fiscal_year
    AND revenue_type = burc_historical_revenue_detail.revenue_type
);
```

**Dashboard Enhancement:**
- Add "Gross Margin %" column to CLV table
- Add margin trend chart to Historical Analytics
- Colour-code clients by margin health

#### 1.2 Populate Revenue Category
**Priority:** High
**Impact:** Enable recurring vs non-recurring analysis

```typescript
// Auto-classify revenue
const classifyRevenue = (type: string): string => {
  if (type.includes('Maintenance') || type.includes('Support')) return 'Recurring';
  if (type.includes('License')) return 'Non-recurring';
  if (type.includes('Professional Services')) return 'Project-based';
  return 'Other';
};
```

**Dashboard Enhancement:**
- Add ARR (Annual Recurring Revenue) metric
- Show recurring revenue ratio trend
- Highlight clients with low recurring %

### Phase 2: Risk & Forecasting (Medium Effort)

#### 2.1 Import Attrition Data
**Priority:** High
**Impact:** Proactive customer retention

**New Table:**
```sql
CREATE TABLE burc_client_attrition (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name TEXT NOT NULL,
  attrition_risk TEXT, -- 'High', 'Medium', 'Low'
  risk_score NUMERIC,
  risk_factors JSONB, -- {'contract_expiry': '2025-06', 'satisfaction': 3.2}
  last_assessment_date DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Dashboard Enhancement:**
- Add "At Risk Revenue" KPI card
- Integrate with Priority Matrix for CSE action
- Alert system for high-risk clients

#### 2.2 Import Risk Profile Data
**Priority:** High
**Impact:** Revenue confidence scoring

**New Fields:**
- `deal_stage` - Pipeline stage classification
- `probability` - Close probability %
- `weighted_revenue` - probability * amount

**Dashboard Enhancement:**
- "Revenue Confidence" waterfall chart
- Best case / Worst case scenarios
- Pipeline-weighted forecasting

### Phase 3: Operational Intelligence (Higher Effort)

#### 3.1 Headcount & Utilisation
**Priority:** Medium
**Impact:** Resource efficiency analysis

**New Table:**
```sql
CREATE TABLE burc_headcount (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INT,
  fiscal_month INT,
  department TEXT,
  role_category TEXT,
  headcount INT,
  billable_hours NUMERIC,
  utilisation_percent NUMERIC,
  revenue_per_head NUMERIC,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Dashboard Enhancement:**
- Revenue per head trend
- Utilisation by department
- Capacity planning indicators

#### 3.2 Support Renewals Tracking
**Priority:** High
**Impact:** Revenue predictability

**New Table:**
```sql
CREATE TABLE burc_renewals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name TEXT NOT NULL,
  contract_type TEXT,
  current_value NUMERIC,
  renewal_date DATE,
  renewal_probability NUMERIC,
  days_until_renewal INT GENERATED ALWAYS AS (renewal_date - CURRENT_DATE) STORED,
  cse_owner TEXT,
  last_contact_date DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Dashboard Enhancement:**
- "Renewals Due" calendar view
- Renewal pipeline by month
- Integration with CSE workload in Priority Matrix

### Phase 4: Cross-Regional Benchmarking (Future)

#### 4.1 Global BURC Comparison
Since BURC is standardised globally, enable:
- Region-to-region performance comparison
- Best practice identification
- Global trend analysis

**Note:** Requires data sharing agreements with other regions.

---

## Workflow Enhancement Opportunities

### 1. Automated Monthly Sync
**Current:** Manual script execution
**Enhancement:** Scheduled Netlify cron job

```typescript
// netlify/functions/scheduled-burc-sync.ts
export const config = {
  schedule: '@monthly' // Run on 1st of each month
};

export default async () => {
  await syncBURCFromSharePoint();
  await refreshMaterializedViews();
  await sendSlackNotification('BURC sync complete');
};
```

### 2. Data Validation Pipeline
**Current:** No validation
**Enhancement:** Pre-import checks

```typescript
const validateBURCData = (data: BURCRow[]) => {
  const errors = [];

  // Check for required fields
  data.forEach((row, idx) => {
    if (!row.client_name) errors.push(`Row ${idx}: Missing client_name`);
    if (row.amount_usd < 0) errors.push(`Row ${idx}: Negative revenue`);
    if (row.fiscal_year < 2019 || row.fiscal_year > 2030)
      errors.push(`Row ${idx}: Invalid fiscal_year`);
  });

  return errors;
};
```

### 3. Change Detection & Alerting
**Enhancement:** Track month-over-month changes

```typescript
const detectSignificantChanges = async () => {
  const changes = await supabase.rpc('detect_burc_changes', {
    threshold_percent: 10 // Alert if >10% change
  });

  if (changes.length > 0) {
    await sendAlert({
      title: 'BURC Significant Changes Detected',
      changes: changes.map(c => `${c.client}: ${c.change_percent}% change`)
    });
  }
};
```

### 4. ChaSen AI Integration
**Enhancement:** Natural language BURC queries

```typescript
// Add to ChaSen context
const burcContext = {
  totalRevenue2025: '$52M',
  topClients: ['GRMC', 'SA Health', 'SingHealth'],
  growthRate: '+10.6% YoY',
  atRiskRevenue: '$2.1M',
  renewalsDue: 5
};

// Enable queries like:
// "Which clients have declining revenue?"
// "What's our maintenance renewal coverage for Q2?"
// "Compare our PS margin to last year"
```

---

## Implementation Roadmap

| Phase | Enhancement | Effort | Impact | Timeline |
|-------|-------------|--------|--------|----------|
| 1.1 | Import COGS Data | Low | High | Week 1 |
| 1.2 | Revenue Category Classification | Low | Medium | Week 1 |
| 2.1 | Attrition Risk Import | Medium | High | Week 2-3 |
| 2.2 | Risk Profile Integration | Medium | High | Week 2-3 |
| 3.1 | Headcount Analytics | High | Medium | Week 4-5 |
| 3.2 | Renewals Tracking | Medium | High | Week 3-4 |
| 4.0 | Automated Sync Pipeline | Medium | High | Week 6 |

---

## Data Integrity Checklist

Before each monthly BURC update:

- [ ] Verify client name consistency with existing records
- [ ] Check for duplicate entries (same client/month/type)
- [ ] Validate fiscal year/month alignment
- [ ] Confirm currency conversion rates
- [ ] Cross-check totals with source spreadsheet
- [ ] Run `npm run validate-schema` before deploy
- [ ] Update `burc_sync_log` with sync status

---

## Context for AI Assistants

**IMPORTANT:** The BURC (Business Unit Revenue & Cost) file is a critical performance document for the APAC business unit at Altera Health. Key context:

1. **Global Standard:** This process is standardised across all Harris Computer regions
2. **Monthly Cadence:** Reviewed monthly to assess business health
3. **Executive Visibility:** Used for leadership decision-making
4. **Data Sources:** Multiple Excel files from SharePoint
5. **Historical Depth:** 7 years of data (2019-2025)
6. **Revenue ~$50M/year:** APAC region total
7. **~40 Clients:** Mix of healthcare providers across Asia-Pacific
8. **Key Metrics:** Revenue, COGS, Gross Margin, NRR, GRR, CLV, Concentration

When making changes to BURC-related code:
- Always verify against `docs/database-schema.md`
- Consider impact on Historical Analytics page
- Update ChaSen AI context if metrics change
- Document any schema changes in migration files
