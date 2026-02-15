# Bug Report: ChaSen Conversation API 400 Errors

**Date:** 25 December 2024
**Status:** FIXED
**Component:** ChaSen AI Conversation Persistence
**Commits:** e8007e0, 9a5c732

## Issue Description

ChaSen was returning 400 errors when trying to create and save conversations. This prevented chat history from being persisted, though the chat functionality itself still worked.

## Root Causes

Two field name mismatches between the AI page and the API:

### Issue 1: Invalid Context Value

**File:** `src/app/(dashboard)/ai/page.tsx` line 1219

The AI page was sending `context: 'chasen-page'` but the API validates against:

```typescript
const validContexts = ['portfolio', 'client', 'general']
```

**Fix:** Changed to `context: 'portfolio'`

### Issue 2: Wrong Field Name for Message Content

**File:** `src/app/(dashboard)/ai/page.tsx` line 1244

The AI page was sending `content` but the API expects `message_content`:

```typescript
// Before
body: JSON.stringify({
  message_type: type,
  content, // ❌ Wrong field name
})

// After
body: JSON.stringify({
  message_type: type,
  message_content: content, // ✅ Correct field name
})
```

## Verification

After fixes, all conversation API calls return success:

| Endpoint                                       | Status | Description          |
| ---------------------------------------------- | ------ | -------------------- |
| `POST /api/chasen/conversations`               | 201    | Conversation created |
| `POST /api/chasen/conversations/{id}/messages` | 201    | Messages saved       |
| `GET /api/chasen/conversations?limit=10`       | 200    | Conversations listed |

The "Recent Chats" sidebar now shows conversation previews with the last message.

## Lessons Learned

1. **Field name consistency** - Always verify request body field names match API expectations
2. **Enum validation** - When APIs validate against allowed values, check the source of truth
3. **Test the full flow** - The main chat worked, but persistence was silently failing

## Related Bug Reports

- `BUG-REPORT-20251224-chasen-timeout-fix.md` - Initial timeout fix
- `BUG-REPORT-20251224-chasen-streaming-heartbeat-fix.md` - Heartbeat streaming
- `BUG-REPORT-20251224-chasen-native-ai-sdk-bypass-fix.md` - Native SDK bypass
