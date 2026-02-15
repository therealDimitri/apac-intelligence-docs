# CSI Ratios Analysis & Implementation Guide

## Overview

Harris/CSI Operating Ratios are key financial metrics used to measure business unit efficiency. This document analyses what data is required to calculate these ratios real-time in the dashboard.

---

## Current Status: ✅ IMPLEMENTED

**August 2025 CSI Ratios (from BURC data):**

| Ratio | Value | Target | Status |
|-------|-------|--------|--------|
| PS Ratio | 1.54 | ≥ 2.0 | 🔴 Below |
| Sales Ratio | 2.32 | ≥ 1.0 | 🟢 Met |
| Maintenance Ratio | 5.37 | ≥ 4.0 | 🟢 Met |
| R&D Ratio | 0.39 | ≥ 1.0 | 🔴 Below |
| G&A Ratio | 15.2% | ≤ 20% | 🟢 Met |

**EBITA:** $645,431 (28.1% of Net Revenue)

---

## CSI Ratio Formulas

### 1. PS (Professional Services) Ratio ≥ 2
```
PS Ratio = Net Professional Services Revenue / Professional Services OPEX
```
**Target:** ≥ 2.0 (every $1 of PS OPEX should generate $2+ of PS Revenue)

### 2. Sales Ratio ≥ 1
```
Sales Ratio = (70% × Net License Revenue) / S&M OPEX
```
**Target:** ≥ 1.0 (70% of license revenue should cover sales costs)

### 3. Maintenance Ratio ≥ 4
```
Maintenance Ratio = (85% × Net Maintenance Revenue) / Maintenance OPEX
```
**Target:** ≥ 4.0 (maintenance should be highly profitable)

### 4. R&D Ratio ≥ 1
```
R&D Ratio = (30% × Net License Revenue + 15% × Net Maintenance Revenue) / R&D OPEX
```
**Target:** ≥ 1.0 (product investment should be funded by revenue)

### 5. G&A Ratio ≤ 20%
```
G&A Ratio = Total G&A OPEX / Total Net Revenue × 100
```
**Target:** ≤ 20% (overhead should be minimal)

---

## Current Data Availability

### ✅ Available - Revenue Data

| Data Point | Table | Column(s) | Notes |
|------------|-------|-----------|-------|
| License Revenue | `burc_revenue_streams` | `annual_total` where `stream = 'License'` | Quarterly breakdown available |
| Professional Services Revenue | `burc_revenue_streams` | `annual_total` where `stream = 'Professional Services'` | Also in `burc_ps_pipeline` |
| Maintenance Revenue | `burc_revenue_streams` | `annual_total` where `stream = 'Maintenance'` | Also in `burc_client_maintenance` |
| Hardware Revenue | `burc_revenue_streams` | `annual_total` where `stream = 'Hardware'` | Minor stream |
| Gross Revenue | `burc_revenue_streams` | `annual_total` where `stream = 'Gross Revenue'` | Total |

**Current Revenue Values (FY2026):**
- License: ~$2.7M
- Professional Services: ~$10M
- Maintenance: ~$19M
- Hardware: ~$45K
- Total Gross Revenue: ~$32M

### ⚠️ Partially Available - Cost Data

| Data Point | Table | Column(s) | Notes |
|------------|-------|-----------|-------|
| Total COGS | `burc_waterfall` | `amount` where `category = 'forecast_cogs'` | Aggregated only |
| Total OPEX | `burc_waterfall` | `amount` where `category = 'forecast_opex'` | **Not broken down by category** |
| Target EBITA | `burc_waterfall` | `amount` where `category = 'target_ebita'` | Available |

### ❌ Missing - OPEX Breakdown

The following OPEX categories are **NOT currently captured** in BURC data:

| Required OPEX Category | Used In Ratio | Status |
|------------------------|---------------|--------|
| Professional Services OPEX | PS Ratio | ❌ Missing |
| Sales & Marketing OPEX | Sales Ratio | ❌ Missing |
| Maintenance OPEX | Maintenance Ratio | ❌ Missing |
| R&D OPEX | R&D Ratio | ❌ Missing |
| General & Administrative OPEX | G&A Ratio | ❌ Missing |

---

## Data Gap Analysis

### What We Can Calculate Now

With current data, we can only calculate **partial ratios** or **estimates**:

```javascript
// Example: Estimate G&A if we assume allocation percentages
const totalOpex = waterfallData.forecast_opex  // Available
const totalRevenue = waterfallData.committed_gross_rev  // Available

// This gives us total OPEX as % of revenue (rough G&A proxy)
const opexRatio = (totalOpex / totalRevenue) * 100
```

### What We Need to Add

To calculate real CSI Ratios, we need **OPEX breakdown by category**. This data typically comes from:

1. **General Ledger / ERP System** - Detailed expense categories
2. **HR/Payroll System** - Headcount costs by department
3. **Department Budgets** - Allocated expenses

---

## Recommended Implementation

### Phase 1: Add OPEX Tracking Table

Create a new table to store monthly OPEX by category:

```sql
CREATE TABLE burc_opex_breakdown (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  year INTEGER NOT NULL,
  month_num INTEGER NOT NULL,
  month TEXT NOT NULL,

  -- OPEX Categories
  ps_opex DECIMAL(15,2),           -- Professional Services
  sm_opex DECIMAL(15,2),           -- Sales & Marketing
  maintenance_opex DECIMAL(15,2),   -- Maintenance/Support
  rd_opex DECIMAL(15,2),           -- R&D
  ga_opex DECIMAL(15,2),           -- General & Administrative
  other_opex DECIMAL(15,2),        -- Other/Unallocated

  total_opex DECIMAL(15,2) GENERATED ALWAYS AS (
    COALESCE(ps_opex, 0) +
    COALESCE(sm_opex, 0) +
    COALESCE(maintenance_opex, 0) +
    COALESCE(rd_opex, 0) +
    COALESCE(ga_opex, 0) +
    COALESCE(other_opex, 0)
  ) STORED,

  notes TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(year, month_num)
);
```

### Phase 2: Extend BURC Excel Extraction

Add a new sheet to "2026 APAC Performance.xlsx" called "OPEX Breakdown" with:

| Month | PS OPEX | S&M OPEX | Maint OPEX | R&D OPEX | G&A OPEX |
|-------|---------|----------|------------|----------|----------|
| Jan   | $xxx    | $xxx     | $xxx       | $xxx     | $xxx     |
| Feb   | $xxx    | $xxx     | $xxx       | $xxx     | $xxx     |
| ...   | ...     | ...      | ...        | ...      | ...      |

Then update `sync-burc-data.mjs` to extract this data.

### Phase 3: CSI Ratios API Endpoint

Create `/api/analytics/burc/csi-ratios`:

```typescript
// src/app/api/analytics/burc/csi-ratios/route.ts

interface CSIRatios {
  ps: { ratio: number; target: 2; status: 'green' | 'amber' | 'red' }
  sales: { ratio: number; target: 1; status: 'green' | 'amber' | 'red' }
  maintenance: { ratio: number; target: 4; status: 'green' | 'amber' | 'red' }
  rd: { ratio: number; target: 1; status: 'green' | 'amber' | 'red' }
  ga: { ratio: number; target: 20; status: 'green' | 'amber' | 'red' }
}

export async function GET() {
  // Fetch revenue data
  const { data: revenueData } = await supabase
    .from('burc_revenue_streams')
    .select('stream, annual_total')

  // Fetch OPEX breakdown
  const { data: opexData } = await supabase
    .from('burc_opex_breakdown')
    .select('*')
    .eq('year', 2026)

  // Calculate ratios
  const license = revenueData.find(r => r.stream === 'License')?.annual_total || 0
  const ps = revenueData.find(r => r.stream === 'Professional Services')?.annual_total || 0
  const maintenance = revenueData.find(r => r.stream === 'Maintenance')?.annual_total || 0
  const totalRevenue = revenueData.find(r => r.stream === 'Gross Revenue')?.annual_total || 0

  const ytdOpex = opexData.reduce((acc, m) => ({
    ps: acc.ps + (m.ps_opex || 0),
    sm: acc.sm + (m.sm_opex || 0),
    maintenance: acc.maintenance + (m.maintenance_opex || 0),
    rd: acc.rd + (m.rd_opex || 0),
    ga: acc.ga + (m.ga_opex || 0),
  }), { ps: 0, sm: 0, maintenance: 0, rd: 0, ga: 0 })

  // Calculate CSI Ratios
  const psRatio = ytdOpex.ps > 0 ? ps / ytdOpex.ps : 0
  const salesRatio = ytdOpex.sm > 0 ? (0.70 * license) / ytdOpex.sm : 0
  const maintRatio = ytdOpex.maintenance > 0 ? (0.85 * maintenance) / ytdOpex.maintenance : 0
  const rdRatio = ytdOpex.rd > 0 ? (0.30 * license + 0.15 * maintenance) / ytdOpex.rd : 0
  const gaRatio = totalRevenue > 0 ? (ytdOpex.ga / totalRevenue) * 100 : 0

  return NextResponse.json({
    ratios: {
      ps: { ratio: psRatio, target: 2, status: getStatus(psRatio, 2, 'gte') },
      sales: { ratio: salesRatio, target: 1, status: getStatus(salesRatio, 1, 'gte') },
      maintenance: { ratio: maintRatio, target: 4, status: getStatus(maintRatio, 4, 'gte') },
      rd: { ratio: rdRatio, target: 1, status: getStatus(rdRatio, 1, 'gte') },
      ga: { ratio: gaRatio, target: 20, status: getStatus(gaRatio, 20, 'lte') },
    },
    inputs: { license, ps, maintenance, totalRevenue, opex: ytdOpex },
    timestamp: new Date().toISOString(),
  })
}

function getStatus(value: number, target: number, comparison: 'gte' | 'lte'): string {
  if (comparison === 'gte') {
    if (value >= target) return 'green'
    if (value >= target * 0.8) return 'amber'
    return 'red'
  } else {
    if (value <= target) return 'green'
    if (value <= target * 1.2) return 'amber'
    return 'red'
  }
}
```

### Phase 4: Dashboard Component

Add CSI Ratios card to financials dashboard:

```tsx
// CSI Ratios Display Component
function CSIRatiosCard({ ratios }) {
  return (
    <div className="bg-white rounded-lg border p-6">
      <h3 className="font-semibold text-lg mb-4">CSI Operating Ratios</h3>

      <div className="space-y-3">
        <RatioRow
          label="PS Ratio"
          value={ratios.ps.ratio}
          target="≥ 2.0"
          status={ratios.ps.status}
        />
        <RatioRow
          label="Sales Ratio"
          value={ratios.sales.ratio}
          target="≥ 1.0"
          status={ratios.sales.status}
        />
        <RatioRow
          label="Maintenance Ratio"
          value={ratios.maintenance.ratio}
          target="≥ 4.0"
          status={ratios.maintenance.status}
        />
        <RatioRow
          label="R&D Ratio"
          value={ratios.rd.ratio}
          target="≥ 1.0"
          status={ratios.rd.status}
        />
        <RatioRow
          label="G&A Ratio"
          value={`${ratios.ga.ratio.toFixed(1)}%`}
          target="≤ 20%"
          status={ratios.ga.status}
        />
      </div>
    </div>
  )
}
```

---

## Alternative: Manual Entry Mode

If OPEX data isn't available from Excel, create a manual entry interface:

1. **Admin Settings Page** - `/settings/csi-ratios`
2. **Monthly OPEX Entry Form** - Allow finance team to input OPEX breakdown
3. **Historical Import** - Bulk upload past months' data

---

## Summary

### Current State
- ✅ Revenue data is fully available
- ⚠️ Total OPEX available but not broken down
- ❌ Cannot calculate real CSI Ratios without OPEX categories

### Required Actions
1. **Data Source**: Obtain OPEX breakdown from finance/GL system
2. **Database**: Create `burc_opex_breakdown` table
3. **Sync Script**: Update to extract OPEX categories from Excel
4. **API**: Create `/api/analytics/burc/csi-ratios` endpoint
5. **UI**: Add CSI Ratios card to financials dashboard

### Timeline Estimate
- Phase 1 (Database + Migration): 1 day
- Phase 2 (Excel + Sync Script): 1-2 days (depends on data availability)
- Phase 3 (API Endpoint): Half day
- Phase 4 (Dashboard UI): Half day

**Total: 3-4 days** once OPEX breakdown data is available.

---

---

## How to Sync CSI Data

### Python Sync Script

The data is extracted from BURC Excel files (.xlsb format) using Python:

```bash
# Sync August 2025 data (default)
python3 scripts/sync-csi-ratios.py

# Sync specific month
python3 scripts/sync-csi-ratios.py --year 2025 --month 8

# Sync from custom file
python3 scripts/sync-csi-ratios.py --file /path/to/burc.xlsb --year 2025 --month 9
```

### API Endpoint

```
GET /api/analytics/burc/csi-ratios
```

Query parameters:
- `year` - Fiscal year (default: latest available)
- `month` - Month number (default: latest available)

Response:
```json
{
  "ratios": {
    "ps": { "value": 1.54, "target": 2, "status": "red", "formula": "..." },
    "sales": { "value": 2.32, "target": 1, "status": "green", "formula": "..." },
    "maintenance": { "value": 5.37, "target": 4, "status": "green", "formula": "..." },
    "rd": { "value": 0.39, "target": 1, "status": "red", "formula": "..." },
    "ga": { "value": 15.2, "target": 20, "status": "green", "formula": "..." }
  },
  "period": { "year": 2025, "month": 8 },
  "underlying": {
    "revenue": { "license": 297957.89, "ps": 643775.99, "maintenance": 1357046.34 },
    "opex": { "ps": 418436.98, "sm": -89767.44, "maintenance": 214758.16, "rd": 758893.49, "ga": 349452.83 }
  }
}
```

---

## Database Tables

### `burc_csi_opex`
Stores monthly OPEX breakdown by category.

### `burc_csi_ratios`
Stores calculated CSI ratios with status indicators.

---

## BURC File Structure

Data is extracted from the **APAC** sheet:

| Row | Data Point |
|-----|------------|
| 50 | License Net Revenue |
| 54 | PS Net Revenue |
| 60 | Maintenance Net Revenue |
| 67 | Total Net Revenue |
| 97 | PS OPEX |
| 126 | Maintenance OPEX |
| 155 | S&M OPEX |
| 184 | R&D OPEX |
| 213 | G&A OPEX |
| 244 | Total OPEX |
| 246 | EBITA |

---

## Questions for Finance Team

Before implementation, clarify:

1. ~~**Is OPEX breakdown available in a structured format?**~~ ✅ Yes, in BURC file
2. **What is the current allocation methodology?** (Direct cost centres, % allocation, etc.)
3. **How frequently is OPEX data updated?** Monthly - need to add more BURC files
4. **Are there any inter-company allocations** that need consideration?
5. **Should ratios be calculated YTD or trailing 12-month?**
