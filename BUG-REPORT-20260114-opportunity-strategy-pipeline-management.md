# Bug Report: Opportunity Strategy Page UI/UX Improvements

**Date:** 2026-01-14
**Status:** Fixed
**Priority:** Medium
**Component:** Strategic Planning - Opportunity Strategy Step

---

## Issues Addressed

### 1. Strategy Summary Position
**Problem:** The Strategy Summary card was located at the bottom of the page, making it difficult for users to get an overview of their pipeline health at a glance.

**Solution:** Moved Strategy Summary to the top of the page as the first element users see when entering the step.

**File Changed:** `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`

---

### 2. No Way to Add Pipeline Opportunities
**Problem:** MEDDPICC Qualification section had no option to add more pipeline opportunities, either manually or from existing pipeline data imports.

**Solution:** Added two methods to add opportunities:
1. **Manual Entry Form** - Modal form with fields for opportunity name, client name, ACV, close date, and stage
2. **Import from Pipeline** - Modal that displays available opportunities from the sales pipeline data import, allowing bulk selection and import

**UI/UX Best Practices Applied (based on research from Salesforce, HubSpot, Pipedrive, Linear, Notion):**
- Combobox-style search with type-to-filter
- Bulk select/deselect functionality
- Clear visual distinction between available and already-added opportunities
- Duplicate detection and prevention
- Empty state designs with clear CTAs

---

### 3. Duplicate Opportunity Prevention
**Problem:** No safeguards existed to prevent adding duplicate opportunities.

**Solution:** Implemented duplicate detection:
- Real-time duplicate checking by opportunity name (case-insensitive)
- Visual indicators (amber highlighting) for potential duplicates in import modal
- Disabled checkbox for already-added opportunities
- Alert message when attempting to add manual opportunity that already exists

---

## Technical Changes

### Files Modified

1. **`src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`**
   - Moved Strategy Summary section to top of page
   - Added new props: `availablePipelineOpportunities`, `onAddOpportunity`, `onRemoveOpportunity`, `clientName`
   - Added state for: `showOpportunitySelector`, `showManualForm`, `opportunitySearch`, `viewMode`
   - Added handlers: `handleAddFromList`, `handleAddManualOpportunity`, `handleRemoveOpportunity`, `checkDuplicate`
   - Added helper components: `ManualOpportunityForm`, `OpportunitySelectorModal`
   - Imported new icons: Plus, Search, X, Download, CheckCircle2, Grid3X3, List

2. **`src/components/planning/unified/AIInsightsPanel.tsx`**
   - Added V2 methodology insight types: gap_analysis, current_state, future_state, tactical_empathy, stakeholder_mapping, storybrand, risk_mitigation, action_narrative
   - Added V2 step insight buttons for: discovery, stakeholders, opportunity, risk_recovery, action_narrative
   - Added V2 step hints with methodology-specific guidance

---

## New Component Interfaces

### OpportunityStrategyStepProps (Updated)
```typescript
interface OpportunityStrategyStepProps {
  opportunities: PipelineOpportunity[]
  onUpdateOpportunities: (opportunities: PipelineOpportunity[]) => void

  // NEW: Available pipeline opportunities from CRM import
  availablePipelineOpportunities?: PipelineOpportunity[]
  onAddOpportunity?: (opportunity: PipelineOpportunity) => void
  onRemoveOpportunity?: (opportunityId: string) => void

  portfolio: PortfolioClient[]
  onUpdatePortfolio: (portfolio: PortfolioClient[]) => void
  clientName?: string  // NEW: For pre-filling manual form
  // ... other props
}
```

### ManualOpportunityForm
- Modal form for manual opportunity entry
- Fields: opportunity_name (required), client_name, acv, close_date, stage
- Auto-generates: id, tcv (3x ACV estimate), weighted_acv (50%), probability, meddpicc scores (all 0)

### OpportunitySelectorModal
- Modal for bulk importing opportunities from pipeline
- Features: search/filter, select all/clear, duplicate detection
- Visual indicators: Available (green), Duplicate (amber with warning)

---

## Testing Checklist

- [x] Strategy Summary displays at top of page
- [x] "Add Opportunity" button opens manual form modal
- [x] "Import from Pipeline" button shows available opportunities
- [x] Search filter works in import modal
- [x] Duplicate detection highlights already-added opportunities
- [x] Manual form validates required fields
- [x] Build passes with no TypeScript errors
- [x] Component renders without runtime errors

---

## Related Components

- ChaSen AI Coach now provides step-specific insights for V2 methodology steps
- MEDDPICC Qualification section receives opportunities from the new management UI

---

## Notes

- UI/UX patterns based on research from leading CRM platforms
- Duplicate detection uses case-insensitive name matching
- TCV defaults to 3x ACV for manual entries (standard SaaS assumption)
- Weighted ACV defaults to 50% for manual entries
