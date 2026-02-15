# Bug Report: Stakeholder Intelligence Step Redesign

**Date:** 2026-01-14
**Status:** Fixed
**Priority:** Medium
**Component:** Strategic Planning - Stakeholder Intelligence Step

---

## Issue Description

**Problem:** The Stakeholder Intelligence step had page-level Voss methodology input sections (Black Swans, Calibrated Questions, Accusation Audit) that were redundant with per-stakeholder inputs already available inside stakeholder cards.

**User Report:** "Black Swan, Calibrated Questions, Accusation Audit input needs to be for each stakeholder added. Redesign the Stakeholder Intelligence step to display this."

---

## Root Cause Analysis

The previous implementation had two input paths for Voss methodology data:
1. **Page-level sections** - Portfolio-wide inputs visible at the top of the page
2. **Per-stakeholder sections** - Inputs nested inside each stakeholder card

This dual approach caused confusion as:
- Users weren't sure which input to use
- Page-level data wasn't linked to specific stakeholders
- The per-stakeholder inputs were hidden until cards were expanded

---

## Solution Implemented

Removed the page-level Voss methodology sections and kept only the per-stakeholder inputs that already existed inside stakeholder cards.

### Changes Made:

1. **Removed page-level sections:**
   - Black Swan Discovery section
   - Calibrated Questions section
   - Accusation Audit section

2. **Removed portfolio-level state:**
   ```tsx
   // REMOVED:
   const [portfolioBlackSwans, setPortfolioBlackSwans] = useState('')
   const [portfolioCalibratedQuestions, setPortfolioCalibratedQuestions] = useState<string[]>([])
   const [portfolioObjections, setPortfolioObjections] = useState<string[]>([])
   const [expandedSection, setExpandedSection] = useState<string | null>('black-swans')
   ```

3. **Updated Intelligence Summary counters:**
   ```tsx
   // Now only counts stakeholder data
   <div className="text-2xl font-bold text-purple-600">
     {stakeholders.filter(s => s.blackSwans).length}
   </div>
   <div className="text-2xl font-bold text-emerald-600">
     {stakeholders.reduce((sum, s) => sum + (s.calibratedQuestions?.length || 0), 0)}
   </div>
   <div className="text-2xl font-bold text-amber-600">
     {stakeholders.reduce((sum, s) => sum + (s.likelyObjections?.length || 0), 0)}
   </div>
   ```

4. **Removed unused imports and components:**
   - Removed `Lightbulb` icon import
   - Removed `PortfolioCalibratedQuestionInput` helper component
   - Removed `PortfolioObjectionInput` helper component

---

## Technical Changes

### File Modified
**`src/app/(dashboard)/planning/strategic/new/steps/StakeholderIntelligenceStep.tsx`**

### Lines Changed:
- Lines 189-193: Removed portfolio-level state variables
- Lines 382-524: Removed page-level QuestionnaireSection components
- Lines 801-862: Removed helper input components
- Updated Intelligence Summary to only count stakeholder data

---

## Testing Checklist

- [x] Page-level Voss sections no longer appear
- [x] Per-stakeholder inputs still work inside stakeholder cards
- [x] Intelligence Summary correctly counts stakeholder data
- [x] Build passes with no TypeScript errors
- [x] No console errors

---

## Design Considerations

### Why Per-Stakeholder Only?
1. **Clearer Data Ownership** - Each Black Swan, question, or objection is linked to a specific stakeholder
2. **Better Context** - Users think about Voss methodology in the context of individual relationships
3. **Reduced Confusion** - Single input path is clearer than dual paths
4. **Aligns with Methodology** - Voss techniques are typically applied per-conversation/stakeholder

---

## Related Components

- Per-stakeholder Voss inputs remain inside stakeholder cards
- Intelligence Summary still displays aggregate counts
- QuestionnaireSection component still used for other sections

---

## Notes

- Users must add a stakeholder to add Voss methodology data
- Each stakeholder card contains expandable sections for Black Swans, Calibrated Questions, and Objections
- The Intelligence Summary updates in real-time as stakeholder data is added
