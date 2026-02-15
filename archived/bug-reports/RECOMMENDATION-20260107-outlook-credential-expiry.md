# Recommendation: Outlook Credential Expiry Workflow

**Date**: 7 January 2026
**Status**: Documented
**Severity**: Enhancement
**Component**: Authentication & Session Management

## Current Implementation

The dashboard already has a comprehensive token health monitoring system:

### Existing Components

1. **`useTokenHealth` hook** (`src/hooks/useTokenHealth.tsx`)
   - Monitors token expiration
   - Triggers proactive refresh 2 minutes before expiry
   - Provides `isExpiringSoon`, `isExpired`, `isHealthy` states
   - Offers `refreshSession()` and `signOutAndReauth()` actions
   - Warning threshold: 10 minutes before expiry

2. **`session-manager.ts`** (`src/lib/session-manager.ts`)
   - Parses API errors and identifies session expiration
   - Handles Azure AD specific error codes (AADSTS50173, AADSTS70008, etc.)
   - Provides `fetchWithSession()` wrapper with automatic session handling
   - Differentiates between auth, network, validation, and API errors

3. **`TokenHealthDebug` component** (for development)
   - Visual indicator showing token status in bottom-left corner
   - Shows time until expiry and error states

## Workflow Overview

```
┌──────────────────────────────────────────────────────────────┐
│                    TOKEN LIFECYCLE                            │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│   [User Signs In]                                             │
│         ↓                                                     │
│   [Token Valid] ──→ Normal operation                          │
│         ↓                                                     │
│   [10min before expiry] ──→ isExpiringSoon = true            │
│         ↓                                                     │
│   [2min before expiry] ──→ Proactive refresh triggered       │
│         ↓                                                     │
│   [Refresh Success] ──→ Continue normal operation            │
│         or                                                    │
│   [Refresh Failed] ──→ Show re-auth prompt                   │
│         ↓                                                     │
│   [Token Expired] ──→ isExpired = true, redirect to sign-in  │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

## Recommended Improvements

### 1. User-Facing Warning Banner

Add a visible warning banner when `isExpiringSoon` is true:

```tsx
// In layout.tsx or dashboard wrapper
import { useTokenHealth } from '@/hooks/useTokenHealth'

function TokenWarningBanner() {
  const { isExpiringSoon, timeUntilExpiry, refreshSession, isRefreshing } = useTokenHealth()

  if (!isExpiringSoon) return null

  const minutesLeft = Math.round((timeUntilExpiry || 0) / 1000 / 60)

  return (
    <div className="fixed top-0 left-0 right-0 z-50 bg-amber-500 text-white px-4 py-2 flex items-center justify-between">
      <span>
        ⚠️ Your Outlook session expires in {minutesLeft} minutes
      </span>
      <button
        onClick={refreshSession}
        disabled={isRefreshing}
        className="bg-white text-amber-600 px-3 py-1 rounded text-sm font-medium"
      >
        {isRefreshing ? 'Refreshing...' : 'Extend Session'}
      </button>
    </div>
  )
}
```

### 2. Outlook Sync Status Indicator

Add visual feedback in the Outlook sync button:

```tsx
// In OutlookSyncButton.tsx
const { isHealthy, isExpiringSoon, isExpired } = useTokenHealth()

// Show different states:
// - Green dot: Token healthy
// - Amber dot: Token expiring soon
// - Red dot: Token expired, needs re-auth
```

### 3. Proactive Email Notification

Consider sending email notifications when tokens are about to expire:

```typescript
// Cron job (daily)
// Check all users with tokens expiring in next 24 hours
// Send reminder email to re-authenticate
```

### 4. Session Persistence

Store last successful auth timestamp for analytics:

```typescript
// In auth callback
const { data } = await supabase
  .from('cse_profiles')
  .update({ last_ms_auth: new Date().toISOString() })
  .eq('email', session.user.email)
```

### 5. Graceful Degradation

When Outlook sync fails, features should degrade gracefully:

| Feature | With Token | Without Token |
|---------|-----------|---------------|
| Outlook Import | ✓ Full access | ✗ Disabled with message |
| Calendar Sync | ✓ Real-time | ✗ Disabled with message |
| Teams Meeting | ✓ Create links | ✗ Manual link entry |
| People Search | ✓ Organisation lookup | ⚠️ Manual name entry |
| Meeting Schedule | ✓ Sync to Outlook | ⚠️ Dashboard-only |

## Error Messages

| Scenario | Message |
|----------|---------|
| Token expiring | "Your Outlook session expires in X minutes. Click to extend." |
| Token expired | "Your Outlook session has expired. Please sign in again to sync meetings." |
| Refresh failed | "Unable to refresh your session. Please sign in again." |
| Network error | "Connection lost. Your changes will sync when reconnected." |

## Testing Checklist

- [ ] Sign in and verify token health shows "Healthy"
- [ ] Wait 50 minutes and verify "Expiring soon" warning appears
- [ ] Click "Extend Session" and verify proactive refresh works
- [ ] Force token expiry and verify graceful redirect to sign-in
- [ ] Try Outlook import with expired token - verify error message

## Implementation Priority

1. **High**: Add warning banner for expiring tokens
2. **High**: Show clear error messages in Outlook-dependent features
3. **Medium**: Add visual status indicator in header/sidebar
4. **Low**: Email notifications for expiring tokens
5. **Low**: Analytics on session refresh success/failure rates

## Files to Modify

- `src/app/(dashboard)/layout.tsx` - Add TokenWarningBanner
- `src/components/OutlookSyncButton.tsx` - Add status indicator
- `src/components/outlook-import-modal.tsx` - Better error handling
- `src/app/api/cron/check-token-health/route.ts` - (New) Batch token health check
