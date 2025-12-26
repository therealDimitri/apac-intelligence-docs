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

## Root Cause

The implementation used the `mailto:` protocol which only supports plain text bodies:

```typescript
// Old implementation
const mailtoLink = `mailto:?body=${encodeURIComponent(emailCheck.body)}`
window.open(mailtoLink, '_blank')
```

The `mailto:` protocol specification (RFC 6068) explicitly states that the body parameter is plain text only - no HTML formatting is supported. Browsers strip any HTML tags for security reasons.

---

## Solution

Changed to use Outlook Web's compose deeplink URL which supports HTML body content:

```typescript
// New implementation
const outlookComposeUrl = `https://outlook.office.com/mail/deeplink/compose?body=${encodeURIComponent(emailCheck.htmlBody)}`
window.open(outlookComposeUrl, '_blank')
```

### Key Changes:

1. **Dual output from `detectEmailDraft()`** - Function now returns both `body` (plain text) and `htmlBody` (HTML)

2. **HTML body with anchor tags**:

   ```typescript
   // Convert markdown links to HTML anchor tags
   .replace(/\[([^\]]+)\]\(((?:[^()]|\([^)]*\))+)\)/g, (_, text, url) => {
     const fullUrl = url.startsWith('/') ? `${baseUrl}${url}` : url
     return `<a href="${fullUrl}">${text}</a>`
   })
   ```

3. **Full URL conversion** - Internal links (starting with `/`) are converted to absolute URLs using `window.location.origin`

4. **HTML formatting** - Bold text converted to `<strong>`, italic to `<em>`, line breaks to `<br><br>`

---

## Files Modified

### `src/app/(dashboard)/ai/page.tsx`

**Change 1:** Updated `detectEmailDraft()` return type and implementation (lines 219-313)

```typescript
// Before
function detectEmailDraft(message: string): { isEmail: boolean; body: string }

// After
function detectEmailDraft(message: string): { isEmail: boolean; body: string; htmlBody: string }
```

**Change 2:** Updated Send to Outlook button to use Outlook Web compose URL (lines 3318-3323)

```typescript
// Before
const mailtoLink = `mailto:?body=${encodeURIComponent(emailCheck.body)}`
window.open(mailtoLink, '_blank')

// After
const outlookComposeUrl = `https://outlook.office.com/mail/deeplink/compose?body=${encodeURIComponent(emailCheck.htmlBody)}`
window.open(outlookComposeUrl, '_blank')
```

### `src/app/api/chasen/email-assist/route.ts`

**Bonus fix:** Corrected `applyRateLimit` and `createErrorResponse` function calls to match updated signatures.

---

## Testing Performed

1. Generated an email draft in ChaSen AI about a client with action items
2. Verified email included markdown links to dashboard pages
3. Clicked "Send to Outlook" button
4. Verified Outlook Web opened with email compose
5. Verified links displayed as clickable hyperlinks (not plain text)
6. Clicked links to confirm navigation to correct dashboard pages
7. TypeScript check passed (`npx tsc --noEmit`)
8. Pre-commit hooks passed (ESLint, Prettier, TypeScript)

---

## Before/After Comparison

### Before (Broken)

- Link showed as: `View Actions (https://apac-cs-dashboards.netlify.app/actions?client=SA%20Health)`
- Not clickable - users had to copy/paste URL
- Unprofessional appearance with long URL strings

### After (Fixed)

- Link shows as: `View Actions` (underlined, clickable)
- Clicking navigates directly to dashboard
- Clean, professional email appearance

---

## Trade-offs

1. **Requires Outlook Web** - The deeplink URL opens Outlook Web, not the desktop Outlook app
2. **Microsoft account required** - User must be signed into their Microsoft account
3. **HTML support** - Outlook Web correctly renders HTML links, but plain text fallback is available in `body` property if needed in future

---

## Related Files

- `src/app/(dashboard)/ai/page.tsx` - Main ChaSen AI page with email detection and rendering
- `docs/BUG-REPORT-20251226-email-draft-formatting.md` - Related email formatting fix
- `docs/BUG-REPORT-20251226-user-message-link-rendering.md` - Related markdown link fix
