# Enhancement Report: Strategic Planning Wizard UI Enhancements v2

**Date**: 16 January 2026
**Status**: Completed
**Severity**: Enhancement
**Component**: Strategic Planning Wizard

## Issues Addressed

### 1. Export API Not Supporting Strategic Plans Table

**Issue**: Export failed with "Plan not found" error because the export API only supported `territory_strategies` and `account_plans` tables, not the `strategic_plans` table used by the new wizard.

**Solution**: Updated `/api/planning/export/route.ts` to:
- Add `'strategic'` plan type support
- Accept inline `planData` parameter to skip DB fetch when data is provided
- Update all export generators (PDF, DOCX, PPTX, XLSX) to handle strategic plan type

**Files Modified**:
- `src/app/api/planning/export/route.ts`
- `src/lib/planning/export-plan.ts`

---

### 2. Header and Stepper Positioning Issues

**Issue**: Step menu was overlapping with header on scroll due to z-index conflicts. Initial attempts with `fixed` positioning caused content cutoff and layout conflicts with the dashboard's scroll container (`<main>` has `overflow-y-auto`).

**Root Cause**: Fixed positioning positions elements relative to the viewport, but the dashboard layout uses a scroll container inside `<main>`. This created a mismatch where fixed elements were positioned at viewport coordinates while content padding was applied relative to the scroll container.

**Solution**: Changed from fixed to sticky positioning which works correctly with the scroll container:
- Header: `sticky top-0 z-30` (removed `fixed left-0 md:left-64 right-0`)
- Stepper: `sticky top-[73px] z-20` (removed `fixed left-0 md:left-64 right-0`)
- Content: Changed from `pt-[136px]` to `pt-6` since sticky elements participate in document flow
- AI Coach sidebar: Updated sticky top from `top-[140px]` to `top-[136px]`
- Footer: Kept as `fixed bottom-0` since it needs to stay at viewport bottom

**Files Modified**:
- `src/app/(dashboard)/planning/strategic/new/page.tsx`

---

### 3. Column Heading Update - ACV to Weighted ACV

**Issue**: ACV column headings in Plan Coverage and MEDDPICC tables didn't clearly indicate the values were weighted.

**Solution**: Changed column heading from "ACV" to "Wtd ACV" in both tables.

**Files Modified**:
- `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`

---

### 4. AI Suggestions Client Name Display

**Issue**: AI Suggestions panel showed only territory (e.g., "for VIC, WA") without the specific client name for context.

**Solution**: Updated RiskRecoveryStep to pass the at-risk client name when risks exist:
```typescript
clientName={
  risks.length > 0
    ? `${risks[0].client}${territory ? ` (${territory})` : ''}`
    : territory || portfolio[0]?.name
}
```

**Files Modified**:
- `src/app/(dashboard)/planning/strategic/new/steps/RiskRecoveryStep.tsx`

---

### 5. Opportunity Count in Section Headings

**Issue**: Plan Coverage and MEDDPICC section headings didn't show the number of opportunities.

**Solution**: Added opportunity count to section titles:
- Plan Coverage: `Plan Coverage (${opportunities.length})`
- MEDDPICC: `Opportunity Qualification (${includedOpportunities.length})`

**Files Modified**:
- `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`

---

### 6. Client Name Dropdown Empty in Add Risk Form

**Issue**: Client dropdown in Add Risk form was empty because it only used parent-level portfolio clients, not client names from pipeline opportunities.

**Solution**: Created `allClients` computed value that combines:
1. Portfolio clients (with ARR and health score)
2. Unique client names from pipeline opportunities

```typescript
const allClients = useMemo(() => {
  const clientMap = new Map()
  portfolio.forEach(c => clientMap.set(c.name, { name: c.name, arr: c.arr, healthScore: c.healthScore }))
  opportunities.forEach(o => {
    if (o.client_name && !clientMap.has(o.client_name)) {
      clientMap.set(o.client_name, { name: o.client_name, arr: o.acv || 0, healthScore: null })
    }
  })
  return Array.from(clientMap.values()).sort((a, b) => a.name.localeCompare(b.name))
}, [portfolio, opportunities])
```

**Files Modified**:
- `src/app/(dashboard)/planning/strategic/new/steps/RiskRecoveryStep.tsx`

---

## Testing

- TypeScript compilation: ✅ Passed
- Build compilation: ✅ Passed
- Visual testing: ✅ Verified

---

## Related Files

- `src/app/api/planning/export/route.ts`
- `src/lib/planning/export-plan.ts`
- `src/app/(dashboard)/planning/strategic/new/page.tsx`
- `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`
- `src/app/(dashboard)/planning/strategic/new/steps/RiskRecoveryStep.tsx`
