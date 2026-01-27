# Bug Report: Manager Email Data Reconciliation Issues

**Date:** 27 January 2026
**Severity:** High
**Status:** Fixed

## Summary

Multiple data reconciliation issues were identified in Manager weekly emails where email data did not match dashboard values.

## Issues Fixed

### 1. Health Status Mismatch (18/0/1 vs 6/1/12)
**Root Cause:** Email used stored `status` field from `client_health_history` table, while dashboard calculates status dynamically from `health_score` using thresholds (>=70 healthy, >=60 at-risk, <60 critical).

**Fix:** Modified `healthByClient` building logic in `data-aggregator.ts` to calculate status from score using the same thresholds as the dashboard (defined in `design-tokens.ts`).

### 2. Name Resolution (Jimmy vs Dimitri)
**Root Cause:** Test email to jimmy.leimonitis@alterahealth.com created ad-hoc recipient without matching existing Manager config for dimitri.leimonitis@alterahealth.com.

**Fix:** Added jimmy.leimonitis@alterahealth.com as an alias in both `MANAGER_EMAILS` array and default recipients list in `cron-orchestrator.ts`.

### 3. Support Health Showing 930 (should be 0-100)
**Root Cause:** Calculation multiplied `support_health_points` by 10 incorrectly, and used threshold `< 5` instead of `< 50`.

**Fix:** Removed `* 10` multiplier at line 1528 in `data-aggregator.ts` and changed low support threshold from `< 5` to `< 50`.

### 4. Working Capital Stats Reconciliation
**Root Cause:** Email fetched ALL data from `aging_accounts` table without filtering by `week_ending_date`, while dashboard only shows latest week. This caused:
- Multiple weeks' data being summed (inflated totals)
- Inconsistent per-client values

**Fix:** Added query to fetch latest `week_ending_date` first, then filtered both AR queries by this date to match dashboard behaviour.

### 5. CSE Performance AR Data Reconciliation
**Root Cause:** Same as Working Capital - AR data for CSEs came from unfiltered query.

**Fix:** Resolved by the Working Capital fix since CSE AR data uses the same `arData` query.

## Enhancements Added

### 6. Segmentation Progress in CSE Performance Table
**Enhancement:** Added "Seg %" column to CSE Performance table showing each CSE's segmentation event completion percentage.

**Files Changed:**
- `data-aggregator.ts`: Added `segmentationProgress` to `CSEPerformance` interface and calculation
- `ai-email-generator.ts`: Added column to HTML table with colour coding (green >=80%, yellow >=60%, red <60%)
- `templates/ManagerWeeklyEmail.tsx`: Added field to interface and table column

### 7. NPS Themes from Verbatim Comments
**Enhancement:** Added automatic theme extraction from NPS verbatim feedback.

**Features:**
- Extracts themes using keyword matching across 10 categories (Service Quality, Communication, Product/Platform, Team/Staff, Training, Relationship, Implementation, Value/ROI, Issues/Problems, Innovation)
- Displays top 3 themes per NPS category (Promoters, Passives, Detractors)
- Shows mention counts and example quotes

**Files Changed:**
- `data-aggregator.ts`: Added `NPSTheme` interface, theme extraction function, and updated NPS query to fetch feedback column
- `ai-email-generator.ts`: Added NPS Themes section to both HTML and text versions

## Files Modified

1. `/src/lib/emails/data-aggregator.ts`
   - Health status calculation using score-based thresholds
   - Support Health scale fix
   - AR data filtering by latest week_ending_date
   - Segmentation progress calculation
   - NPS theme extraction

2. `/src/lib/emails/ai-email-generator.ts`
   - Segmentation column in CSE Performance table
   - NPS Themes display section

3. `/src/lib/emails/cron-orchestrator.ts`
   - Jimmy/Dimitri alias mapping

4. `/src/lib/emails/templates/ManagerWeeklyEmail.tsx`
   - Segmentation progress field and column

## Verification

Test emails should now show:
- Correct health status counts matching dashboard
- Correct recipient name (Dimitri, not Jimmy)
- Support Health on 0-100 scale
- Working Capital stats matching dashboard
- CSE Performance AR matching dashboard
- Segmentation Progress percentage per CSE
- NPS Themes extracted from verbatim feedback
