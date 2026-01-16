# Enhancement Report: MEDDPICC Section UI Enhancements

**Date**: 16 January 2026
**Status**: Completed
**Severity**: Enhancement
**Component**: Strategic Planning Wizard - Opportunity Strategy Step

## Issues Addressed

### 1. Step Menu Overlapping Header on Scroll

**Issue**: When scrolling to the bottom of the page, the step menu would overlap with the header due to both having `z-10`.

**Solution**: Increased header z-index from `z-10` to `z-20` in `page.tsx`.

```typescript
// Before
<div className="bg-white border-b border-gray-200 sticky top-0 z-10">

// After
<div className="bg-white border-b border-gray-200 sticky top-0 z-20">
```

---

### 2. MEDDPICC Section Column Layout

**Issue**: MEDDPICC section had different column layout to Plan Coverage:
- Combined ACV/Close Date column
- No sorting functionality
- Different column widths

**Solution**: Applied Plan Coverage column layout to MEDDPICC:

| Column | Before | After |
|--------|--------|-------|
| Opportunity | col-span-5 | col-span-5 |
| Stage/Source | col-span-3 | col-span-2 |
| ACV | col-span-2 (combined) | col-span-1 |
| Close Date | (combined) | col-span-2 |
| Score | col-span-2 | col-span-2 |

---

### 3. MEDDPICC Column Sorting

**Issue**: No ability to sort opportunities in MEDDPICC section.

**Solution**: Added separate sort state and sorting functionality:

```typescript
// Sort state for MEDDPICC table
const [meddpiccSortColumn, setMeddpiccSortColumn] = useState<
  'opportunity' | 'stage' | 'acv' | 'closeDate' | 'score' | null
>(null)
const [meddpiccSortDirection, setMeddpiccSortDirection] = useState<'asc' | 'desc'>('asc')
```

**Sortable Columns**:
- Opportunity (alphabetical)
- Stage (alphabetical)
- ACV (numeric)
- Close Date (chronological)
- Score (numeric)

---

### 4. Left Rail Navigation Labels

**Issue**: Labels were too brief/unclear.

**Solution**: Updated SECTIONS constant:

| Before | After |
|--------|-------|
| Coverage | Plan Coverage |
| MEDDPICC | Opportunity Qualification |
| StoryBrand | StoryBrand Narratives |

---

### 5. StoryBrand Highlight Not Working

**Issue**: When clicking StoryBrand in left rail, it wouldn't highlight because scroll-spy couldn't detect it at the bottom of the page.

**Solution**: Added near-bottom detection to scroll-spy hook:

```typescript
// Check if scrolled to near bottom - if so, highlight the last visible section
const isNearBottom =
  scrollContainer.scrollHeight - scrollContainer.scrollTop - scrollContainer.clientHeight < 100

if (isNearBottom) {
  // Find the last section that exists in the DOM
  for (let i = sectionIds.length - 1; i >= 0; i--) {
    const element = document.getElementById(sectionIds[i])
    if (element) {
      setActiveSection(sectionIds[i])
      return
    }
  }
}
```

---

### 6. Opportunity Alignment Issues

**Issue**: Some opportunities in MEDDPICC section were not left-aligned due to client logos with different sizes.

**Solution**: Added `flex-shrink-0` class to ClientLogoDisplay component:

```typescript
// Before
<ClientLogoDisplay clientName={opp.client_name} size="xs" />

// After
<ClientLogoDisplay clientName={opp.client_name} size="xs" className="flex-shrink-0" />
```

---

## Testing

- TypeScript compilation: ✅ Passed
- Build compilation: ✅ Passed
- Visual testing: ✅ Verified in browser
- Sort functionality: ✅ Verified
- Navigation highlighting: ✅ Verified for all sections

---

## Related Commits

- `8184ca5a`: feat: Enhance MEDDPICC section and fix UI issues

## Related Files

- `src/app/(dashboard)/planning/strategic/new/page.tsx`
- `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`
