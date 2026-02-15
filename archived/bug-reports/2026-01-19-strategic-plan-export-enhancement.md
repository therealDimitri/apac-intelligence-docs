# Enhancement: Comprehensive Strategic Plan Export

**Date:** 2026-01-19
**Status:** Complete
**Severity:** High (missing functionality)
**Component:** Planning Export API

## Issue

Strategic plan exports were producing empty or minimal content because:
1. The export API expected data in formats that didn't match how the wizard stores data
2. V2 methodology data (Gap Selling, Voss techniques, MEDDPICC, StoryBrand) was completely missing from exports
3. No comprehensive Executive/Operational view was available

### Before Enhancement

Export contained:
- Basic header with CSE name and territory
- Empty or minimal portfolio/opportunities/risks tables
- **Zero methodology data** - Gap Selling, Black Swans, MEDDPICC evidence, StoryBrand narratives, Accusation Audit all missing

## Root Cause

1. **Data Format Mismatch**: Export expected `portfolio_data.clients` but wizard stores `portfolio[]`
2. **Missing Types**: `methodology_data` field was not included in `PlanData` interface
3. **No V2 Sections**: Export function had no code to render methodology sections

## Solution Applied

### 1. Enhanced Type Definitions (`src/app/api/planning/export/route.ts`)

Added comprehensive V2 methodology types:
- `GapDiagnosisConfidence` - Gap Selling confidence scores
- `DiscoveryClientAnalysis` - Per-client gap analysis
- `StakeholderBlackSwanAnalysis` - Voss tactical empathy data
- `MEDDPICCDetailedScore` - MEDDPICC with evidence per element
- `StoryBrandNarrative` - Hero/Villain/Guide narrative structure
- `AccusationAuditResponses` - Preemptive objection handling
- `RiskMitigationScore` - Risk mitigation readiness scores
- `TerritoryStoryBrandNarrative` - Overall territory narrative
- `ActionCompletenessScore` - Action plan quality metrics

### 2. Flexible Data Handling

Export now handles both data formats:
```typescript
const portfolioClients = plan.portfolio_data?.clients || plan.portfolio || []
const allOpportunities = plan.opportunities_data || plan.opportunities || []
const allRisks = plan.risks_data || plan.risks || []
const allActions = plan.actions || plan.action_plan_data?.actions || []
```

### 3. Comprehensive PDF Sections Added

New sections in export (500+ lines added):

**Gap Selling Analysis (Discovery & Diagnosis)**
- Client-by-client current problems and future state
- Quantified impact and cost of inaction
- Confidence score summary (X/25)

**Stakeholder Intelligence (Voss Techniques)**
- Stakeholder table with tactical empathy scores
- Black Swan discoveries (career goals, political dynamics, unspoken worries)
- "That's Right" moments
- Calibrated questions to ask

**Opportunity Strategy (MEDDPICC + StoryBrand)**
- Per-opportunity MEDDPICC score breakdown (X/40)
- Individual element scores with evidence
- Health colour coding (green/amber/red)
- StoryBrand narrative (Hero, Villain, Guide, Call to Action)

**Risk & Recovery Analysis**
- Accusation Audit responses
- Tactical Empathy response plan
- Recovery Stories (Wortmann Story Matrix)
- Mitigation score (X/20)

**Action Plan & Territory Narrative**
- Territory StoryBrand overview
- Reference stories to deploy
- Action items table with client attribution
- Completeness score breakdown (X/50)

### 4. Updated Client Export (`src/lib/planning/export-plan.ts`)

- Added `methodology_data` support
- Updated sections array to include new methodology sections
- Maps `methodologyData` to `methodology_data` for backend compatibility

## Export Sections Now Included

| Section | Content |
|---------|---------|
| `summary` | Executive overview, completion status |
| `portfolio` | Client portfolio with health metrics |
| `targets` | Revenue targets and pipeline coverage |
| `opportunities` | Pipeline with MEDDPICC scores |
| `risks` | Risk assessment with mitigation |
| `actions` | Action plan with completeness |
| `discovery` | Gap Selling analysis |
| `stakeholders` | Black Swans & Tactical Empathy |

## Files Changed

- `src/app/api/planning/export/route.ts` - Added 500+ lines for V2 methodology export
- `src/lib/planning/export-plan.ts` - Updated types and sections array

## Methodology Frameworks Supported

1. **Gap Selling** (Keenan) - Current State → Gap → Future State
2. **Never Split the Difference** (Chris Voss) - Tactical Empathy, Black Swans, Calibrated Questions, Accusation Audit
3. **MEDDPICC** - Sales qualification with evidence
4. **Building a StoryBrand** (Donald Miller) - Hero/Villain/Guide narrative
5. **What's Your Story** (Craig Wortmann) - Recovery stories and reference selling

## Impact

Strategic plan exports now provide:
- Comprehensive Account Planning report
- Both Executive summary and Operational detail
- All methodology elements with actual client names
- AI-generated insights and scores
- Actionable intelligence for stakeholder presentations
