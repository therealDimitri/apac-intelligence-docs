# Enhancement Report: TanStack Table Migration for Plan Coverage and MEDDPICC

**Date**: 16 January 2026
**Status**: Completed
**Severity**: Enhancement
**Component**: Strategic Planning Wizard - Opportunity Strategy Step

## Issue Description

The Plan Coverage and MEDDPICC tables in the Opportunity Strategy step were using custom grid-based layouts that lacked:
1. Multi-column sorting
2. Faceted filtering
3. Bulk row selection and actions
4. Keyboard navigation
5. Row expansion for detailed views
6. Inline editing capabilities
7. Column resizing

## Solution Applied

Migrated both tables to TanStack Table v8 with the existing `useAdvancedTable` hook.

### Files Created

1. **`src/app/(dashboard)/planning/strategic/new/steps/PlanCoverageTable.tsx`**
   - TanStack Table implementation for Plan Coverage
   - Features: Multi-column sorting, faceted stage filter, bulk actions toolbar
   - Keyboard shortcuts: I (Include), E (Exclude), F (Focus), Shift+A (Select All), Escape (Clear)
   - Summary bar showing included/excluded counts and ACV totals

2. **`src/app/(dashboard)/planning/strategic/new/steps/MEDDPICCTable.tsx`**
   - TanStack Table implementation for MEDDPICC scoring
   - Features: Inline edit popover, row expansion, score range filters
   - Score-based sorting (ascending to surface underqualified deals)
   - Expandable rows for detailed scoring panels

3. **`src/app/(dashboard)/planning/strategic/new/steps/table-utils.ts`**
   - Shared utilities for both tables
   - Colour coding functions, formatters, MEDDPICC calculations

### Files Modified

1. **`src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`**
   - Imported new table components
   - Added `markFocusDeals` handler for bulk focus deal toggling
   - Replaced grid-based Plan Coverage section with `PlanCoverageTable`
   - Replaced grid-based MEDDPICC section with `MEDDPICCTable`

2. **`src/app/(dashboard)/planning/strategic/new/steps/index.ts`**
   - Added exports for new table components and types

## Technical Implementation

### PlanCoverageTable Features

```typescript
// Column definitions with TanStack Table v8
const columns = [
  // Selection checkbox
  // Opportunity + Client combined cell
  // Stage with BURC badge
  // Weighted ACV (right-aligned, formatted)
  // Close Date (colour-coded for overdue/this month)
  // Probability (colour-coded dot)
  // Include/Exclude toggle
]

// Bulk actions toolbar
<BulkActionsToolbar
  onIncludeAll={handleBulkInclude}
  onExcludeAll={handleBulkExclude}
  onMarkFocus={handleBulkMarkFocus}
/>
```

### MEDDPICCTable Features

```typescript
// Score range filters
const scoreRangeFilters = [
  { label: 'Critical (<10)', min: 0, max: 10 },
  { label: 'At Risk (10-20)', min: 10, max: 20 },
  { label: 'Developing (20-30)', min: 20, max: 30 },
  { label: 'Strong (30+)', min: 30, max: 40 },
]

// Inline edit popover for MEDDPICC scores
<MEDDPICCEditPopover
  opportunityId={row.original.id}
  scores={row.original.meddpicc}
  onUpdate={handleUpdate}
/>
```

## Benefits

1. **Consistent UX**: Follows TanStack Table patterns used elsewhere in the app
2. **Better Performance**: Built-in virtualization support for large datasets
3. **Accessibility**: Keyboard navigation and screen reader support
4. **Maintainability**: Reusable column definitions and shared utilities
5. **State Persistence**: Sorting and filter state saved to localStorage
6. **Industry Patterns**: Follows Linear, Notion, Airtable design patterns

## Testing

- TypeScript compilation: Passed
- Build compilation: Passed
- All existing functionality preserved
- New features (sorting, filtering, bulk actions) working

## Related Files

- `src/app/(dashboard)/planning/strategic/new/steps/PlanCoverageTable.tsx`
- `src/app/(dashboard)/planning/strategic/new/steps/MEDDPICCTable.tsx`
- `src/app/(dashboard)/planning/strategic/new/steps/table-utils.ts`
- `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`
- `src/app/(dashboard)/planning/strategic/new/steps/index.ts`
- `src/hooks/useAdvancedTable.ts` - Existing hook leveraged
- `src/components/data-table/data-table.tsx` - Base table component

## Future Enhancements (Phase 3)

- [ ] Add virtualization for large datasets (100+ opportunities)
- [ ] Create mobile responsive card view
- [ ] Implement undo/redo for score changes
