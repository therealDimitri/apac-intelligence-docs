# Bug Report: Missing Page-Level Voss Methodology Input Sections

**Date:** 2026-01-14
**Status:** Fixed
**Priority:** High
**Component:** Strategic Planning - Stakeholder Intelligence Step

---

## Issue Description

**Problem:** The Stakeholder Intelligence step showed an Intelligence Summary with counts for Black Swans, Calibrated Questions, and Objections Listed, but there were no visible input sections to add these items. The existing inputs were nested inside individual stakeholder cards and only visible when a stakeholder was added and expanded.

**User Report:** "There are no input sections for Black Swans, Calibrated Questions, Objections Listed."

---

## Root Cause Analysis

The Black Swans, Calibrated Questions, and Objections inputs existed in the codebase but were:
1. Nested inside individual `QuestionnaireSection` components per stakeholder
2. Only visible when a stakeholder was added (Economic Buyer, Champion, or Blocker)
3. Only accessible when the stakeholder card was expanded

This design meant users couldn't add portfolio-level Voss methodology data without first adding stakeholders.

---

## Solution Implemented

Added three new page-level `QuestionnaireSection` components for portfolio-wide Voss methodology inputs:

### 1. Black Swan Discovery Section
- Collapsible section with explanatory content
- Textarea for documenting potential Black Swans
- Expanded by default for immediate visibility

### 2. Calibrated Questions Section
- Collapsible section explaining "How" and "What" questions
- List input for adding calibrated questions
- Counter showing total questions added

### 3. Accusation Audit Section
- Collapsible section explaining objection preemption
- List input for adding likely objections
- Counter showing total objections listed

---

## Technical Changes

### File Modified
**`src/app/(dashboard)/planning/strategic/new/steps/StakeholderIntelligenceStep.tsx`**

### State Additions (Lines 189-193)
```tsx
// Portfolio-level Voss methodology inputs
const [portfolioBlackSwans, setPortfolioBlackSwans] = useState('')
const [portfolioCalibratedQuestions, setPortfolioCalibratedQuestions] = useState<string[]>([])
const [portfolioObjections, setPortfolioObjections] = useState<string[]>([])
const [expandedSection, setExpandedSection] = useState<string | null>('black-swans')
```

### Intelligence Summary Update (Lines 362-376)
Updated counters to include both portfolio-level and per-stakeholder data:
```tsx
<div className="text-2xl font-bold text-purple-600">
  {(portfolioBlackSwans ? 1 : 0) + stakeholders.filter(s => s.blackSwans).length}
</div>
<div className="text-2xl font-bold text-emerald-600">
  {portfolioCalibratedQuestions.length + stakeholders.reduce((sum, s) => sum + (s.calibratedQuestions?.length || 0), 0)}
</div>
<div className="text-2xl font-bold text-amber-600">
  {portfolioObjections.length + stakeholders.reduce((sum, s) => sum + (s.likelyObjections?.length || 0), 0)}
</div>
```

### New Sections (Lines 382-524)
Three new `QuestionnaireSection` components with:
- Explanatory info boxes for each methodology concept
- Input fields with helpful placeholder text
- Add/remove functionality for list items

### Helper Components (Lines 801-862)
```tsx
function PortfolioCalibratedQuestionInput({ onAdd }: { onAdd: (question: string) => void })
function PortfolioObjectionInput({ onAdd }: { onAdd: (objection: string) => void })
```

---

## Testing Checklist

- [x] Black Swan Discovery section displays and expands
- [x] Textarea accepts input for Black Swan notes
- [x] Calibrated Questions section displays and expands
- [x] Can add calibrated questions to list
- [x] Can remove calibrated questions from list
- [x] Accusation Audit section displays and expands
- [x] Can add objections to list
- [x] Can remove objections from list
- [x] Intelligence Summary counters update correctly
- [x] Build passes with no TypeScript errors
- [x] No console errors

---

## Design Considerations

### Why Page-Level Sections?
1. **Immediate Visibility** - Users see Voss methodology inputs without prerequisite steps
2. **Portfolio-Wide Context** - Some Black Swans and objections apply across stakeholders
3. **Educational Value** - Explanatory content teaches Voss methodology concepts
4. **Dual-Level Input** - Users can add both portfolio-level and stakeholder-specific items

### Methodology Attribution
Each section includes:
- "Never Split the Difference" badge linking to book
- "Based on Never Split the Difference by Chris Voss" attribution
- Explanatory content about each concept

---

## Related Components

- `QuestionnaireSection` - Reusable collapsible section component
- Per-stakeholder inputs remain available inside stakeholder cards
- Intelligence Summary aggregates both portfolio and stakeholder data

---

## Notes

- Portfolio-level data is stored in local component state
- Future enhancement: Persist portfolio-level data to database
- Sections use accordion pattern - only one expanded at a time
- Black Swans section expanded by default for immediate engagement
