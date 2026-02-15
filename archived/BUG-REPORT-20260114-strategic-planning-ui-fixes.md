# Bug Report: Strategic Planning UI Fixes

**Date:** 2026-01-14
**Status:** Fixed
**Priority:** Medium
**Component:** Strategic Planning Wizard

---

## Issues Fixed

### 1. CAM Suffix Displayed in Collaborator Dropdown

**Problem:** The collaborator dropdown in Step 1 (Setup & Context) displayed "(CAM)" suffix after CAM names (e.g., "Anu Pradhan (CAM)").

**Root Cause:** The `full_name` field in the `cse_profiles` database table stores names with role suffixes for CAMs.

**Solution:** Applied regex replacement to strip "(CAM)" suffix when displaying names in:
- Collaborator dropdown options
- Selected collaborator chips
- Summary section collaborator list

**File Modified:** `src/app/(dashboard)/planning/strategic/new/steps/SetupContextStep.tsx`

**Changes:**
```tsx
// Strip "(CAM)" suffix from display name
const displayName = profile.full_name.replace(/\s*\(CAM\)\s*$/i, '')
```

---

### 2. GAP Discovery Score UI Enhancement

**Problem:** GAP Discovery Confidence section had simple circular 1-5 buttons without visible descriptions for each score level.

**User Request:** Replicate MEDDPICC Qualification UI style which includes a collapsible Score Guide showing what each score means.

**Solution:** Added `ScoreLegend` component to SelfAssessmentScoring module and integrated it into the GAP Discovery Confidence section.

**Files Modified:**
- `src/components/planning/methodology/SelfAssessmentScoring.tsx` - Added ScoreLegend component
- `src/components/planning/methodology/index.ts` - Exported ScoreLegend
- `src/app/(dashboard)/planning/strategic/new/steps/DiscoveryDiagnosisStep.tsx` - Added ScoreLegend to GAP section

**New Component:**
```tsx
export function ScoreLegend({
  isExpanded,
  onToggle,
  customDescriptions,
  className = '',
}: ScoreLegendProps)
```

Features:
- Collapsible Score Guide header with toggle
- 5-column grid showing scores 1-5
- Each score displays: value, label, and description
- Colour-coded backgrounds matching score levels

---

### 3. Missing Voss Methodology Input Sections (Regression)

**Problem:** The Stakeholder Intelligence step (Step 3) showed an Intelligence Summary with counts for Black Swans, Calibrated Questions, and Objections, but had no visible portfolio-level input sections to add these items. This was a regression - the fix was previously applied but was not present in the current codebase.

**Root Cause:** Portfolio-level Voss methodology sections were either never committed or were overwritten during subsequent development.

**Solution:** Re-implemented three new portfolio-level `QuestionnaireSection` components with full functionality:

**File Modified:** `src/app/(dashboard)/planning/strategic/new/steps/StakeholderIntelligenceStep.tsx`

### A. Black Swan Discovery Section
- Collapsible section with explanatory info box
- Textarea for documenting portfolio-wide Black Swans
- Expanded by default for immediate visibility

### B. Calibrated Questions Section
- Collapsible section explaining "How" and "What" questions
- List input for adding calibrated questions
- Counter badge showing total questions added
- Delete functionality per question

### C. Accusation Audit Section
- Collapsible section explaining objection preemption
- List input for adding likely objections
- Counter badge showing total objections listed
- Delete functionality per objection

**State Additions:**
```tsx
const [portfolioBlackSwans, setPortfolioBlackSwans] = useState('')
const [portfolioCalibratedQuestions, setPortfolioCalibratedQuestions] = useState<string[]>([])
const [portfolioObjections, setPortfolioObjections] = useState<string[]>([])
const [expandedSection, setExpandedSection] = useState<string | null>('black-swans')
```

**Intelligence Summary Update:**
Updated counters to aggregate both portfolio-level and per-stakeholder data:
```tsx
// Black Swans: portfolio + stakeholder count
{(portfolioBlackSwans ? 1 : 0) + stakeholders.filter(s => s.blackSwans).length}

// Calibrated Questions: portfolio + stakeholder count
{portfolioCalibratedQuestions.length + stakeholders.reduce((sum, s) => sum + (s.calibratedQuestions?.length || 0), 0)}

// Objections: portfolio + stakeholder count
{portfolioObjections.length + stakeholders.reduce((sum, s) => sum + (s.likelyObjections?.length || 0), 0)}
```

**Helper Components Added:**
- `PortfolioCalibratedQuestionInput` - Input for adding calibrated questions
- `PortfolioObjectionInput` - Input for adding objections

---

## Testing Checklist

- [x] CAM suffix removed from collaborator dropdown
- [x] CAM suffix removed from collaborator chips
- [x] CAM suffix removed from summary section
- [x] Score Legend displays in GAP Discovery Confidence section
- [x] Score Legend is collapsible
- [x] Score descriptions visible for all 5 levels
- [x] Black Swan Discovery section displays and expands
- [x] Textarea accepts input for Black Swan notes
- [x] Calibrated Questions section displays and expands
- [x] Can add calibrated questions to list
- [x] Can remove calibrated questions from list
- [x] Accusation Audit section displays and expands
- [x] Can add objections to list
- [x] Can remove objections from list
- [x] Intelligence Summary counters update correctly (portfolio + stakeholder)
- [x] Build passes with zero TypeScript errors

---

## Prevention Measures

1. **Regression Testing:** Add visual regression tests for Voss methodology sections
2. **Code Review:** Ensure major feature additions are reviewed before merge
3. **Documentation:** This bug report serves as reference for expected functionality

---

## Related Files

- `SetupContextStep.tsx` - Step 1 component
- `DiscoveryDiagnosisStep.tsx` - Step 2 component
- `StakeholderIntelligenceStep.tsx` - Step 3 component
- `SelfAssessmentScoring.tsx` - Scoring UI component
- `QuestionnaireSection.tsx` - Collapsible section component
- `BUG-REPORT-20260114-stakeholder-voss-sections.md` - Previous related bug report
