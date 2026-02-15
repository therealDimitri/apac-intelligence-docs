# Bug Report: EVP Email Feedback Fixes - AR Aging, NPS Period, Segmentation

**Date**: 2026-01-26
**Severity**: Medium
**Status**: Fixed

## Issues Identified

User feedback identified three problems in the EVP weekly email:

### 1. AR Aging Section - Lacked Goal Context

**Problem**: The Working Capital / AR Aging section displayed raw dollar amounts by bucket (Current, 1-30 Days, etc.) without providing insight into whether the values met business goals.

**User Feedback**: "I need it to be less of a cognitive load and give me insights on achievements vs goals. For example, is $2.2M good or bad?"

**Root Cause**: Email was displaying `$${arAging.current}K` style metrics without goal-based context.

**Solution**: Redesigned the AR section to show goal-based percentages:
- **% Under 60 Days** vs 90% goal (✓/✗ indicator)
- **% Under 90 Days** vs 100% goal (✓/✗ indicator)
- **% Over 90 Days** vs 0% goal (✓/✗ indicator)

Added new fields to `ARAgingBreakdown` interface:
```typescript
percentUnder60Days: number // Goal: 90%
percentUnder90Days: number // Goal: 100%
percentOver90Days: number // Goal: 0%
goalUnder60Met: boolean
goalUnder90Met: boolean
goalOver90Met: boolean
```

### 2. NPS Section - Misleading "Last 30 Days" Text

**Problem**: NPS section displayed "43 responses in last 30 days" which was misleading since NPS surveys are only conducted twice per year.

**User Feedback**: "NPS section that states 43 responses in the last 30 days is misleading. NPS surveys are only done twice a year and the last was Q4 2025."

**Root Cause**: Display text was hardcoded as "last 30 days" even though data was actually from a specific survey period (Q4 25).

**Solution**:
1. Added `surveyPeriod` field to `NPSMetrics` interface
2. Updated data aggregator to pass the actual survey period code (e.g., "Q4 25")
3. Changed display text from "responses in last 30 days" to "responses (Q4 25)"

### 3. Segmentation Progress - Incorrect Overdue/Due This Month Counts

**Problem**: Segmentation progress showed 0 overdue events and 0 due this month when there were actually events in both categories.

**User Feedback**: "Segmentation progress is inaccurate. There is definitely more due this month and overdue."

**Root Cause**: The compliance logic at lines 1014-1018 only included records where `recordYear === currentYear (2026)`, but standard deadline clients (Dec 31 deadline) had 2025 events that were now overdue since Dec 31, 2025 had passed.

```typescript
// BUG: Both branches did the same thing
if (hasExtendedDeadline) {
  if (recordYear === currentYear) includeInCompliance = true
} else {
  if (recordYear === currentYear) includeInCompliance = true  // Identical!
}
```

**Solution**: Fixed the logic to correctly handle both deadline types:
- **Standard deadline clients (Dec 31)**: Include previous year + current year records. Previous year events are now overdue.
- **Extended deadline clients (June 30)**: Include current year only. Their deadline is June 30 of the following year.

```typescript
if (hasExtendedDeadline) {
  if (recordYear === currentYear) {
    includeInCompliance = true
    deadlineForRecord = clientInfo?.extendedDeadline || new Date(currentYear + 1, 5, 30)
  }
} else {
  // Include BOTH previous year (overdue) and current year
  if (recordYear === currentYear || recordYear === currentYear - 1) {
    includeInCompliance = true
    deadlineForRecord = new Date(recordYear, 11, 31)
  }
}
```

## Files Modified

- `/src/lib/emails/data-aggregator.ts`
  - Added goal-based fields to `ARAgingBreakdown` interface
  - Added `surveyPeriod` to `NPSMetrics` interface
  - Fixed segmentation compliance logic for both deadline types
  - Updated `getCSEARAgingBreakdown()` with goal calculations
  - Updated `buildNPSMetrics()` to accept survey period

- `/src/lib/emails/ai-email-generator.ts`
  - Replaced raw dollar AR display with goal-based percentage display
  - Updated NPS text from "last 30 days" to actual survey period
  - Updated both HTML and plain text email sections

## Testing

- Sent test EVP email successfully
- Build passed with zero TypeScript errors
- All three issues verified fixed in test email

## Prevention

1. When displaying metrics, always include context (goals, targets, comparisons)
2. Never hardcode time periods in display text - use actual data source periods
3. When implementing deadline logic, ensure all edge cases are covered (different deadline types, different years)
4. Test with real data that includes edge cases (overdue items, different compliance states)
