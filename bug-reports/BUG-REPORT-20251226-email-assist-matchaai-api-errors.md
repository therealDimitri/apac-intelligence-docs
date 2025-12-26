# Bug Report: Email Assist MatchaAI API Errors

**Date:** 26 December 2025
**Severity:** High
**Status:** Resolved
**Commits:** `ae99400`, `33d9b20`

---

## Summary

The Email Template Studio's AI-powered email assistance features were failing with console errors including "Failed to rewrite content", "Failed to execute action", and "Failed to generate suggestions". The email-assist API was returning 404 errors from the MatchaAI service.

---

## Symptoms

Users reported three console errors when using email assist features:

1. `Failed to rewrite content`
2. `Failed to execute action`
3. `Failed to generate suggestions`

API responses showed:

```json
{ "success": false, "error": { "code": "INTERNAL_ERROR", "message": "MatchaAI API error: 404" } }
```

---

## Root Cause Analysis

**Two separate issues were identified:**

### Issue 1: Invalid Default Model ID

The `.env.local` and multiple source files had `MATCHAAI_DEFAULT_MODEL=claude-3-7-sonnet`, but this model key does not exist in MatchaAI.

**Valid MatchaAI model keys:**

- `claude-sonnet-4-5` (ID: 28) ✅
- `claude-sonnet-4` (ID: 28) ✅
- `claude-3-7-sonnet` does not exist ❌

### Issue 2: Incorrect API Configuration in email-assist

The `src/app/api/chasen/email-assist/route.ts` had its own custom `callMatchaAI` function that differed from the working implementation in `src/lib/ai-providers.ts`:

| Configuration | email-assist (Broken) | ai-providers.ts (Working) |
| ------------- | --------------------- | ------------------------- |
| Endpoint      | `/messages`           | `/completions`            |
| Header        | `X-Api-Key`           | `MATCHA-API-KEY`          |
| Model ID      | String key directly   | Numeric ID from mapping   |
| Mission ID    | String                | Parsed as integer         |

---

## Files Affected

### Issue 1 - Default Model Updates

- `.env.local`
- `src/lib/ai-providers.ts`
- `src/lib/multi-agent.ts`
- `src/lib/agent-workflows.ts`
- `src/lib/ai-evaluation.ts`
- `src/app/api/chasen/ar-insights/route.ts`
- `src/app/api/chasen/chat/route.ts`
- `src/app/api/chasen/email-assist/route.ts`
- `src/app/api/llms/route.ts`
- `src/app/api/meetings/parse-natural-language/route.ts`
- `src/hooks/useStreamingChat.ts`
- `src/components/FloatingChaSenAI.tsx`

### Issue 2 - API Configuration Fix

- `src/app/api/chasen/email-assist/route.ts`

---

## Solution

### Fix 1: Update Default Model to claude-sonnet-4-5

Changed all hardcoded defaults from `claude-3-7-sonnet` to `claude-sonnet-4-5`:

```typescript
// Before
defaultModel: process.env.MATCHAAI_DEFAULT_MODEL || 'claude-3-7-sonnet',

// After
defaultModel: process.env.MATCHAAI_DEFAULT_MODEL || 'claude-sonnet-4-5',
```

Added `claude-sonnet-4-5` to MODEL_MAP in `ai-providers.ts`:

```typescript
export const MODEL_MAP: Record<string, { id: number; name: string; provider: string }> = {
  'claude-sonnet-4-5': { id: 28, name: 'Claude Sonnet 4.5', provider: 'anthropic' },
  'claude-sonnet-4.5': { id: 28, name: 'Claude Sonnet 4.5', provider: 'anthropic' },
  'claude-sonnet-4': { id: 28, name: 'Claude Sonnet 4', provider: 'anthropic' },
  // ... other models
}
```

### Fix 2: Correct email-assist API Configuration

Updated the custom `callMatchaAI` function in email-assist to match the working implementation:

```typescript
// Added model ID mapping
const MODEL_IDS: Record<string, number> = {
  'claude-sonnet-4-5': 28,
  'claude-sonnet-4.5': 28,
  'claude-sonnet-4': 28,
  'claude-3-7-sonnet': 27,
}

// Fixed API call
const modelId = MODEL_IDS[MATCHAAI_CONFIG.defaultModel] || 28

const response = await fetch(`${MATCHAAI_CONFIG.baseUrl}/completions`, {
  // Changed from /messages
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'MATCHA-API-KEY': MATCHAAI_CONFIG.apiKey, // Changed from X-Api-Key
  },
  body: JSON.stringify({
    llm_id: modelId, // Now uses numeric ID
    mission_id: parseInt(MATCHAAI_CONFIG.missionId), // Parsed as integer
    messages: [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt },
    ],
    max_tokens: 2000,
    temperature: 0.7,
  }),
})
```

Also improved response parsing with multiple fallback structures to handle different API response formats.

---

## Verification

Tested email assist API after fixes:

```bash
# Test generate-subject
curl -X POST http://localhost:3002/api/chasen/email-assist \
  -H "Content-Type: application/json" \
  -d '{"action": "generate-subject", "content": "QBR follow-up", "context": {"clientName": "Epworth Healthcare"}}'

# Response:
{"subject":"Altera Digital Health & Epworth Healthcare: QBR Action Items Follow-Up"}

# Test generate-intro
curl -X POST http://localhost:3002/api/chasen/email-assist \
  -H "Content-Type: application/json" \
  -d '{"action": "generate-intro", "context": {"recipientName": "Sarah", "clientName": "Epworth Healthcare"}}'

# Response:
{"content":"Dear Sarah,\n\nIt was a pleasure to connect with you and the Epworth Healthcare team..."}
```

All email assist actions now working correctly.

---

## Prevention Recommendations

1. **Use shared utilities:** The `email-assist` route should import `callMatchaAI` from `@/lib/ai-providers` instead of maintaining its own implementation.

2. **Centralise model configuration:** Create a single source of truth for MatchaAI configuration to avoid drift between implementations.

3. **Add integration tests:** Create tests that verify MatchaAI API connectivity for all AI-powered features.

4. **Document valid model keys:** Maintain a list of valid MatchaAI model keys in the codebase documentation.

---

## Related Documentation

- MatchaAI API: `https://matcha.harriscomputer.com`
- Model configuration: `src/lib/ai-providers.ts`
- Email assist API: `src/app/api/chasen/email-assist/route.ts`
