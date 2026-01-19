# Bug Report: AI Suggestions API Missing 'action' Step Support

## Date
2026-01-19

## Error Type
Console Error / API Validation Error

## Error Message
```
Failed to fetch AI suggestions: {"success":false,"error":{"code":"INVALID_STEP","message":"Step must be one of: discovery, stakeholder, opportunity, risk"}}
```

## Root Cause
The Planning Wizard AI Suggestions API (`/api/planning/wizard/ai-suggestions`) only validated 4 wizard steps but the frontend 6-step workflow includes an 'action' step (Action & Narrative). When the frontend sent `step: 'action'`, the API rejected it with `INVALID_STEP`.

### Type Definition Mismatch
Multiple `WizardStep` type definitions existed across files with inconsistent values:
- **wizard-ai-data-gatherer.ts**: `'discovery' | 'stakeholder' | 'opportunity' | 'risk'` (missing 'action')
- **wizard-ai-prompts.ts**: `'discovery' | 'stakeholder' | 'opportunity' | 'risk'` (missing 'action')
- **wizard-ai-parser.ts**: `'discovery' | 'stakeholder' | 'opportunity' | 'risk'` (missing 'action')
- **useQuestionnaireAI.ts (hook)**: `'discovery' | 'stakeholder' | 'opportunity' | 'risk' | 'action'` ✓

The frontend hook correctly mapped `'action-narrative'` to `'action'`, but the backend didn't support it.

## Files Modified

### 1. `/src/app/api/planning/wizard/ai-suggestions/route.ts`
- Added `'action'` to validation array (line 88)
- Added `'action'` to GET endpoint steps array (line 231)

### 2. `/src/lib/planning/wizard-ai-data-gatherer.ts`
- Updated `WizardStep` type to include `'action'`
- Added `ActionContext` interface
- Added `gatherActionData()` function to gather data for action step
- Updated `checkDataSufficiency()` to handle 'action' step
- Updated `gatherDataForStep()` to handle 'action' step

### 3. `/src/lib/planning/wizard-ai-prompts.ts`
- Added `ActionContext` to imports
- Updated `WizardStep` type to include `'action'`
- Added `buildActionPrompt()` function for action step AI prompts
- Updated `buildPromptForStep()` to handle 'action' step

### 4. `/src/lib/planning/wizard-ai-parser.ts`
- Updated `WizardStep` type to include `'action'`
- Added 'action' case to `generateFallbackSuggestions()` for fallback suggestions

## Testing
- Build passes with zero TypeScript errors
- All files compile successfully

## Impact
- **Before**: Action & Narrative step in the Planning Wizard would fail to load AI suggestions
- **After**: Full 6-step workflow now supported with AI suggestions for all steps

## Prevention
- Consider using a single shared `WizardStep` type definition imported by all files
- Add integration tests for all wizard steps to catch step validation mismatches
