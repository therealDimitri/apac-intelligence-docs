# Bug Report: Teams Integration Complete Fix - Multiple Issues Resolved

**Date**: 2025-12-03
**Severity**: High (Feature Completely Broken → Fully Functional)
**Status**: ✅ RESOLVED
**Commits**: 24e5bbc, 380965f, b87c9f2, 537931c, ce62fde, f790edc, 3917fa3

---

## Executive Summary

Teams integration feature underwent complete overhaul to resolve multiple blocking issues preventing action notifications from posting to Microsoft Teams. Started with deprecated MessageCard format issue, discovered dashboard URL misconfiguration, encountered TypeScript compilation errors, debugged URL parsing failures, and implemented @mentions feature for owner notifications.

**Total Issues Resolved**: 6 major issues
**Files Modified**: 3 (`microsoft-graph.ts`, `route.ts`, `EditActionModal.tsx`)
**Lines Changed**: ~200 lines across all commits

---

## Issue 1: Deprecated MessageCard Format

### Symptoms

- API calls to `/api/actions/teams` returning 200 status
- Server logs showing success: `[Teams Webhook] Successfully posted action`
- **No messages appearing in Teams channel**
- No error messages in console or server logs

### Root Cause

Code was sending **MessageCard format** (deprecated August 2024) to **Power Automate workflow** that expects **Adaptive Card format**. Power Automate looks for `attachments` property which is null in MessageCard payloads, causing silent failures.

### Solution (Commit: 24e5bbc)

**File**: `src/lib/microsoft-graph.ts` (lines 1038-1158)

Converted entire payload structure:

**Before** (MessageCard - DEPRECATED):

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

**After** (Adaptive Card v1.4):

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
        body: [
          {
            type: 'TextBlock',
            text: `${iconMap[event]} Action ${event}`,
            size: 'Large',
            weight: 'Bolder',
            color: colorMap[event] || 'Accent',
          },
          // ... more elements
        ],
        actions: [
          {
            type: 'Action.OpenUrl',
            title: 'View in Dashboard',
            url: `${dashboardUrl}/actions?action=${action.id}`,
          },
        ],
      },
    },
  ],
}
```

**Key Changes**:

- Wrapped in Power Automate structure: `{ type: 'message', attachments: [...] }`
- Changed `sections` → `body` with TextBlock and FactSet elements
- Changed `potentialAction` → `actions` with Action.OpenUrl
- Changed `facts` from `[{ name, value }]` → `[{ title, value }]`
- Updated colors from hex (`#0078D4`) → named colors (`Accent`, `Good`, `Warning`, `Attention`)

### Verification

✅ Messages now appear in Teams channel
✅ Adaptive Card renders with proper formatting
✅ All action details displayed correctly

---

## Issue 2: Dashboard URL Misconfiguration

### Symptoms

- "View in Dashboard" button linked to: `https://apac-intelligence.alteradigitalhealth.com`
- **Domain does not exist** - DNS resolution failure
- Users unable to navigate from Teams card to action details

### Root Cause

Dashboard URL was hardcoded to non-existent domain instead of using environment variable configuration.

### Solution (Commit: 380965f)

**File**: `src/app/api/actions/teams/route.ts` (lines 35-36, 51)

**Before**:

```typescript
await postActionToTeams(webhookUrl, action, event)
// Used hardcoded URL inside postActionToTeams function
```

**After**:

```typescript
// Get dashboard URL from environment variable (falls back to default if not set)
const dashboardUrl = process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3001'

await postActionToTeams(webhookUrl, action, event, dashboardUrl)
```

**Environment Variable**:

- Local: `.env.local` → `NEXT_PUBLIC_APP_URL=https://apac-cs-dashboards.com`
- Production: Netlify environment variables → same value

### Verification

✅ "View in Dashboard" button now links to: `https://apac-cs-dashboards.com/actions?action=S05`
✅ Links work correctly from Teams cards
✅ URL configurable per environment

---

## Issue 3: TypeScript Compilation Error - Type Narrowing

### Symptoms

- Build failed with error: `Property 'split' does not exist on type 'never'`
- **Error location**: `EditActionModal.tsx:85`
- Deployment blocked - cannot push to production

### Root Cause

Complex inline type checking confused TypeScript's type narrowing:

```typescript
owners: Array.isArray(action.owners)
  ? action.owners
  : action.owners
    ? action.owners
        .split(',')
        .map(o => o.trim())
        .filter(Boolean)
    : []
```

TypeScript couldn't determine type in the nested ternary, treating `action.owners` as `never`.

### Solution (Commit: b87c9f2)

**File**: `src/components/EditActionModal.tsx` (lines 74-83)

Created dedicated helper function with explicit typing:

```typescript
// Helper to normalize owners to array - handles both string and array types
const normalizeOwnersToArray = (owners: string | string[]): string[] => {
  if (Array.isArray(owners)) {
    return owners
  }
  if (typeof owners === 'string' && owners.length > 0) {
    return owners
      .split(',')
      .map(o => o.trim())
      .filter(Boolean)
  }
  return []
}
```

**Usage** (lines 96, 138):

```typescript
owners: normalizeOwnersToArray(action.owners), // Handle both array and string
```

### Verification

✅ TypeScript compilation succeeds
✅ Build completes without errors
✅ Type safety maintained with cleaner code

---

## Issue 4: Teams Webhook URL Parsing Failure

### Symptoms

- API calls failing with: `TypeError: Failed to parse URL from https://defaultd4066c3617ca4e3395d20db68e4490.0f.environment.api.powerplat   form.com:443/...`
- Note the **spaces in URL**: `powerplat   form.com` should be `powerplatform.com`
- Modal showed "Posted to Microsoft Teams!" but messages not appearing

### Root Cause

When pasting long webhook URL into Netlify environment variables, the text wrapped across multiple lines and introduced spaces:

- `powerplat   form.com` instead of `powerplatform.com`
- `143f0018bea94e91bf   bbfd36e07ea36a` instead of `143f0018bea94e91bfbbfd36e07ea36a`

### Debugging Process (Commit: 537931c)

**File**: `src/lib/microsoft-graph.ts` (lines 1135-1151)

Added detailed logging to identify issue:

```typescript
try {
  const payload = JSON.stringify(adaptiveCard)
  console.log('[Teams Webhook] Sending payload:', payload.substring(0, 500) + '...')

  const response = await fetch(webhookUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: payload,
  })

  const responseText = await response.text()
  console.log('[Teams Webhook] Response:', {
    status: response.status,
    statusText: response.statusText,
    body: responseText,
  })
}
```

Netlify logs revealed malformed URL with spaces.

### Solution

**Configuration Fix** (No code changes needed):

1. User edited `TEAMS_WEBHOOK_URL` in Netlify dashboard
2. Ensured entire URL on single line with no spaces
3. Redeployed

**Correct URL Format**:

```
https://defaultd4066c3617ca4e3395d20db68e4490.0f.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/143f0018bea94e91bfbbfd36e07ea36a/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=LhEXFizniXRDMvf8PSOBFREir2_Vt5ObzJpASDBRKxU
```

### Verification

✅ URL parsing succeeds
✅ Webhook calls complete successfully
✅ Messages appear in Teams channel

### Prevention

- Document requirement to keep webhook URL on single line
- Add URL validation in deployment pipeline
- Consider using Netlify UI's "paste" button instead of manual text entry

---

## Issue 5: @Mentions Implementation

### User Requirement

"Can I send msgs to individuals?"

**Requirement**: Notify specific action owners while keeping messages in shared channel for transparency.

**Solution**: Microsoft Teams @mentions using `msteams.entities`

### Implementation (Commits: ce62fde, f790edc)

**File**: `src/lib/microsoft-graph.ts` (lines 1092-1122)

#### Step 1: Build Mention Entities

```typescript
// Build @mentions for owners
const mentions: Array<{
  type: string
  text: string
  mentioned: { id: string; name: string }
}> = []
let mentionText = ''

if (action.owners && action.owners.length > 0) {
  const owners = action.owners // Store in const for type safety
  owners.forEach((ownerName, index) => {
    // Convert name to email (firstname.lastname@alterahealth.com format)
    const nameParts = ownerName.toLowerCase().split(' ')
    const email =
      nameParts.length >= 2
        ? `${nameParts[0]}.${nameParts[nameParts.length - 1]}@alterahealth.com`
        : `${nameParts[0]}@alterahealth.com`

    mentions.push({
      type: 'mention',
      text: `<at>${ownerName}</at>`,
      mentioned: {
        id: email,
        name: ownerName,
      },
    })

    // Build mention text: "Alice", "Alice and Bob", "Alice, Bob and Charlie"
    if (index === 0) {
      mentionText = `<at>${ownerName}</at>`
    } else if (index === owners.length - 1) {
      mentionText += ` and <at>${ownerName}</at>`
    } else {
      mentionText += `, <at>${ownerName}</at>`
    }
  })
}
```

#### Step 2: Add Mention Text to Card Body (lines 1147-1152)

```typescript
...(mentionText ? [{
  type: 'TextBlock',
  text: `👤 ${mentionText}`,
  wrap: true,
  spacing: 'Small',
}] : []),
```

#### Step 3: Add Teams Entities (lines 1166-1170)

```typescript
...(mentions.length > 0 ? {
  msteams: {
    entities: mentions
  }
} : {})
```

### Email Domain Fix (Commit: f790edc)

**Initial Implementation**: Used `@alteradigitalhealth.com`
**Correction**: Changed to `@alterahealth.com` (lines 1101-1102)

**User Feedback**: "the correct domain is firstname.lastname@alterahealth.com"

### Verification

✅ Action owners receive personal notifications
✅ Messages visible in shared channel for transparency
✅ @mentions render correctly in Teams
✅ Email addresses follow correct format: `firstname.lastname@alterahealth.com`

### Example Output

For action with owners "Jimmy Leimonitis" and "Sarah Chen":

- Mention entities created with:
  - jimmy.leimonitis@alterahealth.com
  - sarah.chen@alterahealth.com
- Card displays: "👤 @Jimmy Leimonitis and @Sarah Chen"
- Both users receive personal notifications

---

## Issue 6: TypeScript Error - Possibly Undefined

### Symptoms

- Build failed with error: `'action.owners' is possibly 'undefined'`
- **Error location**: `microsoft-graph.ts:1115`
- Occurred in @mentions implementation inside forEach loop

### Root Cause

TypeScript couldn't guarantee `action.owners` wasn't undefined inside the forEach loop, even though it was checked in the parent if statement:

```typescript
if (action.owners && action.owners.length > 0) {
  action.owners.forEach((ownerName, index) => {
    // ...
    } else if (index === action.owners.length - 1) {
      // ^^^^ TypeScript error: action.owners is possibly undefined
    }
  })
}
```

### Solution (Commit: 3917fa3)

**File**: `src/lib/microsoft-graph.ts` (line 1097, 1116)

Store `action.owners` in a const variable for proper type narrowing:

```typescript
if (action.owners && action.owners.length > 0) {
  const owners = action.owners // Store in const for type safety
  owners.forEach((ownerName, index) => {
    // ...
    if (index === 0) {
      mentionText = `<at>${ownerName}</at>`
    } else if (index === owners.length - 1) {
      // ✅ Now uses const variable
      mentionText += ` and <at>${ownerName}</at>`
    } else {
      mentionText += `, <at>${ownerName}</at>`
    }
  })
}
```

### Verification

✅ TypeScript compilation succeeds
✅ Build completes without errors
✅ Deployment successful

---

## Summary of All Changes

### Files Modified

| File                                 | Total Changes | Commits                                     |
| ------------------------------------ | ------------- | ------------------------------------------- |
| `src/lib/microsoft-graph.ts`         | ~150 lines    | 24e5bbc, 537931c, ce62fde, f790edc, 3917fa3 |
| `src/app/api/actions/teams/route.ts` | ~15 lines     | 380965f                                     |
| `src/components/EditActionModal.tsx` | ~15 lines     | b87c9f2                                     |

### Commits Timeline

1. **24e5bbc** - Convert MessageCard to Adaptive Card format
2. **380965f** - Fix dashboard URL using environment variables
3. **b87c9f2** - Fix TypeScript type narrowing with helper function
4. **537931c** - Add detailed logging for debugging
5. **ce62fde** - Implement @mentions for action owners
6. **f790edc** - Fix email domain to @alterahealth.com
7. **3917fa3** - Fix TypeScript error with const variable

### Impact Assessment

**Before Fixes**:

- ❌ Teams integration completely non-functional
- ❌ Messages not appearing in channel
- ❌ Dashboard links pointing to wrong domain
- ❌ Build failures preventing deployment
- ❌ No individual notifications for action owners

**After Fixes**:

- ✅ Teams integration fully functional
- ✅ Beautiful Adaptive Card messages in channel
- ✅ Dashboard links working correctly
- ✅ Clean builds and successful deployments
- ✅ Action owners receive personal @mentions
- ✅ Transparency maintained with channel visibility

---

## Testing Checklist

### Manual Testing Performed

- [x] Edit action in dashboard
- [x] Click "Post to Teams" button
- [x] Verify message appears in Teams channel
- [x] Check Adaptive Card formatting
- [x] Click "View in Dashboard" button
- [x] Verify correct URL navigation
- [x] Confirm action owners receive @mention notifications
- [x] Test with single owner
- [x] Test with multiple owners
- [x] Verify email format (firstname.lastname@alterahealth.com)

### Build & Deployment Testing

- [x] Local build succeeds (`npm run build`)
- [x] TypeScript compilation passes (`npx tsc --noEmit`)
- [x] Netlify deployment succeeds
- [x] Production environment variables configured
- [x] Environment variable validation

---

## Lessons Learned

### 1. Silent Failures Are Dangerous

HTTP 200 status codes don't guarantee end-to-end functionality. Always verify the complete user flow, not just API responses.

**Action Item**: Implement end-to-end integration tests for critical workflows like Teams notifications.

### 2. Microsoft Deprecation Awareness

Office 365 Connectors deprecated August 2024, requiring migration to Power Automate workflows with different payload formats.

**Action Item**: Subscribe to Microsoft 365 roadmap and deprecation notices to stay ahead of breaking changes.

### 3. Environment Variable Validation

Long URLs can break when pasted across multiple lines in configuration UIs, introducing hidden spaces.

**Action Item**: Add URL validation in deployment pipeline to catch malformed environment variables early.

### 4. TypeScript Type Safety

Complex inline type checking can confuse TypeScript's type narrowing. Helper functions with explicit types improve both safety and readability.

**Action Item**: Prefer dedicated helper functions over inline ternary operators for type conversions.

### 5. Progressive Debugging

Adding detailed logging (commit 537931c) was crucial for identifying the URL parsing issue that appeared as a silent failure.

**Action Item**: Maintain comprehensive logging for external API integrations, especially webhooks.

---

## References

- [Converting MessageCard to Adaptive Card - Stack Overflow](https://stackoverflow.com/questions/78756214/converting-teams-webhook-with-payload-type-messagecard-to-be-used-in-power-autom)
- [Adaptive Cards Schema v1.4](http://adaptivecards.io/schemas/adaptive-card.json)
- [Microsoft Teams Webhooks Migration Guide](https://learn.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/)
- [Teams @Mentions Documentation](https://learn.microsoft.com/en-us/microsoftteams/platform/task-modules-and-cards/cards/cards-format#mention-support-within-adaptive-cards)

---

## Risk Assessment

**Risk Level**: Low

- Changes isolated to Teams integration module
- No impact on core dashboard functionality
- All changes tested in production environment
- Rollback plan: Revert commits if needed (unlikely - feature was broken before)

**Migration Required**: None

- Automatic for all users once deployed
- No database schema changes
- No breaking API changes

---

**Feature Status**: ✅ Fully Functional
**Production Ready**: Yes
**User Impact**: High - Critical communication feature now working
**Business Value**: Enables real-time action tracking and owner notifications in Teams
