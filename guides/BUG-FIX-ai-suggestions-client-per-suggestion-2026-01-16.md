# Bug Fix: AI Suggestions - Show Client Context Per Suggestion

**Date:** 2026-01-16
**Type:** UX Enhancement
**Severity:** Medium
**Status:** Fixed

## Symptom

In the Strategic Planning wizard, the AI Suggestions panel displayed the client name only in the header:
> "AI Suggestions (5 fields) for SA"

This lacked clarity when suggestions related to different aspects or contexts. Users couldn't easily see which client each suggestion pertained to.

Additionally, the AI was generating examples using **NSW Health** as a recovery story example, despite NSW Health not being an active client.

## Root Cause Analysis

**UX Issue: Insufficient context per suggestion**

The `AIPrePopulation.tsx` component showed client context only in the header, not per-suggestion. When multiple suggestions were displayed, it was unclear which client each related to.

**AI Issue: No client whitelist/blacklist**

The AI prompts in `wizard-ai-prompts.ts` had no guidance about which clients were active or inactive. The AI would generate examples using any healthcare organisation name it knew, including NSW Health.

## Solution

### 1. Updated AISuggestion Interface

Added `clientName` field to the `AISuggestion` interface in both:
- `src/lib/planning/types.ts`
- `src/components/planning/methodology/AIPrePopulation.tsx`

```typescript
export interface AISuggestion {
  fieldId: string
  fieldLabel: string
  suggestedValue: string
  confidence: 'high' | 'medium' | 'low'
  reasoning?: string
  sources?: string[]
  /** Client or context this suggestion relates to */
  clientName?: string
}
```

### 2. Updated UI to Show Client Per Suggestion

Modified `AIPrePopulation.tsx` to display client name under each suggestion:

```typescript
{/* Client context for this suggestion */}
{suggestion.clientName && (
  <p className="text-xs text-indigo-600 mb-1">
    <span className="font-medium">Client:</span> {suggestion.clientName}
  </p>
)}
```

### 3. Updated AI Prompts

Modified `wizard-ai-prompts.ts` to:

1. Include `clientName` field in all prompt templates (discovery, stakeholder, opportunity, risk)
2. Add active client whitelist in BASE_SYSTEM_PROMPT
3. Add inactive client blacklist

```typescript
const BASE_SYSTEM_PROMPT = `You are an expert Customer Success strategist...

Guidelines:
- Include a "clientName" field in each suggestion to identify which client it relates to
- For recovery stories or examples, ONLY use these active APAC clients:
  SA Health, WA Health, Epworth Healthcare, Barwon Health, Western Health,
  Grampians Health, Albury Wodonga Health, SingHealth, Mount Alvernia Hospital, GRMC
- NEVER mention NSW Health, Hunter New England Health, or other inactive/non-existent clients
`
```

## Files Changed

| File | Changes |
|------|---------|
| `src/lib/planning/types.ts` | Added `clientName?: string` to AISuggestion interface |
| `src/components/planning/methodology/AIPrePopulation.tsx` | Updated interface, removed client from header, added per-suggestion display |
| `src/lib/planning/wizard-ai-prompts.ts` | Updated all prompts to include clientName, added client whitelist/blacklist |

## Testing Verification

1. ✅ Build passes with no TypeScript errors
2. ✅ ESLint passes
3. ✅ Pre-commit hooks pass

## Visual Change

**Before:**
```
┌─────────────────────────────────────────────┐
│ AI Suggestions (5 fields) for SA            │
├─────────────────────────────────────────────┤
│ Discovery Focus                             │
│ Consider prioritising...                    │
│ Confidence: high                            │
├─────────────────────────────────────────────┤
│ Recovery Story                              │
│ Consider sharing how NSW Health faced...    │  ← Wrong client!
│ Confidence: medium                          │
└─────────────────────────────────────────────┘
```

**After:**
```
┌─────────────────────────────────────────────┐
│ AI Suggestions (5 fields)                   │
├─────────────────────────────────────────────┤
│ Discovery Focus                             │
│ Client: SA Health                           │  ← Clear context
│ Consider prioritising...                    │
│ Confidence: high                            │
├─────────────────────────────────────────────┤
│ Recovery Story                              │
│ Client: WA Health                           │  ← Active client
│ Consider sharing how WA Health faced...     │
│ Confidence: medium                          │
└─────────────────────────────────────────────┘
```

## Prevention

- AI prompts now include explicit whitelist of active clients
- AI prompts include explicit blacklist of inactive clients (NSW Health, Hunter New England Health)
- Each suggestion includes client context for clarity

## Commit

```
0fd624c2 Show client context per AI suggestion instead of in header
```
