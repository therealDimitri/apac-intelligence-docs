# Enhancement: Meeting Velocity Chart Week Labels Now Show Week Ending Date

**Date**: 2026-01-09
**Type**: UX Enhancement
**Status**: RESOLVED

---

## Problem Description

The Meeting Velocity chart displayed week labels showing the **week start date** (Monday), which was confusing to users. When the chart showed "5 Jan" as the last label, users thought the data stopped at 5 Jan, when in fact that week included all meetings through 11 Jan (Sunday).

**User Report**: "Meeting Velocity chart only has data up until 5 Jan"

## Investigation Findings

After investigating:
1. **Data was correctly fetched** - Meetings from 7 Jan and 8 Jan were properly included
2. **Week grouping was correct** - The week starting 5 Jan (Monday) contained 3 meetings
3. **The issue was display only** - Labels showed week START dates, not week END dates

### Before (Confusing)
| Week Key | Label | Meetings |
|----------|-------|----------|
| 2025-12-07 | 8 Dec | 5 |
| 2025-12-14 | 15 Dec | 14 |
| 2025-12-21 | 22 Dec | 0 |
| 2025-12-28 | 29 Dec | 0 |
| 2026-01-04 | 5 Jan | 3 |

Users saw "5 Jan" and thought data stopped there, but meetings from 7-8 Jan were included.

### After (Clear)
| Week Key | Label | Meetings |
|----------|-------|----------|
| 2025-12-07 | w/e 14 Dec | 5 |
| 2025-12-14 | w/e 21 Dec | 14 |
| 2025-12-21 | w/e 28 Dec | 0 |
| 2025-12-28 | w/e 4 Jan | 0 |
| 2026-01-04 | w/e 11 Jan | 3 |

Users now see "w/e 11 Jan" (week ending) and understand this week includes all data through Sunday 11 Jan.

## Solution

Updated the `formatWeekLabel` function to display the **week ending date** (Sunday) instead of the week start date (Monday).

### Code Before

```typescript
function formatWeekLabel(date: Date): string {
  const day = date.getDate()
  const month = date.toLocaleDateString('en-AU', { month: 'short' })
  return `${day} ${month}`
}
```

### Code After

```typescript
function formatWeekLabel(weekStart: Date): string {
  // Show week ending date (Sunday) instead of week start (Monday)
  const weekEnd = new Date(weekStart)
  weekEnd.setDate(weekEnd.getDate() + 6)
  const day = weekEnd.getDate()
  const month = weekEnd.toLocaleDateString('en-AU', { month: 'short' })
  return `w/e ${day} ${month}`
}
```

## Files Modified

1. **`src/app/api/analytics/meetings/route.ts`**
   - Updated `formatWeekLabel` function to calculate week end date (+6 days from start)
   - Renamed parameter from `date` to `weekStart` for clarity
   - Added comment explaining the change

## Testing

1. Navigate to the Briefing Room or any page with the Meeting Velocity chart
2. Verify the first label shows "14 Dec" (week ending) instead of "8 Dec" (week start)
3. Verify the last label shows "11 Jan" (current week ending) instead of "5 Jan"
4. Hover over bars to confirm meeting counts are unchanged

## Notes

- This is a display-only change; no data or calculations were modified
- The underlying week grouping still uses Monday as the week start
- The -79% trend calculation remains accurate (compares last 4 weeks)
- Weekly average calculation unchanged
