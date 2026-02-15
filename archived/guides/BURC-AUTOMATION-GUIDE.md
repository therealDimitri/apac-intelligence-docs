# BURC Data Extraction and Automation Guide

**Date**: 16 January 2026
**Author**: System Documentation
**Purpose**: Understanding and automating BURC data extraction from Excel files

## Overview

The BURC (Business Unit Revenue & Cost) data flows from Excel files into the database through a series of sync scripts. This document explains the complete data flow and how to automate BURC matching with Sales Pipeline opportunities.

## Source Files

### 1. BURC Master File (2026 APAC Performance.xlsx)

**Location**:
```
~/Library/CloudStorage/OneDrive-AlteraDigitalHealth/APAC Leadership Team - General/Performance/Financials/BURC/2026/2026 APAC Performance.xlsx
```

**Key Sheets for Pipeline Opportunities**:

| Sheet Name | Purpose | Deal Size |
|------------|---------|-----------|
| Rats and Mice Only | Small deals | < $50k |
| Dial 2 Risk Profile Summary | Larger deals with probability sections | >= $50k |

**Column Structure (both sheets)**:

| Column | Index | Description |
|--------|-------|-------------|
| Opportunity Name | 0 | Full opportunity name with client prefix |
| F/Cast Category | 1 | Backlog, Best Case, Pipeline, etc. |
| Closure Date | 2 | Expected close date (Excel serial) |
| Oracle Agreement # | 3 | Oracle agreement reference |
| SW Rev | 8 | Software revenue |
| PS Rev | 9 | Professional services revenue |
| Maint | 10 | Maintenance revenue |
| HW | 11 | Hardware revenue |
| Bookings ACV | 17 | Annual Contract Value (in millions) |

**Dial 2 Section Markers**:
- **Green:** (90% probability) - High confidence
- **Yellow:** (50% probability) - Medium confidence
- **Red:** (20% probability) - Low confidence
- **Pipeline:** (30% probability) - Early stage

### 2. Sales Budget File

**Location**:
```
~/Library/CloudStorage/OneDrive-AlteraDigitalHealth/Documents/Client Success/Team Docs/Sales Targets/2026/APAC 2026 Sales Budget 6Jan2026.xlsx
```

**Key Sheet**: `APAC Pipeline by Qtr (2)`

**Column Structure** (Header at row 6):

| Column | Index | Description |
|--------|-------|-------------|
| Fiscal Period | 0 | Q1 2026, Q2 2026, etc. |
| Forecast Category | 1 | Omitted, Pipeline, etc. |
| Account Name | 2 | Client/Account name |
| Opportunity Name | 3 | Opportunity description |
| CSE | 4 | Customer Success Engineer |
| CAM | 5 | Customer Account Manager |
| In or Out | 6 | In Target / Out of Target |
| Under 75K | 7 | Yes/No for rats & mice |
| Upside | 8 | Boolean |
| Focus Deal | 9 | Boolean |
| Close Date | 10 | Expected close date |
| Oracle Quote Number | 11 | Oracle reference |
| Total ACV | 12 | Annual Contract Value |
| Oracle Quote Status | 13 | Quote status |
| TCV | 14 | Total Contract Value |
| Weighted ACV | 15 | Probability-weighted ACV |
| ACV Net COGS | 16 | ACV minus cost of goods |
| Bookings Forecast | 17 | Forecasted bookings |

## Database Tables

### 1. `pipeline_opportunities`

Source: BURC Master File (2026 APAC Performance.xlsx)

**Key Columns**:
- `opportunity_name` - Full opportunity name
- `client_name` - Extracted client name
- `acv` - Annual Contract Value
- `close_date` - Expected close date
- `probability` - Win probability (%)
- `burc_source_sheet` - Which BURC sheet (Rats and Mice, Dial 2)

### 2. `sales_pipeline_opportunities`

Source: Sales Budget Excel

**Key Columns**:
- `opportunity_name` - Opportunity description
- `account_name` - Client/Account name
- `cse_name` - Assigned CSE
- `total_acv` - Annual Contract Value
- `weighted_acv` - Probability-weighted ACV
- `in_or_out` - In Target / Out of Target
- `burc_matched` - Boolean: true if matched to BURC
- `burc_pipeline_id` - UUID reference to `pipeline_opportunities.id`
- `burc_match_confidence` - 'exact' or 'fuzzy'

## Sync Scripts

### 1. BURC Pipeline Sync

**Script**: `scripts/sync-burc-pipeline-opportunities.mjs`

**Purpose**: Import pipeline opportunities from BURC Excel into `pipeline_opportunities` table

**Usage**:
```bash
# Preview (no changes)
node scripts/sync-burc-pipeline-opportunities.mjs --dry-run

# Live sync
node scripts/sync-burc-pipeline-opportunities.mjs

# Verbose output
node scripts/sync-burc-pipeline-opportunities.mjs --verbose
```

**What it does**:
1. Reads `2026 APAC Performance.xlsx`
2. Parses "Rats and Mice Only" and "Dial 2 Risk Profile Summary" sheets
3. Extracts client name from opportunity prefix using `CLIENT_PREFIX_MAP`
4. Cross-references with `nps_clients` table for CSE/CAM assignment
5. Inserts/updates `pipeline_opportunities` table

### 2. Sales Budget Pipeline Sync

**Script**: `scripts/sync-sales-budget-pipeline.mjs`

**Purpose**: Import Sales Budget opportunities and cross-reference with BURC

**Usage**:
```bash
# Preview (no changes)
node scripts/sync-sales-budget-pipeline.mjs --dry-run

# Live sync
node scripts/sync-sales-budget-pipeline.mjs

# Verbose output
node scripts/sync-sales-budget-pipeline.mjs --verbose
```

**What it does**:
1. Reads Sales Budget Excel
2. Loads existing BURC pipeline from `pipeline_opportunities`
3. For each Sales Budget opportunity:
   - Attempts **exact match** on opportunity name
   - Falls back to **fuzzy match** using:
     - 70% weight on name similarity (Jaccard)
     - 30% weight on client name similarity
     - +20% bonus if ACV values match within $1,000
   - Requires >70% combined score for match
4. Sets `burc_matched`, `burc_pipeline_id`, `burc_match_confidence`
5. Inserts into `sales_pipeline_opportunities`

## BURC Matching Algorithm

```typescript
function findBurcMatch(opportunity, burcPipeline) {
  // 1. Try exact match on opportunity name
  const exactMatch = burcPipeline.find(b =>
    b.opportunity_name.toLowerCase() === opportunity.opportunity_name.toLowerCase()
  )
  if (exactMatch) return { id: exactMatch.id, confidence: 'exact' }

  // 2. Fuzzy match with combined scoring
  let bestMatch = null
  let bestScore = 0

  for (const burc of burcPipeline) {
    const nameSim = similarity(opportunity.opportunity_name, burc.opportunity_name)
    const clientSim = similarity(opportunity.account_name, burc.client_name)

    // Combined score (name matters more)
    let score = nameSim * 0.7 + clientSim * 0.3

    // ACV matching bonus
    if (Math.abs(opportunity.total_acv - burc.acv) < 1000) {
      score += 0.2
    }

    if (score > bestScore && score > 0.5) {
      bestScore = score
      bestMatch = burc
    }
  }

  if (bestMatch && bestScore > 0.7) {
    return { id: bestMatch.id, confidence: 'fuzzy' }
  }

  return null
}
```

## Client Prefix Mapping

The script uses a prefix map to extract client names from opportunity names:

```javascript
const CLIENT_PREFIX_MAP = {
  'AWH': 'Albury Wodonga Health',
  'SA Health': 'SA Health (iPro)',
  'SAH': 'SA Health (iPro)',
  'WA Health': 'WA Health',
  'WAH': 'WA Health',
  'SingHealth': 'SingHealth',
  'NCS': 'NCS/MinDef Singapore',
  'Parkway': 'Parkway Hospitals Singapore PTE LTD',
  'GHA': 'Gippsland Health Alliance (GHA)',
  'GRMC': 'Guam Regional Medical City (GRMC)',
  'Epworth': 'Epworth Healthcare',
  'Grampians': 'Grampians Health',
  'Barwon': 'Barwon Health Australia',
  'Western Health': 'Western Health',
  'RVEEH': 'Royal Victorian Eye and Ear Hospital',
  'Waikato': 'Te Whatu Ora Waikato',
  'DoH': 'Department of Health - Victoria',
  // ... more mappings
}
```

## Automation Workflow

### Full Sync Process

```bash
# Step 1: Sync BURC pipeline from Excel
node scripts/sync-burc-pipeline-opportunities.mjs

# Step 2: Sync Sales Budget and cross-reference with BURC
node scripts/sync-sales-budget-pipeline.mjs

# Step 3: Verify in database
# Check that opportunities have burc_matched = true
```

### Scheduled Automation (launchd)

The system is set up to run syncs automatically via macOS launchd:

**File**: `scripts/setup-burc-sync.sh`

This creates:
- A plist file at `~/Library/LaunchAgents/com.apac.burc-sync.plist`
- Runs sync automatically when the Excel file is modified (via file watcher)

## UI Integration

### Strategic Planning Wizard

The `OpportunityStrategyStep.tsx` component displays BURC status:

```tsx
{opp.is_burc ? (
  <span className="bg-amber-100 text-amber-700">BURC</span>
) : (
  <span className="bg-red-100 text-red-700">Not In BURC</span>
)}
```

The `is_burc` flag comes from the `burc_matched` column in `sales_pipeline_opportunities`.

## Manual BURC Cross-Reference

For one-off matching (like done for SA Health):

```sql
-- Update specific opportunities as BURC matched
UPDATE sales_pipeline_opportunities
SET burc_matched = true
WHERE opportunity_name ILIKE '%SA Health%25.1%SCM%'
   OR opportunity_name ILIKE '%SA Health%AIMS Integration%';
```

## Troubleshooting

### Common Issues

1. **Excel file not found**
   - Ensure OneDrive is synced
   - Check file path matches expected location

2. **Low match rate**
   - Add missing entries to `CLIENT_PREFIX_MAP`
   - Check for typos in opportunity names
   - Review unmatched opportunities with `--verbose` flag

3. **Date parsing errors**
   - Excel dates can be serial numbers or strings
   - The script handles both formats

### Viewing Match Results

```bash
# Run with verbose to see all matches
node scripts/sync-sales-budget-pipeline.mjs --verbose

# Output shows:
# ✅ Matched opportunities with confidence level
# ❌ Unmatched opportunities (Sales Budget only)
```

## Future Improvements

1. **API-based Excel Import**: Create an API endpoint that accepts Excel file upload
2. **Real-time Sync**: Use file system watchers to trigger sync on file changes
3. **Improved Fuzzy Matching**: Implement Levenshtein distance for better matching
4. **Match Review UI**: Build an admin interface to review and approve fuzzy matches
5. **Audit Trail**: Log all sync operations with before/after values

## Related Files

- `scripts/sync-burc-pipeline-opportunities.mjs` - BURC Excel → `pipeline_opportunities`
- `scripts/sync-sales-budget-pipeline.mjs` - Sales Budget → `sales_pipeline_opportunities`
- `scripts/setup-burc-sync.sh` - launchd automation setup
- `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx` - UI component
- `src/lib/burc-lineage-tracker.ts` - Data lineage tracking for auditing
