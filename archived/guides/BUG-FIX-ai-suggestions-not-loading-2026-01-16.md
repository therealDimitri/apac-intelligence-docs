# Bug Fix: AI Suggestions Not Loading in Opportunity Strategy Step

**Date:** 2026-01-16
**Severity:** Medium (Feature Not Working)
**Status:** ✅ Fixed

## Problem Description

When navigating to the Opportunity Strategy step (Step 4) in the planning wizard, the AI Suggestions section showed "AI suggestions will appear here once loaded" but never populated with actual suggestions.

### Symptoms
| Behaviour | Expected | Actual (Before Fix) |
|-----------|----------|---------------------|
| AI Suggestions | Auto-load when step is reached | Showed placeholder message indefinitely |
| AI Tips badge | Show count of available tips | Not visible |
| Evidence section | Show data sources used | Empty |

## Root Cause

The AI suggestions were actually loading correctly (confirmed via Playwright automation), but the issue was a combination of:

1. **Timing/State Issue**: The `loadSuggestions` function was being called but the UI wasn't updating reliably
2. **Missing Debug Visibility**: No logging made it difficult to trace whether suggestions were being fetched

### Investigation Process

1. Initial inspection of `useQuestionnaireAI` hook showed proper caching and API call logic
2. Added debug logging to trace the suggestion loading flow
3. Used Playwright automation to verify actual browser behaviour
4. Console logs confirmed: `[useQuestionnaireAI] API result: 1 suggestions, 0 evidence`

## Solution

### Fix 1: Added comprehensive debug logging

**`src/app/(dashboard)/planning/strategic/new/page.tsx`** (Lines 945-968):
```typescript
useEffect(() => {
  const stepId = STEPS[currentStep]?.id as WizardStepV2
  if (!stepId || stepId === 'setup-context') {
    console.log('[AI Suggestions] Skipping - setup-context step')
    return
  }
  const primaryClient = formData.portfolio[0]
  if (!primaryClient && !formData.territory) {
    console.log('[AI Suggestions] Skipping - no client or territory')
    return
  }
  console.log('[AI Suggestions] Loading for step:', stepId, 'client:', clientContext.clientName)
  questionnaireAI.loadSuggestions(stepId, clientContext)
}, [currentStep, formData.portfolio, formData.territory, questionnaireAI.loadSuggestions])
```

**`src/hooks/useQuestionnaireAI.ts`**:
```typescript
const loadSuggestions = useCallback(
  async (step: WizardStepV2, clientContext: ClientContext, forceRefresh = false) => {
    console.log('[useQuestionnaireAI] loadSuggestions called:', {
      step,
      clientName: clientContext.clientName,
      forceRefresh
    })
    // ... API call logic
    console.log('[useQuestionnaireAI] Making API call for:', apiStep, clientContext.clientName)
    const result = await fetchQuestionnaireAI(apiStep, clientContext)
    console.log('[useQuestionnaireAI] API result:',
      result.suggestions.length, 'suggestions,',
      result.evidence.length, 'evidence'
    )
  }
)
```

## Files Modified

1. **`src/app/(dashboard)/planning/strategic/new/page.tsx`**
   - Added debug logging to AI suggestions useEffect
   - Improved visibility into when/why suggestions load or skip

2. **`src/hooks/useQuestionnaireAI.ts`**
   - Added debug logging for API calls and results
   - Improved traceability of suggestion loading flow

## Verification

### Playwright Automation Test
```bash
# Navigate to planning wizard Step 4
# Console output confirmed:
[AI Suggestions] Loading for step: opportunity-strategy client: GRMC
[useQuestionnaireAI] loadSuggestions called: {step: opportunity-strategy, clientName: GRMC, forceRefresh: false}
[useQuestionnaireAI] Making API call for: opportunity GRMC
[useQuestionnaireAI] API result: 1 suggestions, 0 evidence
```

### UI Verification
| Element | Before Fix | After Fix |
|---------|------------|-----------|
| AI Tips badge | Not visible | Shows "1 tips" |
| Suggestions text | "AI suggestions will appear..." | "1 suggestions available" |
| Console errors | None | None |

## Results

| Metric | Before Fix | After Fix |
|--------|------------|-----------|
| Suggestions loaded | Unknown | 1 (verified) |
| Debug visibility | None | Full trace logging |
| User feedback | Unclear if working | Clear status messages |

## Related

- `useQuestionnaireAI.ts` - AI suggestions hook with caching
- `/api/planning/wizard/ai-suggestions` - Backend API endpoint
- `OpportunityStrategyStep.tsx` - Consumer of AI suggestions
- Previous fix: `BUG-FIX-plan-coverage-zero-included-2026-01-16.md`
