# Bug Fix: Risk & Recovery Cards Scroll to Bottom on Expand

**Date:** 2026-01-15
**Status:** Resolved
**Commit:** 98d31028

## Problem

Risk & Recovery cards in Step 5 were scrolling to the bottom of the expanded card content when opened, requiring users to manually scroll back up to see the content from the top.

## Root Cause

When clicking to expand a risk card, the browser would show the bottom of the expanded content instead of the top. This was missing the scroll-to-top behaviour that was implemented in other steps (e.g., StakeholderIntelligenceStep).

## Solution

Added scroll-to-top functionality using React refs and useEffect:

### Code Changes

**File:** `src/app/(dashboard)/planning/strategic/new/steps/RiskRecoveryStep.tsx`

1. **Added imports**:
   ```typescript
   import { useState, useMemo, useCallback, useRef, useEffect } from 'react'
   ```

2. **Added ref to store risk card elements**:
   ```typescript
   const riskRefs = useRef<Record<string, HTMLDivElement | null>>({})
   ```

3. **Added useEffect to scroll on expand**:
   ```typescript
   useEffect(() => {
     if (expandedRisk && riskRefs.current[expandedRisk]) {
       setTimeout(() => {
         riskRefs.current[expandedRisk]?.scrollIntoView({
           behavior: 'smooth',
           block: 'start',
         })
       }, 100)
     }
   }, [expandedRisk])
   ```

4. **Wrapped QuestionnaireSection with ref div**:
   ```tsx
   <div
     key={risk.id}
     ref={el => {
       riskRefs.current[risk.id] = el
     }}
     className="scroll-mt-4"
   >
     <QuestionnaireSection ... />
   </div>
   ```

## How It Works

- `riskRefs` stores a reference to each risk card's wrapper div
- When `expandedRisk` changes (user clicks to expand), the useEffect triggers
- `setTimeout` with 100ms delay allows the expand animation to start
- `scrollIntoView({ behavior: 'smooth', block: 'start' })` smoothly scrolls the card to the top of the viewport
- `scroll-mt-4` class adds a small margin at the top for visual spacing

## Testing

1. Navigate to `/planning/strategic/new`
2. Select an owner to enable the form
3. Go to Step 5 (Risk & Recovery)
4. Add a risk if none exist
5. Click on a collapsed risk card to expand it
6. Verify the card scrolls to show the top content, not the bottom

## Files Changed

- `src/app/(dashboard)/planning/strategic/new/steps/RiskRecoveryStep.tsx`

## Related Fixes

- Same pattern used in `StakeholderIntelligenceStep.tsx` for stakeholder card scrolling
