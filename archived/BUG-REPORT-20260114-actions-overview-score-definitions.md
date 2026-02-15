# Bug Report: Actions Overview Placement and Score Definitions

**Date:** 2026-01-14
**Status:** Fixed
**Priority:** Medium
**Component:** Strategic Planning - Action & Narrative Step

---

## Issues Addressed

### 1. Actions Overview Section Placement
**Problem:** The Actions Overview section was positioned below Action Readiness, making it less prominent and harder to find.

**User Report:** "Move Actions Overview and Actions to top of page."

**Solution:** Moved Actions Overview section to appear immediately after AI Suggestions, before Action Readiness.

---

### 2. Missing Score Definitions
**Problem:** The Action Readiness card displayed scores (0-10) for each A.C.T.I.O.N. framework question, but users had no way to understand what each score value meant.

**User Report:** "Add score definitions to each score number in Action Readiness card."

**Solution:** Added contextual score definitions that display based on the current score value, with colour-coded badges.

---

## Technical Changes

### File Modified
**`src/app/(dashboard)/planning/strategic/new/steps/ActionNarrativeStep.tsx`**

### Score Definitions Added (Lines ~50-150)

```tsx
const ACTION_COMPLETENESS_QUESTIONS = [
  {
    id: 'atRiskClientsHaveActions',
    question: 'Do at-risk clients have specific actions assigned?',
    helpText: 'Critical/high risk clients should have mitigation actions defined',
    maxScore: 10,
    definitions: {
      0: 'No actions for at-risk clients',
      3: 'Some at-risk clients have actions',
      5: 'Half of at-risk clients covered',
      7: 'Most at-risk clients have actions',
      10: 'All at-risk clients have specific actions',
    },
  },
  {
    id: 'actionsHaveOwners',
    question: 'Do all actions have assigned owners?',
    helpText: 'Every action should have a specific person responsible',
    maxScore: 10,
    definitions: {
      0: 'No owners assigned',
      3: 'Few actions have owners',
      5: 'Half of actions have owners',
      7: 'Most actions have owners',
      10: 'All actions have assigned owners',
    },
  },
  {
    id: 'actionsHaveDueDates',
    question: 'Do all actions have due dates?',
    helpText: 'Actions without deadlines rarely get completed',
    maxScore: 10,
    definitions: {
      0: 'No due dates set',
      3: 'Few actions have due dates',
      5: 'Half of actions have due dates',
      7: 'Most actions have due dates',
      10: 'All actions have due dates',
    },
  },
  {
    id: 'actionsHaveNextSteps',
    question: 'Are next steps clearly defined?',
    helpText: 'Each action should have clear next steps to execute',
    maxScore: 10,
    definitions: {
      0: 'No next steps defined',
      3: 'Few actions have next steps',
      5: 'Half have clear next steps',
      7: 'Most have clear next steps',
      10: 'All actions have clear next steps',
    },
  },
  {
    id: 'keyAccountsCovered',
    question: 'Are key accounts adequately covered?',
    helpText: 'High-value clients should have proactive engagement plans',
    maxScore: 10,
    definitions: {
      0: 'Key accounts not covered',
      3: 'Few key accounts have plans',
      5: 'Half of key accounts covered',
      7: 'Most key accounts have plans',
      10: 'All key accounts have engagement plans',
    },
  },
  {
    id: 'renewalActionsPlanned',
    question: 'Are renewal actions planned in advance?',
    helpText: 'Renewals should have proactive action plans 90+ days out',
    maxScore: 10,
    definitions: {
      0: 'No renewal planning',
      3: 'Some renewals have plans',
      5: 'Half of renewals planned',
      7: 'Most renewals have advance plans',
      10: 'All renewals planned 90+ days out',
    },
  },
]
```

### Score Definition Display (In Action Readiness section)

```tsx
{/* Show current definition based on score */}
{question.definitions && (
  <div className="mt-2">
    <span className={`text-xs px-2 py-1 rounded-full ${
      currentValue === 0 ? 'bg-red-100 text-red-700'
        : currentValue < 4 ? 'bg-amber-100 text-amber-700'
        : currentValue < 7 ? 'bg-yellow-100 text-yellow-700'
        : currentValue < 10 ? 'bg-blue-100 text-blue-700'
        : 'bg-emerald-100 text-emerald-700'
    }`}>
      {currentDefinition}
    </span>
  </div>
)}
```

### Section Reordering

**Before:**
1. AI Suggestions
2. Action Readiness
3. Strategic Narrative
4. Actions Overview
5. Quick Add Action

**After:**
1. AI Suggestions
2. Actions Overview (moved up)
3. Action Readiness
4. Strategic Narrative
5. Quick Add Action

### Other Changes

- Removed Territory StoryBrand Narrative section (duplicate of Opportunity Stage step)
- Removed `ReferenceStoryInput` helper component
- Removed unused imports (`Star`, `FileText`)
- Updated Plan Summary grid from 4 to 3 columns (removed Reference Stories stat)

---

## Colour-Coded Score Definitions

| Score Range | Colour | Meaning |
|-------------|--------|---------|
| 0 | Red | Not started / Critical gap |
| 1-3 | Amber | Just beginning / Major gap |
| 4-6 | Yellow | Partial coverage / Moderate gap |
| 7-9 | Blue | Good coverage / Minor gap |
| 10 | Emerald | Complete / Fully covered |

---

## Testing Checklist

- [x] Actions Overview appears at top of page (after AI Suggestions)
- [x] Score definitions display for each question
- [x] Definitions update when slider is moved
- [x] Colour coding matches score ranges
- [x] Territory StoryBrand Narrative removed
- [x] Plan Summary shows 3 columns
- [x] Build passes with no TypeScript errors
- [x] No console errors

---

## Design Considerations

### Why Move Actions Overview Up?
1. **Primary Focus** - Actions are the main output of strategic planning
2. **Quick Access** - Users can see and manage actions immediately
3. **Logical Flow** - See actions before assessing their readiness

### Why Score Definitions?
1. **Clarity** - Users understand what each score means
2. **Guidance** - Helps users self-assess accurately
3. **Education** - Teaches best practices implicitly
4. **Actionable** - Users know what's needed to improve scores

---

## Related Components

- Action Readiness uses A.C.T.I.O.N. framework scoring
- Quick Add Action form below the main sections
- Plan Summary aggregates action metrics

---

## Notes

- Score definitions are hardcoded but could be made configurable
- Colour thresholds: 0, 1-3, 4-6, 7-9, 10
- Each question has 5 definition levels (0, 3, 5, 7, 10) with interpolation for other values
