# Bug Report: ChaSen AI Coach Context Timing Issue

**Date:** 2026-01-14
**Status:** Fixed
**Priority:** Medium
**Component:** Strategic Planning Wizard - ChaSen AI Coach

---

## Issue

**Problem:** ChaSen AI Coach buttons could be clicked before portfolio data finished loading, resulting in AI responses with empty context:
- "Owner: (empty)"
- "Territory: Not specified"
- "No portfolio data available"

**User Impact:** Users received unhelpful AI insights because the context data wasn't available when they clicked the buttons.

---

## Root Cause

**Timing Issue:** The AI insight buttons were immediately enabled when the panel rendered, but portfolio data loads asynchronously after the owner is selected. Users could click buttons during the loading window (typically 1-3 seconds) before context was populated.

### Debug Evidence
When user clicked button with "0 clients loaded":
```
[AIInsightsPanel] handleInsightRequest called: {
  ownerName: '',
  territory: undefined,
  portfolioCount: 0
}
```

When button clicked after loading completed:
```
[AIInsightsPanel] handleInsightRequest called: {
  ownerName: 'John Salisbury',
  territory: 'Victoria',
  portfolioCount: 5
}
```

---

## Solution

### 1. Added `contextLoading` prop to AIInsightsPanel

**File:** `src/components/planning/unified/AIInsightsPanel.tsx`

```tsx
interface AIInsightsPanelProps {
  /** Current planning context */
  context: AIContext
  /** Current step in the planning workflow */
  currentStep: string
  /** Whether the panel is initially expanded */
  defaultExpanded?: boolean
  /** Whether context data is still loading (disables AI buttons) */
  contextLoading?: boolean
  // ... callbacks
}
```

### 2. Disabled buttons while loading

Updated button disabled state:
```tsx
disabled={loading || contextLoading}
```

Added visual styling for loading state:
```tsx
className={`... ${
  contextLoading
    ? 'border-gray-200 bg-gray-50'
    : 'border-gray-200 hover:border-indigo-300 hover:bg-indigo-50'
} disabled:opacity-50 disabled:cursor-not-allowed`}
```

### 3. Added loading indicator

Shows a visual indicator in the step hint area:
```tsx
{contextLoading && (
  <div className="mt-2 flex items-center gap-2 text-xs text-indigo-600">
    <Loader2 className="w-3 h-3 animate-spin" />
    <span>Loading portfolio data...</span>
  </div>
)}
```

### 4. Connected to page state

**File:** `src/app/(dashboard)/planning/strategic/new/page.tsx`

Passed the existing `loadingPortfolio` state to AIInsightsPanel:
```tsx
<AIInsightsPanel
  context={buildAIContext()}
  currentStep={STEPS[currentStep].id}
  defaultExpanded={aiCoachExpanded}
  contextLoading={loadingPortfolio}
  // ... callbacks
/>
```

---

## Files Modified

- `src/components/planning/unified/AIInsightsPanel.tsx`
  - Added `contextLoading` prop to interface
  - Destructured prop with default value `false`
  - Updated button disabled states
  - Added loading indicator in step hint area

- `src/app/(dashboard)/planning/strategic/new/page.tsx`
  - Passed `loadingPortfolio` as `contextLoading` prop

---

## Testing Checklist

- [x] Buttons are disabled while portfolio loads
- [x] "Loading portfolio data..." indicator appears during load
- [x] Buttons enable once portfolio finishes loading
- [x] AI insights include full context (owner, territory, clients)
- [x] Build passes with zero TypeScript errors
- [x] No visual regressions

---

## Before/After

### Before
- User clicks "Planning Preparation" immediately after selecting owner
- AI responds: "Owner: (empty), Territory: Not specified, No portfolio data"
- Confusing/useless response

### After
- Buttons are disabled with visual indicator during load
- User waits 1-3 seconds for portfolio to load
- Buttons enable, user clicks
- AI responds: "Owner: John Salisbury, Territory: Victoria, 5 clients in portfolio..."
- Helpful, contextual response

---

## Related Files

- `AIInsightsPanel.tsx` - Main AI Coach component
- `page.tsx` - Strategic planning wizard with loadingPortfolio state
- `usePlanAI.ts` - AI hook for API interactions
