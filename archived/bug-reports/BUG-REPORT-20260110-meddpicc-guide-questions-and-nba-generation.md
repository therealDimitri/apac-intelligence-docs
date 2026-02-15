# MEDDPICC Guide Questions and Next Best Actions Generation

**Date:** 2026-01-10
**Type:** Enhancement / Bug Fix
**Status:** Resolved
**Priority:** Medium

---

## Issue Description

Two issues addressed in this update:

1. **MEDDPICC guide statements not in question format**: The MEDDPICC framework guide needed statements converted to questions for CSE/CAM consideration
2. **Score definitions not visible**: Users couldn't see what each 1-5 score level meant
3. **Next Best Actions not appearing**: The NextBestActionsPanel was showing "All caught up!" because no actions existed in the database

## Root Cause

### Issue 1 & 2: Missing Guide Content
The MEDDPICC score card component had no guide questions or score definitions - these were not implemented in the original component.

### Issue 3: No Action Generation Logic
The NextBestActionsPanel only fetched actions from the `next_best_actions` database table but never generated them. If the table was empty, no actions would display.

## Solution

### 1. Added Score Definitions (1-5 Scale)
```typescript
export const MEDDPICC_SCORE_DEFINITIONS: Record<number, { label: string; description: string }> = {
  1: { label: 'Unknown', description: 'No information gathered yet' },
  2: { label: 'Initial', description: 'Some awareness, needs validation' },
  3: { label: 'Developing', description: 'Partially documented, gaps remain' },
  4: { label: 'Validated', description: 'Well documented with evidence' },
  5: { label: 'Complete', description: 'Fully confirmed and verified' },
}
```

### 2. Added Guide Questions for Each MEDDPICC Element
Converted statements to questions format:

**Metrics:**
- What specific KPIs or business outcomes will improve if the client adopts this solution?
- Can you quantify the economic benefit in their terms (e.g., cost savings, revenue growth, efficiency gains)?
- What measurable success criteria have been agreed with the client?

**Economic Buyer:**
- Who is the person with the ultimate authority to approve this purchase?
- Have you had direct access to them, or are you relying on others to communicate value?
- What are their personal win criteria beyond the business case?

**Decision Criteria:**
- What are the formal and informal criteria the client will use to evaluate solutions?
- How does your solution align with these criteria?
- Which criteria are must-haves versus nice-to-haves?

**Decision Process:**
- What are the steps the client will follow to make a final decision?
- Who is involved at each stage, and what are the key milestones?
- What is the expected timeline and are there any potential blockers?

**Paper Process:**
- What is the legal, procurement, or administrative process the client must follow to execute a purchase?
- Who are the stakeholders involved in contract approval?
- Are there any compliance or security requirements that could delay signing?

**Identify Pain:**
- What is the business problem or challenge the client is trying to solve?
- Is the pain compelling enough to drive action, and what happens if they do nothing?
- Can you quantify the cost of the current problem to the organisation?

**Champion:**
- Who within the client organisation is actively advocating for your solution?
- Have you tested their commitment by asking them to take action on your behalf?
- Do you have multiple champions across different departments or levels?

**Competition:**
- Who else is being considered, including internal alternatives or the status quo?
- What are your key differentiators and competitive advantages?
- How are you positioning against the competition in conversations with the client?

### 3. Added Automatic Action Generation to NextBestActionsPanel
The panel now automatically generates rule-based actions when:
- No actions exist for the given CSE
- No actions exist for the given client

Actions are generated based on:
- Meeting gaps (>30 days, >45 days critical)
- NPS detractors (<= 6)
- Health score decline (>10 points drop)
- Critical health (<50)
- Overdue actions
- Missing compliance events

## Files Modified

| File | Changes |
|------|---------|
| `src/hooks/useMEDDPICC.ts` | Added `MEDDPICC_SCORE_DEFINITIONS` and `MEDDPICC_GUIDE_QUESTIONS` exports |
| `src/components/planning/MEDDPICCScoreCard.tsx` | Imported definitions, display score definition on edit, show guide questions in expanded view |
| `src/components/planning/NextBestActionsPanel.tsx` | Added `fetchClientContext`, `generateMissingActions` functions for automatic action generation |

## UI Changes

### Score Editing
When editing a MEDDPICC score:
- Each score button (1-5) now has a tooltip showing the level definition
- The selected score's definition displays below the score buttons
- Format: "**Validated**: Well documented with evidence"

### Expanded Element View
When expanding a MEDDPICC element:
- Blue "Questions to consider" box now appears at the top
- Lists 3 guiding questions for the CSE/CAM to consider
- Followed by Evidence and AI Suggestions sections

### Next Best Actions
When no actions exist:
- Panel automatically fetches client context data
- Generates rule-based actions using `generateActionsForClient`
- Persists actions to database for future retrieval
- Displays generated actions immediately

## Testing Checklist

- [x] Build passes without TypeScript errors
- [x] Score definitions display as tooltips on score buttons
- [x] Score definition text displays below buttons when editing
- [x] Guide questions display in expanded MEDDPICC elements
- [x] Questions are in interrogative format (end with ?)
- [x] NextBestActionsPanel generates actions when table is empty
- [x] Generated actions persist to database

## Score Level Definitions

| Score | Label | Description |
|-------|-------|-------------|
| 1 | Unknown | No information gathered yet |
| 2 | Initial | Some awareness, needs validation |
| 3 | Developing | Partially documented, gaps remain |
| 4 | Validated | Well documented with evidence |
| 5 | Complete | Fully confirmed and verified |

---

## Additional Enhancement: MEDDPICC Qualification Guide Accordion

### Feature Added
A collapsible "MEDDPICC Qualification Guide" accordion was added to the scorecard with:
- Concise definitions for each MEDDPICC element
- Scoring-aligned key questions (designed to be answered on a 1-5 scale)
- Additional consideration questions

### Element Definitions and Key Questions

| Element | Definition | Key Question (1-5 Scale) |
|---------|------------|--------------------------|
| **M**etrics | Quantifiable measures of value the customer will gain | How clearly have we documented the specific ROI metrics the client expects? |
| **E**conomic Buyer | The person with final authority and budget | How much direct access and engagement do we have with the final decision-maker? |
| **D**ecision Criteria | Formal and informal requirements for evaluation | How well do we understand their evaluation criteria and how we rank against them? |
| **D**ecision Process | Steps, stakeholders, and timeline for decision | How clearly have we mapped each step and stakeholder in their approval process? |
| **P**aper Process | Legal, procurement, and admin steps to close | How well do we understand the contract and procurement requirements to close? |
| **I**dentify Pain | Critical business problem driving need for change | How thoroughly have we quantified the business impact of their current pain? |
| **C**hampion | Internal advocate with power and personal stake | How actively is our champion advocating and influencing internally for us? |
| **C**ompetition | Alternative solutions including status quo | How completely have we mapped all competitors and differentiated against them? |

### Import Opportunity Feature
Added "Import Opportunity" button and dialog to the MEDDPICC card header allowing users to:
- Enter opportunity name (required)
- Set value and stage
- Add expected close date
- Include description

---

## Additional Fixes (Session 2)

### 1. MEDDPICC Features Added to Account Plan Page
The Score Guide and Qualification Guide were added directly to the Opportunities step of the Account Plan wizard:

**Files Modified:**
- `src/app/(dashboard)/planning/account/new/page.tsx`

**Changes:**
- Added imports for `MEDDPICC_SCORE_DEFINITIONS`, `MEDDPICC_DEFINITIONS`, and `MEDDPICCElement` type
- Added state variables: `showMeddpiccScoreLegend`, `showMeddpiccGuide`, `expandedMeddpiccElement`
- Added collapsible Score Guide (1-5) showing colour-coded score definitions (red=1-2, amber=3, green=4-5)
- Added collapsible MEDDPICC Qualification Guide with expandable elements showing definitions and key questions

### 2. NBA Temporary Action Handling
Fixed error when accepting/completing/dismissing locally generated actions:

**Root Cause:** Generated actions have temporary IDs (e.g., `temp-ClientName-0-timestamp`) that don't exist in the database. Attempting to update them caused RLS errors.

**Solution:** Modified `handleAccept`, `handleComplete`, and `handleDismiss` functions to check if the action ID starts with `temp-` and handle locally instead of making database calls.

```typescript
// Check if this is a temporary (locally generated) action
const isTemporary = action.id.startsWith('temp-')

if (isTemporary) {
  // For temporary actions, just update local state
  setActions(prev => prev.map(a => ...))
} else {
  // For persisted actions, update the database
  const result = await acceptAction(action.id)
}
```

### 3. NBA Actions Filter Against Existing Actions
Added logic to check if NBA-generated actions already exist in the `actions` table:

**Behaviour:**
- If an existing action is found and has status "Completed", the NBA action is skipped entirely
- If an existing action is found but not completed, the NBA action shows the existing status in the description

**Implementation:**
```typescript
// Fetch existing actions from actions table for comparison
const fetchExistingActions = useCallback(async (clientNames: string[]) => {
  const { data } = await supabase
    .from('actions')
    .select('client, Action_Description, Status')
    .in('client', clientNames)
  // ...
})

// Compare using keyword similarity (2+ matching words)
const actionMatchesExisting = (generatedTitle: string, existingDescription: string): boolean => {
  const matchingWords = generatedWords.filter(word => existingWords.includes(word))
  return matchingWords.length >= 2
}
```

### 4. Scroll-to-Top on Step Navigation
Fixed missing scroll-to-top when navigating between Account Plan steps:

**File:** `src/app/(dashboard)/planning/account/new/page.tsx`

**Root Cause:** The dashboard layout uses a `<main>` element with `overflow-y-auto` for scrolling, not the window. So `window.scrollTo()` had no effect.

**Fix:**
```typescript
const goToStep = (step: number) => {
  if (step >= 0 && step < STEPS.length) {
    saveProgress()
    setCurrentStep(step)
    // Scroll to top of page when navigating between steps
    // The main content area has overflow-y-auto, so we need to scroll that element, not window
    const mainElement = document.querySelector('main')
    if (mainElement) {
      mainElement.scrollTo({ top: 0, behavior: 'smooth' })
    }
  }
}
```

### 5. Enhanced MEDDPICC Scoring Guidance
Updated MEDDPICC definitions with concise, question-oriented scoring guidance:

**File:** `src/hooks/useMEDDPICC.ts`

**Changes:**
- Made definitions more concise
- Added `scoringGuide` property with specific criteria for each score level (1-5)
- Key questions now direct and actionable

**Example - Metrics Element:**
```typescript
metrics: {
  definition: 'Quantifiable ROI the client expects from your solution.',
  keyQuestion: 'Can we quantify the value in their terms?',
  scoringGuide: {
    1: 'No metrics identified',
    2: 'General benefits discussed, not quantified',
    3: 'Some metrics identified, not validated',
    4: 'Clear metrics agreed with stakeholders',
    5: 'Documented ROI with client sign-off',
  },
}
```

**UI Updates:**
- Each expanded MEDDPICC element now shows:
  - Concise definition
  - Direct key question
  - Colour-coded scoring guide (1-2 red, 3 amber, 4-5 green)
  - Specific criteria for each score level

---

## Updated Testing Checklist

- [x] Build passes without TypeScript errors
- [x] Score Guide (1-5) displays in Account Plan Opportunities step
- [x] Qualification Guide accordion works with expandable elements
- [x] NBA actions can be accepted/completed/dismissed without errors
- [x] NBA actions filter out completed actions from actions table
- [x] NBA actions show existing status when action already exists
- [x] Scroll-to-top works when clicking Next/Previous in Account Plan
- [x] Scoring guidance displays for each MEDDPICC element
- [x] Key questions are concise and directly answerable on 1-5 scale
- [x] Scoring guide is colour-coded (red=1-2, amber=3, green=4-5)

---

## Related Documentation

- `src/lib/next-best-action.ts` - Core NBA engine with action detection logic
- `src/hooks/useMEDDPICC.ts` - MEDDPICC hook with scoring, definitions, and questions
- `src/components/planning/NextBestActionsPanel.tsx` - NBA panel with action generation and filtering
