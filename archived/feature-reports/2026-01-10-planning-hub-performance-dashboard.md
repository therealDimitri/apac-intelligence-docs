# Feature Report: Planning Hub Performance Dashboard

**Date:** 10 January 2026
**Type:** Feature Enhancement
**Status:** Deployed
**Commit:** 5a80a979

---

## Summary

Enhanced the Planning Hub with a comprehensive CSE/CAM Performance Dashboard that provides real-time visibility into territory performance, pipeline health, and meeting readiness. This implementation is Phase 3 of the APAC CS Planning Hub enhancement project.

---

## New Components

### 1. CSEPerformanceDashboard
**Location:** `src/components/planning/CSEPerformanceDashboard.tsx`

Interactive performance dashboard with:
- Heat map view showing CSE performance across territories
- Colour-coded cards based on achievement percentage
- Target vs Actual comparison with gap analysis
- Health score distribution (healthy/at-risk/critical)
- MEDDPICC scoring overview
- Meeting readiness indicators

### 2. TerritoryView & RegionView
**Locations:**
- `src/components/planning/TerritoryView.tsx`
- `src/components/planning/RegionView.tsx`

Drill-down views for:
- Territory-level aggregations (CSE → Territory)
- Region-level rollups (Territory → Region → BU)
- Performance metrics comparison
- Client health distribution

### 3. MEDDPICCSummary
**Location:** `src/components/planning/MEDDPICCSummary.tsx`

Compact MEDDPICC qualification display:
- Letter grade system (A-F)
- Colour-coded dimensions
- Inline variant for space-constrained views
- Bar chart variant for detailed analysis

### 4. ConversationReadiness & UpcomingMeetingsReadiness
**Locations:**
- `src/components/planning/ConversationReadiness.tsx`
- `src/components/planning/UpcomingMeetingsReadiness.tsx`

Power Messaging preparation tracking:
- 5 dimensions: Value Wedge, Power Position, Pain Articulation, Proof Points, Old Brain
- 6-item preparation checklist
- Meeting type classification (QBR, Renewal, Expansion, Executive, Issue)
- 30-day upcoming meetings dashboard

### 5. BURCAlignmentGauge
**Location:** `src/components/planning/BURCAlignmentGauge.tsx`

Circular SVG gauge component:
- Visual alignment indicator
- Customisable thresholds
- Card variant with details

---

## New Context: PlanningPortfolioContext

**Location:** `src/contexts/PlanningPortfolioContext.tsx`

Consolidated context extending ClientPortfolioContext with:

### Data Provided
- `clients` - Enriched client data with corrected compliance
- `targets` - CSE/CAM quarterly targets
- `opportunities` - Pipeline opportunities with MEDDPICC scores
- `meddpiccScores` - MEDDPICC qualification scores per opportunity
- `readinessScores` - Conversation readiness data per meeting
- `territoryPerformance` - Pre-calculated territory aggregations
- `regionalPerformance` - Pre-calculated region aggregations

### Helper Functions
- `getTargetsForCSE(cseName)` - Get targets for specific CSE
- `getOpportunitiesForClient(clientName)` - Get pipeline for client
- `getFocusDeals()` - Get all focus deals
- `getMEDDPICCForOpportunity(opportunityId)` - Get MEDDPICC score
- `getUpcomingReadiness()` - Get next 30 days meetings with readiness

---

## Database Changes

### New Tables

#### `cse_cam_targets`
Quarterly targets for CSEs and CAMs:
- `weighted_acv_target/actual`
- `acv_net_cogs_target/actual`
- `total_acv_target/actual`
- `tcv_target/actual`

#### `pipeline_opportunities`
Pipeline deals with BURC tracking:
- `opportunity_name`, `client_name`
- `in_target`, `focus_deal`, `rats_and_mice` flags
- `acv`, `tcv`, `weighted_acv` (generated)
- `burc_match`, `burc_source_sheet`

#### `conversation_readiness`
Power Messaging preparation scores:
- Power Messaging dimensions (1-5 scores)
- `overall_readiness` (generated average)
- 6-item preparation checklist
- Links to `unified_meetings`

### New Views

- `cse_performance_summary` - CSE health and client metrics
- `pipeline_by_cse` - Pipeline aggregated by CSE
- `territory_performance` - Territory-level metrics

### Seed Data
- Quarterly targets for FY2026 (Q1-Q4)
- All CSEs: Tracey Bland, John Salisbury, Laura Messing, Open Role
- All CAMs: Anu Pradhan, Nikki Wei

---

## Planning Hub Page Updates

**Location:** `src/app/(dashboard)/planning/page.tsx`

### New "Performance" Tab
Added third tab to the Planning Hub with:
1. CSEPerformanceDashboard integration
2. Territory/Region drill-down capability
3. Upcoming meeting readiness cards

### Context Integration
- Wrapped with `PlanningPortfolioProvider`
- Uses `usePlanningPortfolio()` hook for data
- Transforms `TerritoryPerformance` to `CSEPerformance` format

---

## Territory Mapping

| CSE | Territory | Region |
|-----|-----------|--------|
| Tracey Bland | VIC + NZ | Australia+NZ |
| John Salisbury | WA + VIC | Australia+NZ |
| Laura Messing | SA | Australia+NZ |
| Open Role | Asia + Guam | Asia+Guam |

---

## Next Steps

1. **Phase 2:** BURC Excel import script for pipeline synchronisation
2. **Phase 6:** AI recommendation engine for gap analysis
3. **Integration:** Link MEDDPICC scores from existing `meddpicc_scores` table
4. **Enhancement:** Add conversation readiness entry from Meeting Details page

---

## Related Files

- `src/contexts/ClientPortfolioContext.tsx` - Base context pattern
- `src/components/planning/MEDDPICCScoreCard.tsx` - Full MEDDPICC entry form
- `docs/design/CLIENT-PORTFOLIO-CONTEXT.md` - Context design documentation

---

## Testing

1. **Build Verification:** `npm run build` passes with no TypeScript errors
2. **Database:** Migration applied and verified in Supabase
3. **Manual Testing Required:**
   - Navigate to Planning Hub
   - Click "Performance" tab
   - Verify CSE performance cards display correctly
   - Verify territory/region views work
   - Check loading states
