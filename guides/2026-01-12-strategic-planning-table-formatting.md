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

## Files Modified

### src/app/(dashboard)/planning/strategic/new/page.tsx
- Added imports: `Crown`, `Zap`, `Sprout`, `Moon`, `type LucideIcon`
- Added `SEGMENT_CONFIG` constant with icon mappings
- Updated `getStepCompletion` case 'relationships' to require `portfolioConfirmed`
- Added `text-center` to all table header `<th>` elements
- Added `text-center` to all table data `<td>` elements
- Changed `ClientLogoDisplay` size from `sm` to `xs`
- Added `justify-center` to client cell container
- Renamed "Client Health" → "Health Score"
- Renamed "Support Health" → "Support Score"
- Updated tooltip content to be concise
- Updated Segment cell to use `SEGMENT_CONFIG` with icons and `rounded-full`
- Reordered summary cards: Target, ARR, Coverage

## Testing Performed

- [x] Build passes with zero TypeScript errors
- [x] Step 3 no longer shows as complete until portfolio is confirmed
- [x] Table columns are centred (headers and data)
- [x] Client logos display at correct size with proper alignment
- [x] Health Score and Support Score columns display correctly
- [x] Segment badges show icons matching Client Portfolios
- [x] Summary cards appear in correct order

## Prevention

1. **Wizard Step Logic**: Always require prerequisite steps before marking later steps complete
2. **UI Consistency**: Use shared config constants (like SEGMENT_CONFIG) across pages
3. **Table Styling**: Follow established patterns for centred data tables
