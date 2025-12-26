# Bug Report: Outlook Email Draft Links Not Clickable

**Date:** 26 December 2025
**Status:** Resolved
**Severity:** Medium
**Component:** ChaSen AI - Send to Outlook Feature

---

## Summary

When clicking the "Send to Outlook" button on email drafts in ChaSen AI, dashboard action links were displayed as plain text URLs instead of clickable hyperlinks. Users had to manually copy and paste URLs, defeating the purpose of including them.

---

## Symptoms

1. Email opens in Outlook with links showing as plain text: `View Actions (https://apac-cs-dashboards.netlify.app/actions?client=SA%20Health)`
2. Links were not clickable - users couldn't click to navigate
3. Professional appearance diminished by long URL strings

---

## Root Cause Analysis

### Initial Approach: `mailto:` Protocol

The first implementation used the `mailto:` protocol:

```typescript
const mailtoLink = `mailto:?body=${encodeURIComponent(emailCheck.body)}`
window.open(mailtoLink, '_blank')
```

**Problem:** The `mailto:` protocol (RFC 6068) only supports plain text bodies. Browsers strip HTML tags for security.

### Second Attempt: Outlook Web Compose with `body` Parameter

Changed to Outlook Web deeplink:

```typescript
const url = `https://outlook.office.com/mail/deeplink/compose?body=${encodeURIComponent(htmlBody)}`
```

**Problem:** The `body` parameter still renders as plain text, showing `<a href>` tags as literal text.

### Third Attempt: Outlook Web Compose with `htmlbody` Parameter

Tried using `htmlbody` instead of `body`:

```typescript
const url = `https://outlook.office.com/mail/deeplink/compose?htmlbody=${encodeURIComponent(htmlBody)}`
```

**Problem:** Outlook opened with completely empty body - parameter not supported.

### Interim Solution: Clipboard Copy

Implemented clipboard API with HTML content:

```typescript
const blob = new Blob([emailCheck.htmlBody], { type: 'text/html' })
await navigator.clipboard.write([
  new ClipboardItem({
    'text/html': blob,
    'text/plain': new Blob([emailCheck.body], { type: 'text/plain' }),
  }),
])
```

**Problem:** Required manual paste into Outlook - not ideal UX.

---

## Final Solution: Microsoft Graph API

Created a proper email draft directly in Outlook's Drafts folder using Microsoft Graph API with full HTML support.

### Key Changes

#### 1. New Function: `createEmailDraft()` in `src/lib/microsoft-graph.ts`

```typescript
export async function createEmailDraft(
  accessToken: string,
  draft: EmailDraft
): Promise<{ id: string; webLink: string }> {
  const bodyContent = draft.htmlBody || draft.body
  const contentType = draft.htmlBody ? 'HTML' : 'Text'

  const messagePayload = {
    subject: draft.subject || '',
    body: { contentType, content: bodyContent },
    // ... recipients handling
  }

  const response = await fetch(`${GRAPH_API_BASE_URL}/me/messages`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(messagePayload),
  })

  const createdDraft = await response.json()
  return {
    id: createdDraft.id,
    webLink: createdDraft.webLink || 'https://outlook.office.com/mail/drafts',
  }
}
```

#### 2. New API Endpoint: `src/app/api/outlook/draft/route.ts`

- Authenticates user via existing auth system
- Validates request body (requires `body` or `htmlBody`)
- Calls `createEmailDraft()` with user's MS access token
- Returns draft ID and webLink for opening in Outlook
- Handles errors gracefully (401 for expired token, 403 for permissions)

#### 3. Updated Button in `src/app/(dashboard)/ai/page.tsx`

```typescript
onClick={async (e) => {
  const btn = e.currentTarget
  try {
    // Show loading state
    btn.querySelector('span')!.textContent = 'Creating...'

    // Call API to create draft
    const response = await fetch('/api/outlook/draft', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        subject,
        body: emailCheck.body,
        htmlBody: emailCheck.htmlBody,
      }),
    })

    // Open draft in Outlook
    window.open(result.webLink, '_blank')
  } catch (error) {
    // Fallback: copy to clipboard with HTML
    await navigator.clipboard.write([...])
  }
}
```

---

## Files Modified

| File                                 | Changes                                                                                 |
| ------------------------------------ | --------------------------------------------------------------------------------------- |
| `src/lib/microsoft-graph.ts`         | Added `EmailDraft` interface with `htmlBody` field; Added `createEmailDraft()` function |
| `src/app/api/outlook/draft/route.ts` | **NEW** - API endpoint for creating drafts via Graph API                                |
| `src/app/(dashboard)/ai/page.tsx`    | Updated button to call API first, fall back to clipboard on error                       |

---

## Testing Performed

1. Generated email draft in ChaSen AI with action links
2. Clicked "Send to Outlook" button
3. Verified API endpoint was called (`POST /api/outlook/draft`)
4. With expired token: Fallback to clipboard worked ("Copied!" shown)
5. Button showed loading states: "Creating..." → "Opening..." or "Copied!"
6. TypeScript check passed (`npx tsc --noEmit`)

---

## Expected Behaviour (With Valid MS Token)

1. Click "Send to Outlook" → Button shows "Creating..."
2. Draft created in Outlook Drafts folder with proper HTML
3. Button shows "Opening..." → Outlook Web opens to the draft
4. Links display as **clickable underlined text** (not raw URLs)
5. Clicking links navigates to dashboard pages

---

## Fallback Behaviour (Token Expired/Missing)

1. API returns 401/403
2. Button shows "Error" briefly
3. Automatically copies HTML to clipboard
4. Button shows "Copied!"
5. User can paste into Outlook (HTML preserved)

---

## Permissions Required

The Microsoft Graph API requires the `Mail.ReadWrite` permission scope to create email drafts. Users may need to re-authenticate if this permission wasn't previously granted.

---

## Architecture Diagram

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  ChaSen AI      │────▶│ /api/outlook/    │────▶│ Microsoft Graph │
│  "Send to       │     │    draft         │     │ POST /me/       │
│   Outlook"      │     │                  │     │    messages     │
└─────────────────┘     └──────────────────┘     └─────────────────┘
        │                        │                        │
        │                        ▼                        ▼
        │               ┌──────────────────┐     ┌─────────────────┐
        │               │ Auth check       │     │ Draft created   │
        │               │ Access token     │     │ in Drafts folder│
        │               └──────────────────┘     └─────────────────┘
        │                                                 │
        ▼                                                 ▼
┌─────────────────┐                              ┌─────────────────┐
│ Fallback:       │                              │ Opens webLink   │
│ Clipboard copy  │                              │ in Outlook Web  │
└─────────────────┘                              └─────────────────┘
```

---

## Related Files

- `src/app/(dashboard)/ai/page.tsx` - Main ChaSen AI page with email detection
- `src/lib/microsoft-graph.ts` - Microsoft Graph API client library
- `docs/BUG-REPORT-20251226-email-draft-formatting.md` - Related email formatting fix
- `docs/BUG-REPORT-20251226-user-message-link-rendering.md` - Related markdown link fix
