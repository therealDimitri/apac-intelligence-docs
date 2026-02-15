# Enhancement Report: Strategic Planning - Territory vs Account Differentiation

**Date:** 12 January 2026
**Status:** Resolved
**Type:** Enhancement
**Severity:** High

## Summary

Implemented comprehensive differentiation between Territory Overview and Account Deep-Dive strategic planning workflows. Previously, both plan types had nearly identical UI with duplicated data. Now each plan type has purpose-built features tailored to their specific use cases.

## Issues Addressed

### 1. Lack of Plan Type Differentiation
**Reported Behaviour:**
- Territory Overview and Account Deep-Dive had identical workflows
- Same data displayed for both plan types
- No unique value proposition for either approach

**Resolution:**
Implemented distinct features for each plan type across all workflow steps.

## Features Implemented (P1-P6)

### P1: Portfolio View Differentiation
**Territory View:**
- Multi-client table with ARR, NPS, Health Score, Segment
- Sortable columns for portfolio analysis
- Pipeline weighted ACV per client

**Account View:**
- Single client comprehensive snapshot
- 8-card metric dashboard:
  - Health Score with trend indicator
  - NPS with distribution breakdown
  - Engagement Score
  - Meeting Activity (90 days)
  - Support Metrics (open tickets, SLA compliance)
  - Contract Details (renewal date, value)
  - Expansion Potential indicator
  - Churn Risk assessment

### P2: Territory Prioritisation Matrix
**Territory Only:**
- 4-quadrant client prioritisation grid
- Axes: Health Score (X) vs ARR (Y)
- Quadrants:
  - **Protect & Grow** (Green): High Health, High ARR
  - **Maintain** (Amber): Low Health, High ARR
  - **Develop** (Blue): High Health, Low ARR
  - **Evaluate** (Gray): Low Health, Low ARR
- Interactive client positioning with visual indicators
- Strategic action guidance per quadrant

### P3: Power-Interest Stakeholder Grid
**Account Only:**
- Drag-and-drop stakeholder positioning
- 4-quadrant grid:
  - **Manage Closely**: High Power, High Interest (Key Players)
  - **Keep Satisfied**: High Power, Low Interest (Keep Informed)
  - **Keep Informed**: Low Power, High Interest (Show Consideration)
  - **Monitor**: Low Power, Low Interest (Minimal Effort)
- Stakeholder cards with name, title, role indicators
- Colour-coded quadrants for visual clarity
- HTML5 Drag API for intuitive repositioning

### P4: MEDDPICC Stage-Gating & Deal Health
**All Opportunities:**
- 8-segment compact MEDDPICC bar visualisation
- Colour-coded elements (M, E, D1, D2, P, I, C1, C2)
- Opacity indicates score strength (0-5 scale)
- Hover tooltips showing element scores

**Deal Health Traffic Light:**
- Green (28+): Healthy deal
- Amber (16-27): At Risk
- Red (<16): Critical

**Stage-Gate Validation:**
Warns when MEDDPICC scores don't meet stage requirements:
- Discovery: Identify Pain (I) ≥ 2
- Qualification: Metrics (M), Champion (C1) ≥ 3
- Proposal: Economic Buyer (E), Decision Criteria (D1) ≥ 3
- Negotiation: Decision Process (D2), Paper Process (P) ≥ 4
- Commit: All elements ≥ 3, Total ≥ 28

### P5: Value Wedge & Conversation Readiness
**Account Only:**

**Value Wedge Framework (Erik Peterson methodology):**
- Unique Capabilities: What only we can do
- Customer Importance: How critical to their success
- Competitive Comparison: How competitors fall short
- Defensibility: Why this can't be replicated

**Unconsidered Needs Section:**
- Hidden Pain Points
- Cost of Inaction

**Conversation Readiness Checklist:**
- Value proposition articulated
- Competitor weaknesses mapped
- Champion talking points ready
- Proof points prepared
- Objection handling ready
- Next steps planned

### P6: Owner & Collaborator Defaults
- CSE owns both Territory and Account plans
- Owner dropdown only shows CSE roles
- CAMs automatically added as collaborators when Account Deep-Dive selected
- Clear guidance: "CSEs own strategic plans. Add CAMs as collaborators"

## Files Modified

### strategic/new/page.tsx
- Added MEDDPICC stage-gating constants and helper functions
- Extended `PortfolioClient` interface with Account-specific metrics
- Extended `Stakeholder` interface with `powerInterest` field
- Modified `handlePlanTypeChange` to auto-add CAM as collaborator
- Added Territory Prioritisation Matrix (4-quadrant grid)
- Added Account Deep-Dive comprehensive snapshot cards
- Added Power-Interest Grid with drag-drop functionality
- Added MEDDPICC compact bar and deal health indicators
- Added Value Wedge & Conversation Readiness section
- Added stage-gate validation warnings

## Technical Details

### MEDDPICC Element Colours
```typescript
const MEDDPICC_ELEMENT_COLOURS = {
  m: 'bg-blue-500',    // Metrics
  e: 'bg-purple-500',  // Economic Buyer
  d1: 'bg-indigo-500', // Decision Criteria
  d2: 'bg-violet-500', // Decision Process
  p: 'bg-pink-500',    // Paper Process
  i: 'bg-amber-500',   // Identify Pain
  c1: 'bg-green-500',  // Champion
  c2: 'bg-red-500',    // Competition
}
```

### Stage Gate Requirements
```typescript
const MEDDPICC_STAGE_REQUIREMENTS = {
  'Discovery': { required: ['i'], minScore: 2 },
  'Qualification': { required: ['m', 'c1'], minScore: 3 },
  'Proposal': { required: ['e', 'd1'], minScore: 3 },
  'Negotiation': { required: ['d2', 'p'], minScore: 4 },
  'Commit': { required: [...all], minScore: 3, totalMin: 28 },
}
```

## Testing Performed

- [x] Build passes with zero TypeScript errors
- [x] Territory view shows multi-client table
- [x] Account view shows single client deep snapshot
- [x] Territory Prioritisation Matrix displays correctly
- [x] Power-Interest Grid drag-drop works
- [x] MEDDPICC bar and deal health indicators display
- [x] Stage-gate warnings appear appropriately
- [x] Value Wedge section renders for Account only
- [x] CAM auto-added as collaborator for Account plans
- [x] Owner dropdown shows CSE-only options

## Research Sources

- MEDDPICC Framework (meddicc.com)
- "Conversations That Win the Complex Sale" by Erik Peterson
- DemandFarm Stakeholder Mapping
- Creately Power-Interest Grid
- Anaplan Territory Planning Best Practices

## Prevention

- Plan type differentiation should be established early in design
- Each plan type should have documented unique features
- UX research should validate distinct use cases before implementation
