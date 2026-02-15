# Bug Report: AI Suggestions Not Working for Territory Plans

**Date**: 16 January 2026
**Status**: Fixed
**Severity**: Medium
**Component**: Strategic Planning Wizard - AI Suggestions

## Issue Description

AI Suggestions panel showed "No suggestions available for this territory" for territory plans like "Asia + Guam" even though there were 21 opportunities with valid client data in the plan.

## Root Cause Analysis

### Problem Flow
1. Territory plan "Asia + Guam" with owner "Open Role" (or any CSE with no direct client assignments)
2. Portfolio loading queries: `clients WHERE cse_name = 'Open Role'` - returns empty
3. `formData.portfolio` is empty despite having 21 pipeline opportunities
4. AI suggestions code used `primaryClient?.name || formData.territory` as client name
5. Fell back to territory name "Asia + Guam" since portfolio was empty
6. AI data gatherer queried: `client_name = 'Asia + Guam'` - no client exists with that name
7. Returned empty suggestions

### Key Insight
The code prioritised `formData.portfolio[0]` but didn't consider `formData.opportunities` or `pipelineOpportunities` which contain actual client names from the pipeline.

## Fix Applied

**File**: `src/app/(dashboard)/planning/strategic/new/page.tsx`

### Changes
Updated the AI suggestions loading logic to use client names from multiple sources with the following priority:

1. `formData.portfolio[0]?.name` - Portfolio client (for account plans)
2. `formData.opportunities[0]?.client_name` - Included opportunity client name
3. `pipelineOpportunities[0]?.client_name` - Available pipeline opportunity client name
4. `formData.territory` - Territory name (last resort fallback)

### Updated Locations
- useEffect for auto-loading AI suggestions (lines 945-987)
- Discovery step `onLoadAISuggestions` handler
- Stakeholder step `onLoadAISuggestions` handler
- Opportunity step `onLoadAISuggestions` handler
- Risk step `onLoadAISuggestions` handler

### Code Change Example
```typescript
// Before
const clientNameToUse = primaryClient?.name || formData.territory

// After
const firstOpportunityClient =
  formData.opportunities[0]?.client_name || pipelineOpportunities[0]?.client_name
const clientNameToUse = primaryClient?.name || firstOpportunityClient || formData.territory
```

## Testing

- TypeScript compilation: Passed
- Build compilation: Passed (note: full build requires Supabase env vars)

## Impact

Territory plans with empty portfolios but populated pipeline opportunities will now receive AI suggestions based on the first opportunity's client name, providing relevant insights from that client's meeting history, NPS data, and health metrics.

## Related Files

- `src/app/(dashboard)/planning/strategic/new/page.tsx` - Main wizard page
- `src/hooks/useQuestionnaireAI.ts` - AI suggestions hook
- `src/app/api/planning/wizard/ai-suggestions/route.ts` - AI suggestions API
- `src/lib/planning/wizard-ai-data-gatherer.ts` - Data gathering for AI context
