# Bug Report: Sign Out Blank Page and Unstyled Confirmation

**Date:** 9 January 2026
**Status:** Fixed
**Severity:** Medium
**Component:** Auth > Sign Out Flow

---

## Problem Description

When users signed out of the dashboard (either manually or via token refresh/session expiry), they encountered two issues:

1. **Blank Page**: The page would go blank and not automatically refresh or redirect to the sign-in page
2. **Unstyled Confirmation**: The NextAuth default sign-out confirmation page was not branded to match the login page styling

### User Impact

- Confusing user experience when signing out
- Users had to manually navigate to the login page
- Inconsistent branding between sign-in and sign-out pages
- Session expiry redirects resulted in a blank, unresponsive page

---

## Root Cause Analysis

1. **Missing Custom Sign-Out Page**: NextAuth 5 provides a default sign-out page at `/api/auth/signout` which shows an unstyled HTML form. No custom `signOut` page was defined in the NextAuth configuration.

2. **Improper Redirect Flow**: The sign-out functions in various components were using different approaches:
   - Some called `signOut({ redirect: false })` then tried to redirect manually
   - Some redirected to `/api/auth/signout` which shows the default NextAuth page
   - The `handleSessionExpired()` function called `signOut()` but didn't handle the redirect properly

3. **Token Expiry Flow**: When tokens expired, the `useTokenHealth` hook would call `signOut({ redirect: false })` followed by `signIn('azure-ad')`, which could fail silently and leave the page blank.

---

## Solution Implemented

### 1. Created Branded Sign-Out Page

**New file: `src/app/auth/signout/page.tsx`**

A new sign-out page that matches the login page styling with:
- Purple gradient background (same as sign-in)
- Altera logo
- Clear messaging for both manual sign-out and session expiry
- Auto sign-out for expired sessions (`?reason=session_expired`)
- Countdown and auto-redirect to sign-in after successful sign-out
- Option to clear SSO session completely (Microsoft logout)
- Success state with confirmation message

### 2. Updated NextAuth Configuration

**File: `src/auth.ts`**

Added the custom sign-out page to NextAuth pages config:

```typescript
pages: {
  signIn: '/auth/signin',
  signOut: '/auth/signout',  // Added
  error: '/auth/error',
},
```

### 3. Updated Session Manager

**File: `src/lib/session-manager.ts`**

Changed `handleSessionExpired()` to redirect to the styled sign-out page instead of calling `signOut()` directly:

```typescript
// Before
await signOut({ callbackUrl: redirectUrl })

// After
const signOutUrl = new URL('/auth/signout', window.location.origin)
signOutUrl.searchParams.set('reason', 'session_expired')
signOutUrl.searchParams.set('callbackUrl', redirectUrl)
window.location.href = signOutUrl.toString()
```

### 4. Updated Token Health Hook

**File: `src/hooks/useTokenHealth.tsx`**

Changed `signOutAndReauth()` to redirect to the styled sign-out page:

```typescript
// Before
await signOut({ redirect: false })
await signIn('azure-ad', { callbackUrl: window.location.pathname })

// After
const signOutUrl = new URL('/auth/signout', window.location.origin)
signOutUrl.searchParams.set('reason', 'session_expired')
signOutUrl.searchParams.set('callbackUrl', window.location.pathname)
window.location.href = signOutUrl.toString()
```

### 5. Updated Sign-Out Buttons

Updated all sign-out buttons to use the new styled page:

**Files changed:**
- `src/components/CommandPalette.tsx`
- `src/components/layout/sidebar.tsx`
- `src/components/layout/MobileDrawer.tsx`

```typescript
// Before
window.location.href = '/api/auth/signout'

// After
window.location.href = '/auth/signout'
```

---

## Files Changed

| File | Changes |
|------|---------|
| `src/app/auth/signout/page.tsx` | **NEW** - Branded sign-out page matching login styling |
| `src/auth.ts` | Added `signOut: '/auth/signout'` to pages config |
| `src/lib/session-manager.ts` | Updated `handleSessionExpired()` to redirect to new page |
| `src/hooks/useTokenHealth.tsx` | Updated `signOutAndReauth()` to redirect to new page |
| `src/components/CommandPalette.tsx` | Updated sign-out button URL |
| `src/components/layout/sidebar.tsx` | Updated sign-out button URL |
| `src/components/layout/MobileDrawer.tsx` | Updated sign-out button URL |

---

## Sign-Out Page Features

### Manual Sign-Out Flow
1. User clicks Sign Out button
2. Redirected to `/auth/signout`
3. Shows confirmation with options:
   - "Sign Out" - Clears local session only
   - "Sign Out & Clear SSO Session" - Also logs out from Microsoft
   - "Cancel" - Returns to previous page
4. After sign-out, shows success message with countdown
5. Auto-redirects to sign-in page after 5 seconds

### Session Expiry Flow
1. Token expires or refresh fails
2. System redirects to `/auth/signout?reason=session_expired`
3. Page auto-triggers sign-out (no confirmation needed)
4. Shows informative message about session expiry
5. Redirects to sign-in page

---

## Testing Steps

### Manual Sign-Out
1. Sign in to the dashboard
2. Click Sign Out from sidebar, command palette (⌘K), or mobile drawer
3. Verify branded sign-out confirmation page appears
4. Click "Sign Out"
5. Verify success message and countdown
6. Verify auto-redirect to sign-in page

### Session Expiry
1. Sign in to the dashboard
2. Wait for token to expire (or manually trigger via dev tools)
3. Verify redirect to sign-out page with expiry message
4. Verify auto sign-out and redirect to sign-in

### SSO Sign-Out
1. Sign in to the dashboard
2. Click Sign Out
3. Choose "Sign Out & Clear SSO Session"
4. Verify redirect to Microsoft logout then back to sign-in

---

## Design Alignment

The sign-out page now matches the sign-in page with:
- ✅ Purple gradient background (`from-purple-600 to-purple-800`)
- ✅ White card with shadow (`shadow-2xl rounded-lg`)
- ✅ Altera logo (32x32)
- ✅ Consistent button styling
- ✅ Footer with copyright
- ✅ Responsive design for mobile
- ✅ Loading spinner during sign-out

---

## Related Files

- Sign-in page: `src/app/auth/signin/page.tsx`
- Error page: `src/app/auth/error/page.tsx`
- Auth config: `src/auth.ts`
