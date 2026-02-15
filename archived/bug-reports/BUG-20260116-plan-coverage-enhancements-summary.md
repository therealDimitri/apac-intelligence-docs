# Enhancement Report: Plan Coverage Table Comprehensive Improvements

**Date**: 16 January 2026
**Status**: Completed
**Severity**: Enhancement
**Component**: Strategic Planning Wizard - Opportunity Strategy Step

## Overview

A series of UX improvements were made to the Plan Coverage and MEDDPICC tables in the Strategic Planning Wizard to improve data visibility, organisation, and user interaction.

---

## 1. Separate Wtd ACV and Close Date Columns

**Issue**: Combined "Wtd ACV/Close Date" column displayed both values stacked vertically.

**Solution**: Split into two individual columns for clearer data presentation.

| Before | After |
|--------|-------|
| Wtd ACV/Close Date (combined) | Wtd ACV \| Close Date |

---

## 2. Fiscal Quarter Indicator

**Issue**: Close dates lacked fiscal context for planning purposes.

**Solution**: Added Australian fiscal quarter (July-June) to close dates.

```typescript
const getFiscalQuarter = (date: Date): string => {
  const month = date.getMonth() + 1
  if (month >= 7 && month <= 9) return 'Q1'  // Jul-Sep
  if (month >= 10 && month <= 12) return 'Q2' // Oct-Dec
  if (month >= 1 && month <= 3) return 'Q3'   // Jan-Mar
  return 'Q4' // Apr-Jun
}
```

**Display**: `15 Feb Q3`

---

## 3. Forecast Category Badge Colours

**Issue**: All category badges were grey, making it hard to identify opportunity types.

**Solution**: Colour-coded badges based on forecast category.

| Category | Colour | Tailwind Classes |
|----------|--------|------------------|
| Best Case | 🟢 Green | `bg-emerald-100 text-emerald-700` |
| Bus Case | 🔵 Blue | `bg-blue-100 text-blue-700` |
| Pipeline | 🟣 Purple | `bg-purple-100 text-purple-700` |
| Backlog | 🟠 Amber | `bg-amber-100 text-amber-700` |
| Other | ⚪ Grey | `bg-gray-100 text-gray-700` |

Applied to both Plan Coverage and MEDDPICC sections.

---

## 4. Column Alignment Fix

**Issue**: Close Date and Probability columns were not centred properly.

**Solution**: Changed from `flex justify-center` to `text-center` for proper alignment.

---

## 5. Column Sorting

**Issue**: No ability to sort opportunities by different criteria.

**Solution**: Added sortable column headers with visual indicators.

**Sortable Columns**:
- Opportunity (alphabetical)
- Stage (alphabetical)
- Wtd ACV (numeric)
- Close Date (chronological)
- Probability (numeric)

**Sort Behaviour**:
1. First click → Ascending
2. Second click → Descending
3. Third click → Clear sort

**Indicators**:
- `ArrowUpDown` (muted) → Unsorted
- `ArrowUp` → Ascending
- `ArrowDown` → Descending

---

## 6. Probability Dropdown Width

**Issue**: "Medium (40-69%)" text was cut off in the dropdown.

**Solution**: Increased width from 150px to 170px.

```typescript
// Before
className={`w-[150px] ...`}

// After
className={`w-[170px] ...`}
```

---

## Grid Layout Changes

| Column | Before | After |
|--------|--------|-------|
| Opportunity | col-span-5 | col-span-4 |
| Stage/Source | col-span-3 | col-span-2 |
| Wtd ACV | col-span-2 (combined) | col-span-2 |
| Close Date | (combined) | col-span-2 |
| Probability | col-span-2 | col-span-2 |

---

## Data Source Verification

Confirmed parsing of **2026 APAC Performance.xlsx** from SharePoint:
- Path: `https://alteradh.sharepoint.com/teams/APACLeadershipTeam/Shared Documents/General/Performance/Financials/BURC/2026/2026 APAC Performance.xlsx`
- Sheets parsed: `Dial 2 Risk Profile Summary`, `Rats and Mice Only`
- Categories found: Best Case, Bus Case, Pipeline, Backlog, Lost

---

## Testing

- TypeScript compilation: ✅ Passed
- Build compilation: ✅ Passed
- Visual testing: ✅ Verified in browser
- Sorting functionality: ✅ Verified

---

## Related Commits

| Commit | Description |
|--------|-------------|
| `13de95bd` | Separate Wtd ACV and Close Date into individual columns |
| `d3a15159` | Color-code forecast category badges in Plan Coverage |
| `b74a9f6c` | Apply forecast category colour coding to MEDDPICC section |
| `903a394d` | Centre Close Date and Probability columns |
| `8d51a96d` | Add column sorting to Plan Coverage table |

---

## Related Files

- `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`
- `src/app/(dashboard)/planning/strategic/new/page.tsx`
- `src/app/api/pipeline/2026/route.ts`
