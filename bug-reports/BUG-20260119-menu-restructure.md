# Enhancement: Menu Restructure - Industry Best Practice Terminology

**Date**: 2026-01-19
**Type**: Enhancement / Navigation Improvements
**Status**: RESOLVED

---

## Overview

Restructured the sidebar navigation menu to align with industry best practices from leading Customer Success platforms (Gainsight, ChurnZero, Vitally, Planhat, Totango) while maintaining Altera workflow processes.

## Final Menu Structure

```
Command Centre
  └── BURC Performance
  └── BU Performance
  └── APAC Goals

Success Plans
  └── Account Plans

Clients
  └── Portfolio Health
  └── Segmentation Performance

Action Hub
  └── Meetings
  └── Actions & Tasks
  └── Segmentation Event Progress

Analytics
  └── CS Team Performance
  └── NPS & Mid-Project Feedback
  └── Support Health
  └── Working Capital

Resources
  └── Guides & Templates
```

## Changes Made

### Menu Structure (Before → After)

| Section | Before | After |
|---------|--------|-------|
| Home | Command Centre (standalone link) | Command Centre (collapsible group) |
| Home Children | - | BURC Performance, BU Performance, APAC Goals |
| Planning Hub | Account Plans, Full Pipeline | Success Plans > Account Plans (moved after Command Centre) |
| Clients | Client Portfolios | Portfolio Health |
| Clients | Segmentation Events | Segmentation Performance |
| Engagement | Briefing Room, Actions & Tasks, etc. | Action Hub (renamed, restructured) |
| Analytics | Team Performance, NPS Analytics, etc. | CS Team Performance, NPS & Mid-Project Feedback, etc. |

### Key Terminology Changes

1. **Command Centre** → Now a collapsible group with performance dashboards
2. **Planning Hub** → Renamed to **Success Plans** (industry standard), moved after Command Centre
3. **Engagement** → Renamed to **Action Hub** (operational focus)
4. **Briefing Room** → Renamed to **Meetings** (clearer purpose)
5. **Client Portfolios** → Renamed to **Portfolio Health** (descriptive)
6. **Team Performance** → Renamed to **CS Team Performance** (specific)
7. **NPS Analytics** → Renamed to **NPS & Mid-Project Feedback** (comprehensive)
8. **Full Pipeline** → Removed from menu

### Route Mappings

| Menu Item | Route |
|-----------|-------|
| Command Centre > BURC Performance | `/burc` |
| Command Centre > BU Performance | `/` |
| Command Centre > APAC Goals | `/apac` |
| Success Plans > Account Plans | `/planning` |
| Clients > Portfolio Health | `/client-profiles` |
| Clients > Segmentation Performance | `/segmentation` |
| Action Hub > Meetings | `/meetings` |
| Action Hub > Actions & Tasks | `/actions` |
| Action Hub > Segmentation Event Progress | `/compliance` |
| Analytics > CS Team Performance | `/team-performance` |
| Analytics > NPS & Mid-Project Feedback | `/nps` |
| Analytics > Support Health | `/support` |
| Analytics > Working Capital | `/aging-accounts` |
| Resources > Guides & Templates | `/guides` |

## Research Summary

Analysed terminology from leading CS platforms:
- **Gainsight**: Customer 360, Cockpit, Timeline, Success Plans
- **ChurnZero**: Command Center, Plays, Segments
- **Vitally**: Account Hub, Playbooks, Health Scores
- **Planhat**: Customer 360, Revenue, Workflows
- **Totango**: SuccessBLOCs, Campaigns, Segments

## Files Modified

| File | Changes |
|------|---------|
| `src/components/layout/sidebar.tsx` | Complete menu structure reorganisation |

## Testing

- [x] Build passes (`npm run build`)
- [x] TypeScript compilation successful
- [x] Menu structure displays correctly
- [x] All collapsible groups expand/collapse
- [x] Navigation to all routes works correctly
- [x] Active state highlighting works for nested items
- [x] localStorage persistence for expanded groups maintained

## Commits

- `[pending]` - Restructure sidebar menu with industry best practice terminology
