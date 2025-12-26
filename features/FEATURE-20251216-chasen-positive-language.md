# ChaSen AI Positive Language Update

**Date:** 16 December 2025
**Type:** Feature Enhancement
**Status:** Completed
**Files Modified:** `src/app/api/chasen/chat/route.ts`

## Summary

Updated ChaSen AI language throughout the system prompt and data labels to be less alarmist and more positive/constructive. The goal is to frame client health data as opportunities for engagement rather than problems to fix.

## Changes Made

### Terminology Replacements

| Original Term                                   | New Term                                         | Context             |
| ----------------------------------------------- | ------------------------------------------------ | ------------------- |
| At-Risk Health Count                            | Focus Clients (Health <60)                       | Portfolio summary   |
| At-Risk Compliance Count                        | Focus Clients (Compliance <80)                   | Portfolio summary   |
| At-Risk ARR (90 days)                           | Renewal Attention (90 days)                      | Revenue tracking    |
| Declining Clients                               | Attention Needed                                 | Trend analysis      |
| At-Risk Trend                                   | Priority Watch                                   | Trend analysis      |
| Top At-Risk Clients                             | Priority Focus Clients                           | Client list headers |
| Overdue Events (Not Completed)                  | Events Awaiting Completion                       | Event tracking      |
| Overdue Events (Past Due Date)                  | Events Awaiting Completion (Past Scheduled Date) | Event data headers  |
| at-risk clients, overdue actions, declining NPS | focus clients, outstanding actions, NPS trends   | Instruction text    |

### Language Philosophy

The updated language follows these principles:

1. **Opportunity-focused**: Instead of highlighting risk, emphasise opportunities for engagement
2. **Action-oriented**: Use terms that suggest positive action rather than defensive response
3. **Client-centric**: Frame everything from the perspective of helping clients succeed
4. **Constructive framing**: Replace negative labels with neutral or positive alternatives

### Example Transformations

**Before:**

```
- At-Risk Health Count: 5 clients
- Declining Clients: 3
- At-Risk Trend: 2
- Overdue Events (Not Completed): 10
```

**After:**

```
- Focus Clients (Health <60): 5 clients
- Attention Needed: 3
- Priority Watch: 2
- Events Awaiting Completion: 10
```

## Testing

- TypeScript compilation: Passed
- No breaking changes to API responses
- All data fields remain accurate, only labels changed

## Notes

- Internal variable names (e.g., `atRiskHealth`, `atRiskCompliance`) were not changed as they are implementation details
- Database field values for `predicted_status` ('critical', 'at-risk', 'compliant') were not changed as these reflect actual schema values
- Financial terminology like "Outstanding Receivables" was already positive and retained

## Related Issues

- Part of ongoing UX improvement initiative
- Supports positive coaching approach for CSE team

## Verification

To verify the changes, start a new ChaSen conversation and ask about portfolio health or client status. The responses should use positive framing language.
