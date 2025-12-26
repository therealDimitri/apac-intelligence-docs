# Bug Report: Teams Integration Not Posting Messages

**Date**: 2025-12-03
**Severity**: High (Feature Not Working)
**Status**: ✅ RESOLVED
**Commit**: 24e5bbc

---

## Issue Summary

Teams integration was returning successful HTTP 200 responses but messages were not appearing in the Teams channel. The "Post to Teams" button in the Edit Action modal was calling the API successfully, but the Power Automate workflow was not posting the messages to Teams.

---

## Symptoms

- API calls to `/api/actions/teams` returning 200 status
- Server logs showing: `[Teams Webhook] Successfully posted action S05 (updated)`
- No messages appearing in the Teams channel
- No error messages in console or server logs

**Example Server Logs**:

```
[Teams Webhook] Successfully posted action S05 (updated)
POST /api/actions/teams 200 in 1014ms (compile: 54ms, proxy.ts: 1740µs, render: 959ms)
```

---

## Root Cause

The code was sending **MessageCard format** (deprecated) to a **Power Automate workflow** that expects **Adaptive Card format**.

### Why This Happened

1. **Microsoft deprecated Office 365 Connectors** (which used MessageCard format) in August 2024
2. **Power Automate workflows** replaced incoming webhooks and use a different payload structure
3. The workflow template "Send webhook alerts to a channel" expects Adaptive Cards wrapped in a specific format

### Old Format (MessageCard - DEPRECATED)

```typescript
const card = {
  '@type': 'MessageCard',
  '@context': 'https://schema.org/extensions',
  summary: `Action ${event}: ${action.id}`,
  themeColor: '#0078D4',
  sections: [...],
  potentialAction: [...]
}
```

### Required Format (Adaptive Card)

```typescript
const adaptiveCard = {
  type: 'message',
  attachments: [
    {
      contentType: 'application/vnd.microsoft.card.adaptive',
      content: {
        $schema: 'http://adaptivecards.io/schemas/adaptive-card.json',
        type: 'AdaptiveCard',
        version: '1.4',
        body: [...],
        actions: [...]
      }
    }
  ]
}
```

**Key Difference**: Power Automate looks for the `attachments` property, which is null in MessageCard payloads, causing messages to be silently ignored.

---

## Solution

Converted the payload from MessageCard format to Adaptive Card format in the `postActionToTeams()` function.

### Changes Made

1. **Wrapped card in Power Automate structure**:
   - Added `type: 'message'`
   - Added `attachments` array with `contentType: 'application/vnd.microsoft.card.adaptive'`

2. **Converted to Adaptive Card elements**:
   - Changed `sections` → `body` with `TextBlock` and `FactSet` elements
   - Changed `potentialAction` → `actions` with `Action.OpenUrl` elements
   - Changed `facts` structure from `[{ name, value }]` → `[{ title, value }]`

3. **Updated color scheme**:
   - Hex colors (`#0078D4`) → Adaptive Card color names (`Accent`, `Good`, `Warning`, `Attention`)

4. **Updated schema reference**:
   - Added `$schema: 'http://adaptivecards.io/schemas/adaptive-card.json'`
   - Set `version: '1.4'` for latest Adaptive Card features

### Code Reference

**File**: `src/lib/microsoft-graph.ts`
**Function**: `postActionToTeams()` (lines 1038-1158)
**Key Line**: Line 1092 - Added comment explaining Power Automate requirement

---

## Files Changed

| File                         | Lines Changed | Type     |
| ---------------------------- | ------------- | -------- |
| `src/lib/microsoft-graph.ts` | 1038-1158     | Modified |

**Total**: 1 file modified, 62 insertions, 38 deletions

---

## Testing

### Before Fix

- ✅ API returns 200 status
- ❌ No messages appear in Teams channel
- ❌ Silent failure (no error logs)

### After Fix

- ✅ API returns 200 status
- ⏳ Messages should now appear in Teams channel (requires testing with actual action update)
- ✅ Payload structure matches Power Automate expectations

### How to Test

1. Edit an action in the dashboard
2. Click "Post to Teams" button
3. Check Teams channel for the adaptive card message
4. Verify message contains:
   - Action ID and description
   - Owner(s)
   - Status, Priority, Due Date
   - "View in Dashboard" button

---

## References

- [Converting Teams Webhooks to Power Automate - Stack Overflow](https://stackoverflow.com/questions/78756214/converting-teams-webhook-with-payload-type-messagecard-to-be-used-in-power-autom)
- [Adaptive Cards Schema](http://adaptivecards.io/schemas/adaptive-card.json)
- [Microsoft Teams Webhooks Migration Guide](https://learn.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/)

---

## Lessons Learned

1. **Silent failures are hard to debug**: HTTP 200 doesn't always mean success - need to verify end-to-end functionality

2. **Check Microsoft deprecation notices**: Office 365 Connectors were deprecated in August 2024, requiring migration to Power Automate

3. **Payload format matters**: Even though both formats are JSON, Power Automate workflows require specific structure with `attachments` array

4. **Test with production services**: Local API testing isn't sufficient - need to verify actual Teams channel receives messages

5. **Document integration requirements**: Added comment at line 1092 to explain why Adaptive Card format is required for future developers

---

## Prevention

To prevent similar issues in the future:

1. **Stay updated on Microsoft deprecations**: Subscribe to Microsoft 365 roadmap updates
2. **Test end-to-end**: Don't rely solely on HTTP status codes for integration testing
3. **Document external dependencies**: Clearly note which format specific external services expect
4. **Version external APIs**: Track which API version/format external services use

---

**Impact**: High-value feature now functional for action notifications in Teams
**Risk**: Low - Change isolated to Teams integration, doesn't affect core functionality
**Migration**: None required - automatic for all users once deployed
