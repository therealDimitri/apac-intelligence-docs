# Feature Report: Plan Coverage Table with Oracle Quote Detail Data

**Date**: 18 January 2026
**Type**: Feature Enhancement
**Status**: Complete
**Affected Areas**: Strategic Planning wizard - Opportunity Strategy step, Pipeline API

---

## Summary

Enhanced the Plan Coverage table in the Strategic Planning wizard to:
- Display full opportunity names without truncation
- Add Forecast Status and Stage columns from Oracle Quote Detail data
- Include a More Details modal with additional fields (Item Description, GL Product, Business Unit, Quoting Category, Opty Id)
- Redesign table layout to a card-based format for improved readability

---

## Data Source

**Excel File**: APAC 2026 Sales Budget 14Jan2026 v0.1.xlsx
**Sheet**: Oracle Quote Detail
**Key Columns Used**:
| Column | Description |
|--------|-------------|
| Opty Id (col 3) | Oracle Opportunity ID for matching |
| Forecast Status (col 7) | Pipeline, Best Case, etc. |
| Stage (col 8) | Engage, Discover, Prove, Agree |
| Item Description (col 14) | Detailed item description |
| Gl Product (col 15) | GL Product category |
| Business Unit (col 16) | Business unit classification |
| Quoting Category (col 17) | Quote categorisation |

---

## Implementation Details

### 1. Pipeline API - Oracle Quote Detail Parsing
**File**: `src/app/api/pipeline/2026/route.ts`

Added new function to parse Oracle Quote Detail sheet and enrich pipeline opportunities:
```typescript
interface OracleQuoteDetailEntry {
  forecastStatus: string
  stage: string
  itemDescription: string
  glProduct: string
  businessUnit: string
  quotingCategory: string
}

function parseOracleQuoteDetailSheet(workbook: XLSX.WorkBook): Map<string, OracleQuoteDetailEntry>
```

### 2. Type Extensions
**File**: `src/app/(dashboard)/planning/strategic/new/steps/types.ts`

Extended PipelineOpportunity type:
```typescript
export interface PipelineOpportunity {
  // ... existing fields ...
  stage: string               // Sales stage: Engage, Discover, Agree, Prove
  forecast_status: string     // Forecast Status: Pipeline, Best Case
  opty_id?: string
  item_description?: string
  gl_product?: string
  business_unit?: string
  quoting_category?: string
}
```

### 3. UI Redesign - Card-Based Layout
**File**: `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`

Changed from 12-column grid to flexible card layout:
- **Row 1**: Checkbox + Full Opportunity Name + Client Name + Info button
- **Row 2**: Status badges (Forecast Status, Stage) + Metrics (ACV, Wtd, Close Date, Probability)

### 4. More Details Modal
Added modal with:
- Item Description (multi-line text)
- GL Product
- Business Unit
- Quoting Category
- Opty Id

---

## Database Updates

Added columns to `sales_pipeline_opportunities` table:
- `item_description` (text)
- `gl_product` (text)
- `business_unit` (text)
- `quoting_category` (text)

Updated 86 records with Oracle Quote Detail data.

---

## Files Modified

| File | Changes |
|------|---------|
| `src/app/api/pipeline/2026/route.ts` | Oracle Quote Detail parsing, enrichment |
| `src/app/(dashboard)/planning/strategic/new/page.tsx` | Updated type mapping for new fields |
| `src/app/(dashboard)/planning/strategic/new/steps/types.ts` | Extended PipelineOpportunity interface |
| `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx` | Card-based UI, More Details modal |

---

## UI Changes

### Before
- Grid-based table with truncated opportunity names
- Single Status column
- No additional detail view

### After
- Card-based layout with full opportunity names
- Separate Forecast Status and Stage badges
- Info button opens More Details modal
- Improved visual hierarchy with badges

---

## Badge Colour Scheme

### Forecast Status
| Status | Colour |
|--------|--------|
| Pipeline | Grey |
| Best Case | Blue |
| Commit | Green |
| Other | Grey |

### Stage
| Stage | Colour |
|-------|--------|
| Engage | Blue |
| Discover | Yellow |
| Prove | Purple |
| Agree | Green |
| Closed | Grey |

---

## Verification Steps

1. Navigate to Strategic Planning > New Plan
2. Complete Summary step and reach Opportunity Strategy step
3. Verify:
   - Opportunity names display in full (no truncation)
   - Forecast Status badge shows (Pipeline, Best Case, etc.)
   - Stage badge shows (Engage, Discover, Prove, Agree)
   - Clicking Info button opens More Details modal
   - Modal displays Item Description, GL Product, Business Unit, Quoting Category, Opty Id

---

## Related Commits

- `90b53389` - feat: Add Forecast Status, Stage columns and More Details modal to Plan Coverage

---

## Notes

- Data enrichment happens at API level by matching Opty Id from Oracle Quote Detail to pipeline opportunities
- Manual opportunities added via the wizard will default to Forecast Status = "Pipeline"
- Missing data displays as "Not available" in More Details modal
