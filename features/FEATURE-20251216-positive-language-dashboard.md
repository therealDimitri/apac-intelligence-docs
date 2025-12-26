# Dashboard Positive Language Update

**Date:** 16 December 2025
**Type:** Feature Enhancement
**Status:** Completed
**Files Modified:**

- `src/components/ActionableIntelligenceDashboard.tsx`
- `src/components/priority-matrix/utils.ts`
- `src/components/ChasenWelcomeModal.tsx`
- `src/app/(dashboard)/priority-matrix-demo/page.tsx`

## Summary

Updated dashboard and priority matrix language to be less alarmist and more positive/constructive. The goal is to frame client health data as opportunities for engagement rather than problems to fix.

## Changes Made

### ActionableIntelligenceDashboard.tsx

| Original Term                                                        | New Term                                                               |
| -------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| "severely behind schedule"                                           | "opportunity to accelerate progress"                                   |
| "behind schedule"                                                    | "ready to advance"                                                     |
| "overdue across client portfolio"                                    | "awaiting completion across client portfolio"                          |
| "Immediate action required"                                          | "Priority focus"                                                       |
| "Action needed soon"                                                 | "Opportunity to progress"                                              |
| "days overdue. Blocking progress and impacting client relationship." | "days past scheduled date. Ready to complete for client success."      |
| "NPS score declining"                                                | "NPS score trending - engagement opportunity"                          |
| "Indicates growing dissatisfaction and potential attrition risk."    | "Opportunity to strengthen relationship through proactive engagement." |

### priority-matrix/utils.ts

| Original Term      | New Term                 |
| ------------------ | ------------------------ |
| "Attrition Risk"   | "Renewal Focus"          |
| "Compliance Issue" | "Compliance Focus"       |
| "Overdue Task"     | "Task Ready to Complete" |
| "Client Risk"      | "Client Focus"           |

### ChasenWelcomeModal.tsx

| Original Term     | New Term        |
| ----------------- | --------------- |
| "at-risk clients" | "focus clients" |

### priority-matrix-demo/page.tsx

| Original Term              | New Term                             |
| -------------------------- | ------------------------------------ |
| "severely behind schedule" | "opportunity to accelerate progress" |
| "Compliance Issue"         | "Compliance Focus"                   |
| "events overdue"           | "events awaiting completion"         |

## Language Philosophy

The updated language follows these principles:

1. **Opportunity-focused**: Instead of highlighting risk, emphasise opportunities for engagement
2. **Action-oriented**: Use terms that suggest positive action rather than defensive response
3. **Client-centric**: Frame everything from the perspective of helping clients succeed
4. **Constructive framing**: Replace negative labels with neutral or positive alternatives
5. **Encouraging tone**: Support CSE team morale through positive coaching language

## Testing

- TypeScript compilation: Passed
- No breaking changes to functionality
- All data remains accurate, only user-facing labels changed

## Related Issues

- Continuation of ChaSen AI positive language update
- Part of ongoing UX improvement initiative
- Supports positive coaching approach for CSE team
