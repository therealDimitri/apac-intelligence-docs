# Bug Report: Executive Briefing Crew Data Accuracy Issues

**Date:** 27 December 2025
**Severity:** Medium
**Status:** Fixed
**Commit:** `df64996`

## Summary

The Executive Briefing AI Crew was reporting inaccurate NPS scores and incorrectly classifying accounts receivable as overdue, leading to misleading executive summaries.

## Issues Identified

### 1. NPS Score Source Error

**Symptom:** ChaSen reported NPS -39 when actual values were:
- Latest (Q4 25): NPS -19
- All-time: NPS -35

**Root Cause:** The query was not filtering by period and was incorrectly calculating NPS from all responses without period context.

**Fix:**
- Added `nps_period_config` table query for period context
- Added `period` column to NPS responses query
- Calculated latest period NPS vs previous period NPS separately
- Added all-time NPS for context
- Added trend indicator with delta points (+33 improvement from Q2 to Q4)

### 2. Aging/AR Classification Error

**Symptom:** ChaSen reported $1.23M overdue when TRUE overdue (31+ days) was only $680k.

**Root Cause:** The database `total_overdue` column incorrectly includes 1-30 day amounts, which should be classified as "recently due" not "overdue".

**Business Definition:**
- **Current (not yet due)**: `current_amount` column
- **Recently Due (1-30 days)**: `days_1_to_30` column
- **TRUE Overdue (31+ days)**: Sum of `days_31_to_60` through `days_over_365`

**Fix:**
- Changed aging query to select all bucket columns instead of `total_overdue`
- Calculated TRUE overdue manually: sum of all 31+ day buckets
- Updated prompt to clearly label "Current", "Recently Due", and "TRUE Overdue"
- Summary now shows "31+ days" qualifier

### 3. Alarmist Language

**Symptom:** The briefing used overly negative language without proper context, e.g., "alarming NPS" without noting improving trend.

**Fix:**
- Updated system prompt to avoid alarmist language
- Added instruction to present facts objectively with context
- Prompt now explicitly mentions positive NPS trend (+33 points)

### 4. Missing NPS Trends in Risk Dashboard

**Symptom:** Risk Dashboard showed at-risk clients without NPS trend context.

**Fix:**
- Added NPS by client tracking with latest and previous period scores
- Risk Dashboard now shows Latest NPS with trend arrows (↑↓→)
- Example: `SingHealth: Health 44%, Latest NPS: 6 ↓`

## Files Modified

- `src/app/api/chasen/crew/route.ts` - `executeExecutiveBriefing()` function

## Verification

After fix, the Executive Briefing correctly reports:
- **Summary:** `18 clients, 65% health, NPS -19 (Q4 25), $679k overdue (31+ days)`
- **NPS Performance:** Latest -19, Previous -52, Trend ↑ (+33 points)
- **Financial Position:** $1.80M total AR, $569k current, $555k 1-30 days, $679k TRUE overdue (38%)
- **Risk Dashboard:** Client-specific NPS with trend indicators

## Lessons Learned

1. Always use period-qualified NPS when multiple survey periods exist
2. The `total_overdue` database column includes 1-30 days - always calculate TRUE overdue manually
3. Executive summaries should include trend context, not just point-in-time values
4. Avoid alarmist language - present objective facts with comparative context
