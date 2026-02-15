# Bug Report: Test Emails Showing Zero Clients/Data

**Date:** 27 January 2026
**Severity:** Medium
**Status:** Fixed
**Commit:** c1586526

## Summary

Test emails sent via the cron API showed 0 clients, 0% health, and empty portfolio data when the test recipient email address didn't belong to a registered CSE with assigned clients.

## Symptoms

When sending a test email:
```
GET /api/cron/cse-emails?type=friday&test=true&testEmail=jimmy.leimonitis@alterahealth.com&testRole=CSE
```

The email displayed:
- 0 clients
- 0% health
- 0 at risk
- 0% Q target
- Generic ChaSen insights ("Focus on building momentum this week")

## Root Cause

The test email flow created an ad-hoc recipient with a name derived from the email address (e.g., "Jimmy Leimonitis" from jimmy.leimonitis@alterahealth.com). The `getCSEPortfolioData` function then queried the database filtering by this CSE name, which returned no data because:

1. Jimmy Leimonitis isn't registered as a CSE with client assignments
2. The email wasn't in `MANAGER_EMAILS` which would trigger aggregate data access
3. All subsequent data queries (clients, AR, NPS, actions, etc.) returned empty arrays

### Code Flow

1. `cron-orchestrator.ts` line 174-186: Creates ad-hoc recipient from email
2. `ai-email-generator.ts` line 77: Calls `getCSEPortfolioData(recipientName, ...)`
3. `data-aggregator.ts` line 409: Sets `filterName = cseName` (not null)
4. All queries filter by non-existent CSE name → returns 0 rows

## Fix Applied

Added a `testCseName` parameter that allows test emails to use a real CSE's portfolio data while sending to a different email address.

### Changes Made

1. **`/src/app/api/cron/cse-emails/route.ts`**
   - Added `testCseName` query parameter
   - Updated usage documentation with valid CSE names
   - Pass `testCseName` to job options

2. **`/src/lib/emails/cron-orchestrator.ts`**
   - Added `testCseName` to `RunEmailJobOptions` interface
   - Pass `testCseName` through `processRecipient` to `generateAIEmail`

3. **`/src/lib/emails/ai-email-generator.ts`**
   - Added optional `dataSourceCseName` parameter to `generateAIEmail`
   - Use `dataSourceCseName` for data fetching while keeping `recipientName` for greeting

## Usage

```bash
# Test email with real CSE data
curl "http://localhost:3001/api/cron/cse-emails?type=friday&test=true&testEmail=your@email.com&testCseName=Tracey%20Bland"

# Valid CSE names:
# Tracey Bland, Laura Messing, John Salisbury, Gilbert So, BoonTeck Lim, Nikki Wei
```

## Verification

After fix:
- Email shows actual client count from specified CSE's portfolio
- Health scores, AR data, NPS metrics populated correctly
- ChaSen insights reference real clients and situations
- Greeting still addresses the test recipient by name

## Prevention

- Test emails should always specify `testCseName` when the recipient isn't a real CSE
- Consider adding validation that warns if portfolio data is empty
- Could add a "preview mode" that generates HTML without sending
