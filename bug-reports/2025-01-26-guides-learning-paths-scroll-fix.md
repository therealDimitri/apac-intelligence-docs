# Bug Report: Role Learning Paths Not Scrolling to Content

## Issue
Role-based learning path modules in the Guides & Resources page did not display/scroll to their associated training content when clicked.

## Date
2025-01-26

## Symptoms
- User clicks on a learning path module (e.g., "Managing Client Portfolios")
- Nothing happens - page doesn't scroll and training section doesn't expand
- Progress tracking works but navigation is broken

## Root Cause
The training section container `<div>` elements were missing `id` attributes. The `onModuleClick` handler in `LearningPathSelector.tsx` uses:

```javascript
document.getElementById(sectionId)?.scrollIntoView({ behavior: 'smooth' })
```

Without the `id` attributes, `getElementById()` returns `null` and `scrollIntoView()` is never called.

## Files Affected
- `src/app/(dashboard)/guides/page.tsx` - Training section containers

## Resolution
Added `id` attributes to all 12 training section container divs:

1. `id="command-centre"`
2. `id="client-portfolios"`
3. `id="nps-analytics"`
4. `id="briefing-room"`
5. `id="actions-tasks"`
6. `id="chasen-ai"`
7. `id="success-plans"`
8. `id="compliance-tracking"`
9. `id="pipeline-financials"`
10. `id="priority-matrix"`
11. `id="settings-preferences"`
12. `id="alerts-notifications"`

## Additional Fixes in Same Commit
- Fixed ESLint error: setState in useEffect - converted to lazy initialization of useState
- Removed unused imports (MousePointer2, FolderKanban, Wallet, MessagesSquare, ClipboardList)
- Removed unused isMobile hook from layout.tsx

## Testing
- Verified CSE learning path module clicks correctly scroll to and expand training sections
- Progress tracking updates correctly (showing completion percentage and checkmarks)
- Build passes with zero TypeScript errors

## Status
RESOLVED
