# Bug Report: Email Recipient Name Showing "Jimmy" Instead of "Dimitri"

**Date:** 2026-01-27
**Severity:** Low
**Status:** Fixed
**Component:** Email System - Cron Orchestrator

## Issue Summary

Test emails were displaying "Jimmy" as the recipient name instead of "Dimitri" when sent to `dimitri.leimonitis@alterahealth.com`.

## Root Cause

The email system derives recipient names from email addresses when the recipient is not found in the configured recipients list. The code at `src/lib/emails/cron-orchestrator.ts` lines 174-186 parses the email prefix (before @) and capitalises each part:

```typescript
const emailName = testRecipientEmail.split('@')[0]
const nameParts = emailName
  .split('.')
  .map(part => part.charAt(0).toUpperCase() + part.slice(1).toLowerCase())
```

Since `dimitri.leimonitis@alterahealth.com` was not in the configured recipients list (only as a CC recipient), the system would derive the name from whoever's email was used for testing.

## Solution

Added Dimitri Leimonitis as a configured Manager-level recipient in:

1. **`src/lib/emails/cron-orchestrator.ts`** - Added to `getDefaultRecipients()` function:
   ```typescript
   {
     name: 'Dimitri Leimonitis',
     email: 'dimitri.leimonitis@alterahealth.com',
     role: 'Manager',
     schedule: ['monday', 'wednesday', 'friday'],
     ccRecipients: [],
   }
   ```

2. **`supabase/migrations/20260126_email_ai_personalisation.sql`** - Added to seed data:
   ```sql
   ('Dimitri Leimonitis', 'dimitri.leimonitis@alterahealth.com', 'Manager', NULL,
    ARRAY['monday', 'wednesday', 'friday'],
    ARRAY[]::TEXT[])
   ```

3. **`src/hooks/__tests__/useUserProfile.test.ts`** - Updated test mocks to use `dimitri.leimonitis@alterahealth.com` for consistency.

## Files Changed

- `/src/lib/emails/cron-orchestrator.ts` - Added Manager recipient entry
- `/supabase/migrations/20260126_email_ai_personalisation.sql` - Added to migration seed data
- `/src/hooks/__tests__/useUserProfile.test.ts` - Updated test email/name consistency

## Testing

1. All unit tests pass
2. Build completes successfully
3. Deployment verified on production

## Prevention

When adding new team members who may receive emails, ensure they are added to the `email_recipient_config` table or the `getDefaultRecipients()` function rather than relying on email address parsing.
