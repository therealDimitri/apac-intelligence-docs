# Feature: Automated Email Logging

**Date:** 24 December 2024
**Status:** PENDING TABLE CREATION
**Component:** ChaSen Email System

## Overview

Added automated logging for all scheduled CSE emails (Monday, Wednesday, Friday) to enable easy verification of email delivery without checking Netlify logs.

## Components Created

### 1. Database Migration

**File:** `docs/migrations/20251224_email_logs_table.sql`

Creates `email_logs` table with:

- `email_type` - 'monday', 'wednesday', 'friday', 'client_support', 'evp'
- `recipient_name`, `recipient_email` - Who received the email
- `subject` - Email subject line
- `status` - 'sent' or 'failed'
- `error_message` - Error details if failed
- `external_email_id` - ID from Resend email service
- `sent_at`, `created_at` - Timestamps
- `metadata` - JSONB for CC list and other data

### 2. Email Logging in Cron Endpoint

**File:** `src/app/api/cron/cse-emails/route.ts`

Added `logEmailSend()` helper function that:

- Logs each email send attempt to `email_logs` table
- Captures success/failure status
- Records external email ID from Resend
- Stores metadata like CC recipients

### 3. Check Script

**File:** `scripts/check-email-logs.mjs`

Usage:

```bash
# Check all emails from today
node scripts/check-email-logs.mjs

# Check Wednesday emails only
node scripts/check-email-logs.mjs wednesday

# Check Monday emails from last 7 days
node scripts/check-email-logs.mjs monday 7
```

Output includes:

- Email type breakdown
- Success/failure counts
- Per-recipient status with timestamps
- Error messages for failures

## Setup Required

**IMPORTANT:** The `email_logs` table must be created before email logging will work.

### Option 1: Run Migration Script

```bash
node scripts/apply-email-logs-migration.mjs
```

This will attempt to create the table. If it fails (exec_sql RPC not available), it will open the Supabase SQL Editor.

### Option 2: Manual SQL Execution

1. Open: https://supabase.com/dashboard/project/usoyxsunetvxdjdglkmn/sql/new
2. Copy and paste the SQL from `docs/migrations/20251224_email_logs_table.sql`
3. Click "Run"

## Verification

After table creation, test the logging:

1. Trigger a test email run:

   ```bash
   curl -X GET "https://apac-intelligence.netlify.app/api/cron/cse-emails?type=wednesday" \
     -H "Authorization: Bearer YOUR_CRON_SECRET"
   ```

2. Check the logs:
   ```bash
   node scripts/check-email-logs.mjs wednesday
   ```

## Files Modified

- `src/app/api/cron/cse-emails/route.ts` - Added email logging
- `docs/migrations/20251224_email_logs_table.sql` - Table creation SQL
- `scripts/apply-email-logs-migration.mjs` - Migration runner
- `scripts/check-email-logs.mjs` - Log checker script
- `scripts/create-email-logs-table.mjs` - Alternative migration script

## Future Enhancements

1. **Dashboard Widget** - Add email log viewer to internal ops page
2. **Alerts** - Send Slack notification on email failures
3. **Retry Logic** - Automatically retry failed emails
4. **Analytics** - Track email delivery rates over time
