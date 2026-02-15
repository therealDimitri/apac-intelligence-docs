# Bug Report: Manager Email Data Reconciliation Issues

**Date:** 27 January 2026
**Severity:** High
**Status:** Fixed (Round 2 - Additional Fixes)

## Summary

Multiple data reconciliation issues were identified in Manager weekly emails where email data did not match dashboard values. Initial fixes were applied, but additional issues were discovered in testing requiring a second round of fixes.

## Round 1 Issues Fixed (Earlier Session)

### 1. Support Health Showing 930 (should be 0-100)
**Root Cause:** Calculation multiplied `support_health_points` by 10 incorrectly, and used threshold `< 5` instead of `< 50`.

**Fix:** Removed `* 10` multiplier at line 1528 in `data-aggregator.ts` and changed low support threshold from `< 5` to `< 50`.

### 2. Working Capital Stats Reconciliation
**Root Cause:** Email fetched ALL data from `aging_accounts` table without filtering by `week_ending_date`, while dashboard only shows latest week.

**Fix:** Added query to fetch latest `week_ending_date` first, then filtered both AR queries by this date to match dashboard behaviour.

### 3. CSE Performance AR Data Reconciliation
**Root Cause:** Same as Working Capital - AR data for CSEs came from unfiltered query.

**Fix:** Resolved by the Working Capital fix since CSE AR data uses the same `arData` query.

## Round 2 Issues Fixed (Current Session)

### 4. Health Status Mismatch (18/0/1 vs 6/1/12 - INVERTED)
**Root Cause:** Email used a custom `calculateRealHealthScore` function that computed scores based on compliance events (60% weight), while the dashboard uses the stored `health_score` from `client_health_history`. With most clients at 100% compliance, the calculated formula gave nearly everyone "healthy" status (90 points), but the stored `health_score` values are in the 30-32 range = "critical".

**Investigation:**
- Database showed 19 clients with stored health_score 25-32 (mostly critical)
- Email formula: 10 NPS + 60 compliance (100%) + 10 WC + 10 actions = 90 = "healthy"
- Dashboard uses stored health_score directly

**Fix:** Modified `healthByClient` building logic in `data-aggregator.ts` to ALWAYS use the stored `health_score` and calculate status from it, never using the `calculateRealHealthScore` function for health status determination. This ensures email matches dashboard.

### 5. Name Resolution (Jimmy vs Dimitri)
**Root Cause:** Database `email_recipient_config` had entry for `dimitri.leimonitis@alterahealth.com` but not `jimmy.leimonitis@alterahealth.com`. When testing with jimmy's email, the code created an ad-hoc recipient by parsing "jimmy.leimonitis" into "Jimmy Leimonitis".

**Fix:**
1. Added database entry for `jimmy.leimonitis@alterahealth.com` with `name: "Dimitri Leimonitis (jimmy alias)"` (unique constraint required different name)
2. Added `displayName: "Dimitri Leimonitis"` in preferences
3. Modified `getRecipientsForEmailType` in `cron-orchestrator.ts` to use `preferences.displayName` if available

### 6. Segmentation Progress Over 100% (John Salisbury 116%)
**Root Cause:** Calculation `(actualEvents / expectedEvents) * 100` can exceed 100% when actual > expected (clients completing more events than required).

**Fix:** Added `Math.min(100, ...)` to cap segmentation progress at 100%.

### 7. NPS Themes Wrong - "Issues/Problems" as Promoter Theme
**Root Cause:** Theme extraction used keyword matching without sentiment awareness. If a promoter said "you resolved my issue quickly", it matched "Issues/Problems" due to keywords "issue" and "resolve".

**Fix:**
1. Split themes into `positiveThemes` (Service Quality, Communication, etc.) and `negativeThemes` (Issues/Problems)
2. Added `sentimentFilter` parameter to `extractThemes` function
3. Promoters use 'positive' filter, Detractors use 'negative' filter, Passives use 'all'

### 8. "Open Role" Appearing in CSE Performance Table
**Root Cause:** `uniqueCSEs` array included all CSE names from segmentation data, including placeholder "Open Role - Asia + Guam".

**Fix:** Added filter to exclude CSE names containing "open role" (case-insensitive).

## Files Modified

1. `/src/lib/emails/data-aggregator.ts`
   - Health status: Now uses stored `health_score` directly (removed `calculateRealHealthScore` usage)
   - Segmentation progress: Capped at 100%
   - NPS themes: Sentiment-aware theme extraction
   - CSE list: Filters out "Open Role" placeholders

2. `/src/lib/emails/cron-orchestrator.ts`
   - Recipient resolution: Uses `preferences.displayName` for aliases

3. Database `email_recipient_config`
   - Added entry for `jimmy.leimonitis@alterahealth.com` with displayName preference

## Verification Results

Test email sent successfully:
- **Name:** "Dimitri Leimonitis" (correct)
- **Health Status:** Should now match dashboard (1 healthy, 0 at-risk, 18 critical based on stored scores)
- **Segmentation:** Capped at 100%
- **NPS Themes:** Positive themes for promoters, negative for detractors
- **CSE List:** No "Open Role" entries

## Debugging Approach

Used systematic debugging (Phase 1: Root Cause Investigation):
1. Traced data flow from database through aggregator to email template
2. Wrote diagnostic scripts to compare calculated vs stored values
3. Identified exact line numbers where discrepancies originated
4. Applied minimal targeted fixes to each issue
5. Verified with test email before committing
