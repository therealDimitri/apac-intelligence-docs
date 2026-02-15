# Bug Report: Renewal Intent Classification Patterns

**Date:** 2026-01-19
**Status:** Fixed
**Severity:** Medium
**Component:** ChaSen Intent Classifier

## Issue

Certain renewal-related queries were being classified as `general` intent instead of `renewal_analysis`, causing them to bypass the specialist renewals agent.

### Example Query

```
"Which contracts are expiring in the next 90 days?"
```

**Before fix:**
- Intent: `general`
- Confidence: 0.30

**After fix:**
- Intent: `renewal_analysis`
- Confidence: 0.95

## Root Cause

The intent classifier phrase patterns were too rigid:
- `"contracts expiring"` didn't match `"contracts are expiring"` (with 'are' in between)
- Missing patterns for common time-based queries like "in the next 90 days"
- No patterns for "which contracts" or "what contracts" query variations

## Fix Applied

Updated `src/lib/chasen-intent-classifier.ts` to add comprehensive phrase patterns:

```typescript
phrases: [
  // Existing patterns...
  'contracts are expiring',      // NEW: handles "are" between words
  'contract is expiring',        // NEW: singular variant
  'expiring in the next',        // NEW: time-based pattern
  'expire in the next',          // NEW: time-based pattern
  'expiring soon',               // NEW
  'upcoming renewal',            // NEW: singular
  'contract end',                // NEW
  'contract ends',               // NEW
  'when does the contract',      // NEW
  'when is the contract',        // NEW
  'next 30 days',                // NEW: specific time frames
  'next 60 days',                // NEW
  'next 90 days',                // NEW
  'next quarter',                // NEW
  'this quarter',                // NEW
  'which contracts',             // NEW: question patterns
  'what contracts',              // NEW
]
```

## Test Results

| Query | Intent | Confidence |
|-------|--------|------------|
| Which contracts are expiring in the next 90 days? | renewal_analysis | 0.95 |
| Show me upcoming renewals | renewal_analysis | 0.95 |
| What contracts expire this quarter? | renewal_analysis | 0.95 |
| Renewal pipeline analysis | renewal_analysis | 0.93 |
| Contract end dates for my portfolio | renewal_analysis | 0.50 |

## Impact

Renewal-related queries now correctly route to the specialist renewals agent, improving response quality and relevance for contract management tasks.

## Commit

`52d3f0c8` - Improve renewal_analysis intent classification patterns
