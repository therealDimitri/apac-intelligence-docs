# Enhancement: Email Working Capital Section - Current Card and As Of Date

**Date**: 27 January 2025
**Type**: Enhancement
**Status**: Completed
**Component**: Weekly Email Generator (CSE and Team Lead emails)

## Summary

Enhanced the Working Capital / AR Health section in weekly emails to include:
1. A new "Current" card showing the percentage of AR that is current (not overdue)
2. An "As of" date showing when the AR data was last updated

## Changes Made

### 1. Data Aggregator (`src/lib/emails/data-aggregator.ts`)

- Added `asOfDate?: string` field to the `ARAgingBreakdown` interface
- Updated Manager email AR data query to include `week_ending_date` from `aging_accounts` table
- Updated CSE email AR data query to use `aging_accounts` table (instead of deprecated `aged_accounts_history`) and include `week_ending_date`
- Both queries now track the latest `week_ending_date` across all records and set it as `asOfDate`

### 2. Email Generator (`src/lib/emails/ai-email-generator.ts`)

#### CSE Email HTML Section (`generateCSEARAgingSection`)
- Changed layout from 3 columns (33% each) to 4 columns (25% each)
- Added new "Current" card as the first column with:
  - `percentCurrent` value (percentage of total AR that is current)
  - ChaSen brand styling (purple/light purple) to distinguish from goal-based cards
  - No goal indicator (informational only)
- Updated footer to include "As of [date]" when available, formatted as "DD Month YYYY"

#### Team Lead Email HTML Section
- Applied same changes as CSE email
- Uses IIFE pattern to format the date within the template literal

#### Text Versions (Both CSE and Team Lead)
- Added `Current: X%` line after Total Outstanding
- Added `As of [date]` line when asOfDate is available

## Display Order

The section now shows four cards in this order:
1. **Current** - Percentage of AR that is current (not overdue yet) - informational
2. **Under 60 Days** - Goal: 90%
3. **Under 90 Days** - Goal: 100%
4. **Over 90 Days** - Goal: 0%

## Data Source

- `asOfDate` is sourced from the `week_ending_date` column in the `aging_accounts` table
- The latest date across all records is used
- Date is formatted using `en-AU` locale: "27 January 2025"

## Files Modified

1. `/src/lib/emails/data-aggregator.ts`
   - Added `asOfDate` to `ARAgingBreakdown` interface
   - Updated AR data fetching in `getTeamPerformanceData` function
   - Updated `getCSEARAgingBreakdown` function

2. `/src/lib/emails/ai-email-generator.ts`
   - Updated `generateCSEARAgingSection` function (HTML)
   - Updated CSE text version section
   - Updated Team Lead HTML section
   - Updated Team Lead text version section

## Testing

- Build verified: `npm run build` passes successfully
- TypeScript compilation: No errors

## Verification Steps

1. Generate a preview email using the email preview endpoint
2. Verify the Working Capital section shows 4 cards
3. Confirm "Current" appears first with correct percentage
4. Confirm "As of" date appears at the bottom
5. Check both CSE and Team Lead email formats
