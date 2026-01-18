# Bug Fix: AI Suggestions Only Showing Single Client

**Date**: 2026-01-19
**Type**: Bug Fix
**Status**: RESOLVED

---

## Issue Summary

AI Suggestions on the Opportunity Strategy page (and other wizard steps) only displayed suggestions for a single client when CSEs have multiple clients in their portfolio. Suggestions should be generated and displayed for ALL clients assigned to the CSE.

## Problem

When a CSE with multiple clients in their portfolio loaded AI Suggestions on any wizard step (Discovery, Stakeholder, Opportunity Strategy, Risk Recovery), the system only fetched and displayed suggestions for the first client in the portfolio, ignoring all other clients.

**Example**: CSE John Salisbury has clients including WA Health, SA Health, NT Health, etc. The AI Suggestions panel only showed "WA Health: 7 suggestions" instead of suggestions for all assigned clients.

## Root Cause

The `onLoadAISuggestions` handler in the strategic planning wizard page (`src/app/(dashboard)/planning/strategic/new/page.tsx`) was only extracting the first client from the portfolio:

```typescript
// Before (BROKEN):
onLoadAISuggestions={() => {
  const primaryClient = formData.portfolio[0]  // Only first client!
  const clientNameToUse = primaryClient?.name || firstOpportunityClient
  // ... only generates for single client
}}
```

## Solution

### 1. Added Multi-Client Method to Hook

Added `loadSuggestionsForClients` method to `useQuestionnaireAI` hook that fetches suggestions for multiple clients in parallel:

**File**: `src/hooks/useQuestionnaireAI.ts`

```typescript
loadSuggestionsForClients: (
  step: WizardStepV2,
  clientContexts: ClientContext[],
  forceRefresh?: boolean
) => Promise<void>
```

This method:
- Fetches suggestions for all clients in parallel using `Promise.all`
- Uses caching per-client to avoid redundant API calls
- Tags each suggestion with its `clientName` for grouping
- Makes fieldIds unique per-client to avoid conflicts

### 2. Updated Wizard Page

Modified all four wizard steps (Discovery, Stakeholder, Opportunity, Risk) to collect ALL clients from portfolio and opportunities:

**File**: `src/app/(dashboard)/planning/strategic/new/page.tsx`

```typescript
// After (FIXED):
onLoadAISuggestions={() => {
  // Get unique client names from portfolio and opportunities
  const portfolioClientNames = formData.portfolio.map(c => c.name).filter(Boolean)
  const opportunityClientNames = [
    ...new Set(
      [...formData.opportunities, ...pipelineOpportunities]
        .map(o => o.client_name)
        .filter(Boolean)
    ),
  ]
  const allClientNames = [...new Set([...portfolioClientNames, ...opportunityClientNames])]

  // If we have multiple clients, use the multi-client method
  if (allClientNames.length > 1) {
    const clientContexts: AIClientContext[] = allClientNames.map(name => ({
      clientName: name,
      territory: formData.territory,
    }))
    return questionnaireAI.loadSuggestionsForClients('opportunity-strategy', clientContexts, true)
  }
  // Single client fallback...
}}
```

### 3. Enhanced UI Component

Updated `AIPrePopulation` component to group suggestions by client with per-client "Apply All" buttons:

**File**: `src/components/planning/methodology/AIPrePopulation.tsx`

- Added logic to group suggestions by `clientName`
- Displays grouped sections: "{ClientName}: X suggestions" with per-group "Apply All"
- Each client group is collapsible with its own styling
- Added "Refresh All" button for multi-client mode

### 4. Updated Account Plan View

Also updated the account plan view page to use CSE-based suggestions for portfolio-wide context:

**File**: `src/app/(dashboard)/planning/account/[id]/page.tsx`

Changed from `clientName={plan.client_name}` to `cseName={plan.cse_partner}` to show suggestions for the CSE's entire portfolio.

## Files Modified

| File | Changes |
|------|---------|
| `src/hooks/useQuestionnaireAI.ts` | Added `loadSuggestionsForClients` method (+120 lines) |
| `src/app/(dashboard)/planning/strategic/new/page.tsx` | Updated all 4 wizard steps to pass all clients (+100 lines) |
| `src/components/planning/methodology/AIPrePopulation.tsx` | Added client grouping UI (+180 lines) |
| `src/app/(dashboard)/planning/account/[id]/page.tsx` | Use CSE name for portfolio suggestions |

## Testing

- [x] Build passes (`npm run build`)
- [x] TypeScript compilation successful
- [x] ESLint passes
- [x] Changes committed and pushed to `main`

## Result

AI Suggestions now:
1. Fetches suggestions for ALL clients in the CSE's portfolio in parallel
2. Groups suggestions by client name with individual "Apply All" buttons
3. Shows per-client suggestion counts (e.g., "WA Health: 7 suggestions", "SA Health: 5 suggestions")
4. Caches results per-client to avoid redundant API calls
5. Maintains backward compatibility for single-client scenarios
