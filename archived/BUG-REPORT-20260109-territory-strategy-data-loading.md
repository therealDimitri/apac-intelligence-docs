# Bug Report: Territory Strategy Data Loading and UI Issues

**Date:** 9 January 2026
**Severity:** High
**Status:** Resolved
**Component:** Planning > Territory Strategy > New

## Issue Summary

Multiple issues were identified with the Territory Strategy creation page:
1. Data not being pulled from Supabase (ARR showing $0, NPS/CSI showing N/A)
2. Opportunity fields truncating long text values
3. Pipeline opportunities showing "Unknown Client" instead of actual client names
4. MEDDPICC scoring UI was not intuitive and lacked guidance

## Root Cause Analysis

### Issue 1: ARR/NPS/CSI Not Loading

Two problems were identified:

1. **Wrong table name**: Code was querying `client_health_scores_materialized` but the actual table is `client_health_summary`
2. **Wrong field name**: Code was querying `latest_nps` but the actual field is `nps_score`
3. **Case-sensitive lookups**: When client names didn't match exact casing, the lookup failed silently

**Original Code:**
```typescript
// Direct array.find() with exact string match - case sensitive
const arrRecord = arrData?.find(a => a.client_name === clientName)
const healthRecord = healthData?.find(h => h.client_name === clientName)
```

### Issue 2: Pipeline Deals "Unknown Client"

The `pipeline_deals` table uses different column names than expected:
- Uses `account_name` (not `client_name`)
- Uses `forecast_category` (not `stage`)
- Does not have `acv` or `probability` columns

**Original Code:**
```typescript
client_name: deal.client_name || 'Unknown Client', // Wrong column name
stage: deal.stage || 'Unknown', // Wrong column name
```

### Issue 3: Field Truncation

The opportunity form used a 4-column grid layout which was too narrow for longer field values like "Opportunity Name" and "Client" names.

### Issue 4: MEDDPICC UI/UX

The original MEDDPICC scoring used basic number inputs with single-letter labels, providing no context about what each element means or how to score them.

## Solution Implemented

### Fix 1: Correct Table/Field Names and Case-Insensitive Lookups

1. Changed table from `client_health_scores_materialized` to `client_health_summary`
2. Changed field from `latest_nps` to `nps_score`
3. Created efficient Map-based lookups using lowercase keys for O(1) case-insensitive matching:

```typescript
// Create ARR lookup map (case-insensitive)
const arrMap = new Map<string, number>()
arrData?.forEach(a => {
  if (a.client_name) {
    arrMap.set(a.client_name.toLowerCase(), a.arr_usd || 0)
  }
})

// Create health lookup map (case-insensitive)
const healthMap = new Map<string, { nps: number | null; csi: number | null }>()
healthData?.forEach(h => {
  if (h.client_name) {
    healthMap.set(h.client_name.toLowerCase(), {
      nps: h.latest_nps ?? null,
      csi: h.health_score ?? null,
    })
  }
})

// Usage with case-insensitive lookup
const clientName = client.client_name.toLowerCase()
const arrValue = arrMap.get(clientName) || 0
const healthValues = healthMap.get(clientName)
```

### Fix 2: Correct Pipeline Deals Column Mapping

Updated pipeline deals mapping to use the correct column names:

```typescript
const opportunities: PipelineOpportunity[] = pipelineDeals.map(deal => ({
  id: deal.id,
  opportunity_name: deal.opportunity_name || 'Unnamed Opportunity',
  client_name: deal.account_name || 'Unknown Client', // Correct column
  acv: 0, // Not stored in pipeline_deals table
  weighted_acv: 0,
  close_date: deal.close_date || '',
  stage: deal.forecast_category || 'Unknown', // Correct column
  probability: 0,
}))
```

### Fix 3: Responsive 2-Column Grid Layout

Changed opportunity form from 4-column to 2-column responsive grid:

```typescript
<div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
  {/* Opportunity Name - full width on small, half on medium+ */}
  {/* Client - full width on small, half on medium+ */}
  {/* Close Date */}
  {/* ACV */}
</div>
```

### Fix 4: Enhanced MEDDPICC UI

Completely redesigned MEDDPICC scoring interface:

1. **Full Element Names**: Display complete names (Metrics, Economic Buyer, etc.) instead of single letters
2. **Tooltips**: Added hover definitions explaining what each element measures
3. **Clickable Button Scoring**: Interactive 1-5 buttons for easy scoring
4. **Colour-Coded Scores**: Visual feedback by score level:
   - Red (1-2): Low/At Risk
   - Yellow (3): Medium/Developing
   - Green (4-5): High/Strong
5. **Score Legend**: Clear reference showing what each score level means
6. **Qualification Status Badges**: Visual indicators showing:
   - Strong Champion: Champion score 4+
   - Pain Identified: Identify Pain score 4+
   - Qualified Lead: Total score 30+

## Additional Fix: ARR Data Source and Client Aliases (9 Jan 2026 - Update 2)

### Issue: ARR Showing $0
The `client_arr` table was empty. ARR data is actually stored in the `burc_contracts` table with `annual_value_usd` column.

### Issue: GHA NPS/CSI Missing
The client "GHA" in the assigned clients list didn't match "Gippsland Health Alliance (GHA)" in the health summary table.

### Solution
1. Changed ARR source from `client_arr` to `burc_contracts.annual_value_usd`
2. Implemented client name alias resolution using `client_name_aliases` table
3. Created bidirectional alias mapping (display_name ↔ canonical_name)
4. Added missing alias: "GHA Regional" → "Gippsland Health Alliance (GHA)"
5. Added tooltips to all relevant column headers with definitions

### Column Tooltips Added
- **ARR**: "Annual Recurring Revenue - The yearly contract value from this client in USD"
- **NPS**: "Net Promoter Score (-100 to 100) - Measures customer loyalty"
- **CSI**: "Client Success Index (0-100%) - Composite health score"
- **Segment**: "Client Segment - Strategic categorisation based on ARR, growth potential"
- **Renewal Target**: "Expected revenue from contract renewals"
- **Growth Target**: "New revenue from upsells, cross-sells, and expansion"
- **Confidence**: "Your assessment of achieving this target (High/Medium/Low)"

## Files Modified

- `src/app/(dashboard)/planning/territory/new/page.tsx` - Multiple sections updated

## Testing Recommendations

1. Create a new Territory Strategy
2. Verify ARR values populate correctly for assigned clients
3. Verify NPS/CSI scores display (not N/A) for clients with health data
4. Import pipeline opportunities and verify client names display correctly
5. Add manual opportunities - verify fields don't truncate
6. Test MEDDPICC scoring:
   - Hover over element names for tooltips
   - Click score buttons to verify selection
   - Verify colour coding changes with score levels
   - Check qualification badges update based on scores

## Impact

- **Before:**
  - ARR showing $0 for all clients with data
  - NPS/CSI showing "N/A" even when data exists
  - Pipeline clients showing "Unknown Client"
  - Opportunity fields truncating long values
  - MEDDPICC scoring confusing for users

- **After:**
  - ARR values correctly populated from database
  - NPS/CSI scores display when available
  - Pipeline client names correctly mapped from `account_name`
  - Fields display full values with responsive layout
  - MEDDPICC provides clear guidance and intuitive scoring

## Lessons Learned

1. Always verify exact column names in database schema before querying
2. String comparisons should be case-insensitive when matching user-entered data against database values
3. Use Map for O(1) lookups instead of array.find() for better performance
4. Review actual table schema in migration files or schema docs, not just assumed column names
5. UI/UX for scoring systems should include context and guidance, not just input fields
