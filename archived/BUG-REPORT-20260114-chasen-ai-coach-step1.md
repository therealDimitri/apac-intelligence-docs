# Bug Report: ChaSen AI Coach Step 1 Improvements

**Date:** 2026-01-14
**Status:** Fixed
**Priority:** Medium
**Component:** Strategic Planning Wizard - ChaSen AI Coach

---

## Issue

**Problem:** The ChaSen AI Coach panel on Step 1 (Setup & Context) displayed vague, unhelpful content:
- "ChaSen is here to help with your planning."
- "No specific actions for this step."
- Only a generic "Get General Insight" button

**User Impact:** CSE/CAM users starting a new strategic plan had no guidance on what to prepare or expect from the planning process.

---

## Root Cause

The `AIInsightsPanel` component had:
1. No `STEP_HINTS` entry for the V2 step ID `setup-context` (only had V1 `context` step)
2. No `INSIGHT_BUTTONS` configured for the `setup-context` step
3. No `QuickTips` logic for the `setup-context` step

---

## Solution

### 1. Added Step Hint for Setup & Context

**File:** `src/components/planning/unified/AIInsightsPanel.tsx`

```tsx
'setup-context':
  "Welcome! Let's prepare you for strategic planning. Select yourself as the plan owner to load your portfolio, then add any collaborators who should contribute. I'll guide you through Gap Selling, Voss negotiation, and MEDDPICC frameworks in the steps ahead.",
```

### 2. Added Three Insight Buttons

New buttons for the setup-context step:

| Button | Description | Maps To |
|--------|-------------|---------|
| Planning Preparation | Review what you need for effective strategic planning | `generateDraft` |
| Portfolio Snapshot | Get an initial overview of your portfolio health | `analyzeRisks` |
| Methodology Guide | Understand Gap Selling, Voss & MEDDPICC frameworks | `getContextualInsight` |

### 3. Added Quick Tips

Dynamic tips based on current state:
- "Select yourself as the plan owner to load your portfolio" (if no owner selected)
- "{X} clients loaded in your portfolio" (after owner selected)
- "{X} clients may need attention (health score below 60)" (if at-risk clients exist)
- "Add collaborators who should contribute to this plan"
- "Next: You'll diagnose gaps using Keenan's Gap Selling framework"

### 4. Updated usePlanAI Hook

**File:** `src/hooks/usePlanAI.ts`

Added V2 step ID mappings for `getContextualInsight`:
```tsx
'setup-context': 'generate_draft',
'discovery-diagnosis': 'analyze_risks',
'stakeholder-intelligence': 'stakeholder_insights',
'opportunity-strategy': 'meddpicc_coach',
'risk-recovery': 'suggest_actions',
'action-narrative': 'generate_draft',
```

---

## Files Modified

- `src/components/planning/unified/AIInsightsPanel.tsx`
  - Added `setup-context` to `STEP_HINTS`
  - Added V2 step hints for all 6 steps
  - Added 3 new insight buttons for setup-context
  - Added new InsightType values
  - Updated `handleInsightRequest` switch statement
  - Updated `getQuickTips` function

- `src/hooks/usePlanAI.ts`
  - Added V2 step ID mappings to `getContextualInsight`

---

## Testing Checklist

- [x] Welcome message displays on Step 1
- [x] Three action buttons appear (Planning Preparation, Portfolio Snapshot, Methodology Guide)
- [x] Quick Tips display actionable guidance
- [x] Tips update dynamically based on owner selection
- [x] Build passes with zero TypeScript errors
- [x] Buttons trigger appropriate AI requests

---

## Before/After

### Before
- "ChaSen is here to help with your planning."
- "No specific actions for this step."
- Generic "Get General Insight" button

### After
- "Welcome! Let's prepare you for strategic planning..."
- Three specific action buttons with clear descriptions
- Contextual quick tips that guide the user

---

## Related Files

- `AIInsightsPanel.tsx` - Main AI Coach component
- `usePlanAI.ts` - AI hook for API interactions
- `page.tsx` - Strategic planning wizard main page
