# Bug Report: Strategic Planning Portfolio Table Formatting

**Date:** 12 January 2026
**Status:** Resolved
**Type:** Bug Fix
**Severity:** Medium

## Summary

Fixed multiple formatting issues in the Strategic Planning Portfolio step:
1. Step 3 (Relationships & Opportunities) prematurely marked as complete
2. Table column headings and data not centred
3. Client name vertical alignment and logo size issues
4. Incorrect column naming (Client Health, Support Health)
5. Segment styling not matching Client Portfolios
6. Summary cards in wrong order
7. Table width not showing all columns
8. Segment badges wrapping to multiple lines ("Sleeping Giant")
9. Table not sorted by Weighted ACV
10. Client column should be left-aligned
11. NPS scores showing stale data instead of calculated aggregates
12. Support Health scores showing stale data instead of latest metrics
13. Health scores showing stale data instead of latest snapshots

## Issues Addressed

### 1. Step 3 Premature Completion

**Reported Behaviour:**
- Step 3 "Relationships & Opportunities" showed a green checkmark immediately after entering step 2
- This occurred because opportunities were pre-selected on load (focus deals, BURC matched)

**Root Cause:**
The `getStepCompletion` function for step 3 only checked if any opportunity had `selected: true`:
```typescript
case 'relationships':
  return formData.plan_type === 'territory'
    ? formData.opportunities.some(o => o.selected)
    : formData.stakeholders.length >= 1
```

**Resolution:**
Added `formData.portfolioConfirmed` as a prerequisite for step 3 completion:
```typescript
case 'relationships':
  // Require portfolio to be confirmed first (step 2) before step 3 can be complete
  return formData.portfolioConfirmed && (formData.plan_type === 'territory'
    ? formData.opportunities.some(o => o.selected)
    : formData.stakeholders.length >= 1)
```

### 2. Table Column Centering

**Reported Behaviour:**
- Column headings were left-aligned
- Data cells were not centred below their headings

**Resolution:**
- Added `text-center` class to all `<th>` elements
- Added `text-center` class to all data `<td>` elements

### 3. Client Name Vertical Alignment and Logo Size

**Reported Behaviour:**
- Client names not vertically centred with logos
- Logo size too large for table rows

**Resolution:**
- Changed `ClientLogoDisplay` size from `sm` to `xs`
- Added `justify-center` to client cell flex container:
```typescript
<div className="flex items-center justify-center gap-2">
  <ClientLogoDisplay clientName={client.name} size="xs" />
  <Link ...>{client.name}</Link>
</div>
```

### 4. Column Naming

**Reported Behaviour:**
- "Client Health" should be "Client Health Score"
- "Support Health" should be "Support Health Score"

**Resolution:**
Renamed columns with concise names:
- "Client Health" → "Health Score"
- "Support Health" → "Support Score"

Also updated tooltip content to be concise:
- "Overall account health (0-100)"
- "Support ticket health (0-100)"

### 5. Segment Styling

**Reported Behaviour:**
- Segment badges not matching Client Portfolios styling
- Missing icons for each segment type

**Resolution:**
Added `SEGMENT_CONFIG` matching Client Portfolios page:
```typescript
const SEGMENT_CONFIG: Record<string, {
  icon: LucideIcon; colour: string; bgColor: string; borderColor: string
}> = {
  Giant: { icon: Crown, colour: 'text-purple-700', bgColor: 'bg-purple-50', borderColor: 'border-purple-200' },
  Collaboration: { icon: Star, colour: 'text-green-700', bgColor: 'bg-green-50', borderColor: 'border-green-200' },
  Leverage: { icon: Zap, colour: 'text-blue-700', bgColor: 'bg-blue-50', borderColor: 'border-blue-200' },
  Maintain: { icon: Shield, colour: 'text-yellow-700', bgColor: 'bg-yellow-50', borderColor: 'border-yellow-200' },
  Nurture: { icon: Sprout, colour: 'text-teal-700', bgColor: 'bg-teal-50', borderColor: 'border-teal-200' },
  'Sleeping Giant': { icon: Moon, colour: 'text-indigo-700', bgColor: 'bg-indigo-50', borderColor: 'border-indigo-200' },
}
```

Updated Segment cell to use `rounded-full` with icons:
```typescript
<span className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-medium ${segConfig.bgColor} ${segConfig.colour} border ${segConfig.borderColor}`}>
  <SegIcon className="h-3 w-3" />
  {client.segment}
</span>
```

### 6. Summary Cards Order

**Reported Behaviour:**
- Cards showed: FY26 Weighted ACV Target, Coverage, Portfolio ARR
- Expected order: FY26 Weighted ACV Target, Portfolio ARR, Coverage

**Resolution:**
Reordered summary cards JSX to match expected order.

### 7. Table Width Not Showing All Columns

**Reported Behaviour:**
- Table columns were being compressed, hiding the Segment column
- Required horizontal scroll but columns were still cut off

**Resolution:**
Added `min-w-max` to table to prevent column compression:
```typescript
<table className="w-full min-w-max text-sm">
```

### 8. Segment Badges Wrapping

**Reported Behaviour:**
- "Sleeping Giant" segment text was wrapping to two lines within the badge

**Resolution:**
Added `whitespace-nowrap` to segment badge spans and `flex-shrink-0` to icons:
```typescript
<span className={`... whitespace-nowrap ...`}>
  <SegIcon className="h-3 w-3 flex-shrink-0" />
  {client.segment}
</span>
```

### 9. Table Sorting

**Reported Behaviour:**
- Table was sorted alphabetically by client name
- Expected: Sort by Weighted ACV descending (highest value first)

**Resolution:**
Added sort before mapping portfolio clients:
```typescript
{[...formData.portfolio]
  .sort((a, b) => b.acvTarget - a.acvTarget)
  .map(client => { ... })}
```

### 10. Client Column Alignment

**Reported Behaviour:**
- Client column was centred like other columns
- Expected: Left-aligned for better readability

**Resolution:**
Changed Client column header and data to use `text-left`:
```typescript
<th className="text-left py-3 px-4 font-medium text-gray-700">
```
Removed `justify-center` from client cell flex container.

### 11. NPS Scores Using Stale Data

**Reported Behaviour:**
- NPS scores were showing stale values from `client_health_summary.nps_score`
- Example: Epworth Healthcare showed +5 when NPS Analytics page showed -100
- Data was not being calculated from actual survey responses

**Root Cause:**
The portfolio loading used `client_health_summary.nps_score` which is a point-in-time snapshot, not the actual calculated aggregate from `nps_responses`.

**Resolution:**
Query `nps_responses` table and calculate NPS aggregates per client:
```typescript
const { data: npsResponses } = await supabase
  .from('nps_responses')
  .select('client_name, score')
  .in('client_name', portfolioClientNames)

// Calculate NPS for each client
// Formula: NPS = ((promoters - detractors) / total) * 100
// Promoters: scores >= 9, Detractors: scores <= 6
```

Override the stale `nps` value with the calculated aggregate in portfolio mapping.

### 12. Support Health Scores Using Stale Data

**Reported Behaviour:**
- Support Health scores showed stale values from `client_health_summary.support_health_score`
- Support Health page showed different (correct) values
- Example: RVEEH showed 96, WA Health showed 94, Barwon Health showed 92

**Root Cause:**
The portfolio loading used cached `support_health_score` from `client_health_summary`, not the latest calculated score from `support_sla_metrics`.

**Resolution:**
Query `support_sla_metrics` table and calculate Support Health scores using the same formula as the Support Health page:
```typescript
const { data: supportMetrics } = await supabase
  .from('support_sla_metrics')
  .select('client_name, resolution_sla_percent, satisfaction_score, aging_31_60d, aging_61_90d, aging_90d_plus, critical_open, period_end')
  .order('period_end', { ascending: false })

// Calculate support health score
// Formula matches api/support-metrics/route.ts:
// - SLA Compliance (40% weight)
// - Satisfaction (30% weight) - convert 1-5 scale to 0-100
// - Aging penalty (20% weight) - 100 - (aging30dPlus * 10)
// - Critical cases penalty (10% weight) - 100 - (critical_open * 25)
```

Override the stale `supportHealthScore` with the calculated value in portfolio mapping.

### 13. Health Scores Using Stale Data

**Reported Behaviour:**
- Health scores showed stale values from `client_health_summary.health_score`
- Historical client health data available but not being used

**Root Cause:**
The portfolio loading used cached `health_score` from `client_health_summary`, not the latest snapshot from `client_health_history`.

**Resolution:**
Query `client_health_history` table and get the latest health score for each client:
```typescript
const { data: healthHistory } = await supabase
  .from('client_health_history')
  .select('client_name, health_score, snapshot_date')
  .order('snapshot_date', { ascending: false })

// Get latest health score for each client (first occurrence after sorting by date desc)
```

Override the stale `healthScore` with the latest value in portfolio mapping.

## Files Modified

### src/app/(dashboard)/planning/strategic/new/page.tsx
- Added imports: `Crown`, `Zap`, `Sprout`, `Moon`, `type LucideIcon`
- Added `SEGMENT_CONFIG` constant with icon mappings
- Updated `getStepCompletion` case 'relationships' to require `portfolioConfirmed`
- Added `text-center` to all table header `<th>` elements (except Client)
- Added `text-center` to all table data `<td>` elements (except Client)
- Changed `ClientLogoDisplay` size from `sm` to `xs`
- Changed Client column to `text-left` alignment
- Renamed "Client Health" → "Health Score"
- Renamed "Support Health" → "Support Score"
- Updated tooltip content to be concise
- Updated Segment cell to use `SEGMENT_CONFIG` with icons and `rounded-full`
- Reordered summary cards: Target, ARR, Coverage
- Added `min-w-max` to table for proper column widths
- Added `whitespace-nowrap` to Segment badges
- Added portfolio sort by Weighted ACV descending
- Added NPS aggregate calculation from `nps_responses` table
- Added Support Health score calculation from `support_sla_metrics` table
- Added Health Score fetching from `client_health_history` table
- Override stale client_health_summary values with latest data from source tables

## Testing Performed

- [x] Build passes with zero TypeScript errors
- [x] Step 3 no longer shows as complete until portfolio is confirmed
- [x] Table columns are centred (headers and data) except Client
- [x] Client column is left-aligned
- [x] Client logos display at correct size with proper alignment
- [x] Health Score and Support Score columns display correctly
- [x] Segment badges show icons matching Client Portfolios
- [x] Segment badges stay on one line (including "Sleeping Giant")
- [x] Summary cards appear in correct order
- [x] Table sorted by Weighted ACV descending
- [x] All columns visible with horizontal scroll
- [x] NPS scores now show calculated aggregates from nps_responses
- [x] Support Health scores now show latest values from support_sla_metrics
- [x] Health scores now show latest values from client_health_history
- [x] Console logging confirms correct NPS, Support Health, and Health Score calculations

## Prevention

1. **Wizard Step Logic**: Always require prerequisite steps before marking later steps complete
2. **UI Consistency**: Use shared config constants (like SEGMENT_CONFIG) across pages
3. **Table Styling**: Follow established patterns for data tables
4. **Table Width**: Use `min-w-max` when tables have many columns
5. **Text Wrapping**: Use `whitespace-nowrap` for badges and short labels
6. **Dynamic Data**: Always fetch latest data from source tables (nps_responses, support_sla_metrics, client_health_history) instead of using cached/summary values
