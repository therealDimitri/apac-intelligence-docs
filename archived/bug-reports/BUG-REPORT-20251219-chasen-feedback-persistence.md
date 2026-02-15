# Bug Report: ChaSen Feedback State Persisting Across New Chats

**Date**: 2025-12-19
**Status**: RESOLVED
**Severity**: Medium
**Component**: ChaSen AI - Response Modal Feedback

---

## Issue Summary

The ChaSen Response Modal was incorrectly displaying feedback status (e.g., "✓ Marked as helpful") from previous responses when asking new questions. New chats did not show the feedback options (thumbs up/down/missing info buttons).

## Symptoms

- Response Modal showed "✓ Marked as helpful" even for brand new questions
- Feedback buttons (thumbs up/down/help) were not visible for new responses
- Users could not provide feedback on new responses
- Previous feedback incorrectly carried over to unrelated responses

## Root Cause

The `messageFeedback` state was not being reset when new questions were submitted. The state tracked feedback using a fixed key `'response-modal'`, which persisted across different questions:

```typescript
// Feedback state persisted even when new questions were asked
const [messageFeedback, setMessageFeedback] = useState<
  Record<string, 'helpful' | 'not_helpful' | 'missing_info'>
>({})

// Response Modal checked this fixed key
{messageFeedback['response-modal'] ? (
  <span>✓ Marked as helpful</span>
) : (
  // Show feedback buttons
)}
```

The three question handlers (`handleSuggestionClick`, `handleCustomSubmit`, `handleFollowUpClick`) did not clear this feedback state when initiating new questions.

## Solution

Added feedback state reset logic to all three question handlers:

```typescript
// Reset feedback state for new response
setMessageFeedback(prev => {
  const { 'response-modal': _, ...rest } = prev
  return rest
})
```

**Applied to:**

1. `handleSuggestionClick` - When clicking a suggestion prompt
2. `handleCustomSubmit` - When submitting a custom question
3. `handleFollowUpClick` - When clicking a follow-up question

## Files Modified

1. `src/components/FloatingChaSenAI.tsx` - Added feedback reset in three handlers

## Impact

- Each new response now correctly shows feedback options
- Users can provide feedback on every individual response
- Previous feedback no longer carries over to new questions
- Feedback tracking is accurate per-response

## Verification

After fix:

- Ask a question → Response shows feedback buttons (thumbs up/down)
- Click "helpful" → Shows "✓ Marked as helpful"
- Ask a new question → Response shows feedback buttons again (reset)
- Previous feedback does not appear on new responses

---

## Lessons Learned

1. **State management with fixed keys** - When using fixed keys for temporary state, ensure they are reset when the context changes
2. **Test state transitions** - Verify that state is properly reset between different user actions
3. **Feedback UX** - Users should always be able to provide feedback on new responses
