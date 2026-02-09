# P2/P3/P4 Hardening Sprint

**Date:** 9 February 2026
**Type:** Feature Shipping + Production Hardening
**Status:** Complete

## Summary

Shipped 7 implementation chunks across three priorities, bringing the platform from 37 LIVE / 4 WIRED to **41 LIVE / 0 WIRED**. Also added production observability (sync logging + alerting) and adopted PageShell on 3 more pages.

## Chunks Delivered

### Chunk 1: Leading Indicators — Real Portfolio Baselines (P3)

**Problem:** `LeadingIndicatorsCard.tsx` hardcoded `previous: 50` for NPS and expansion metrics. Every client showed misleading change percentages.

**Fix:** Replaced hardcoded baselines with portfolio-wide averages computed from `ClientPortfolioContext`. NPS baseline = mean NPS across all clients. Health baseline = mean health score. Change percentages now show "how far from portfolio average" — meaningful and accurate.

**Also added:** Expandable alert list. Previously capped at 5 alerts with no way to see more. Now shows "+N more alerts" button that toggles full list.

| File | Change |
|------|--------|
| `src/components/LeadingIndicatorsCard.tsx` | Portfolio baselines, expandable toggle |

### Chunk 2: Timeline Replay — Event Type Filter Chips (P3)

**Problem:** Timeline showed all 8 event types with no way to focus on specific ones.

**Fix:** Added 8 filter chips (Health, NPS, Meetings, Actions, Completed, Deals, Escalations, News) between speed controls and state display. Click to toggle — empty selection shows all. Filters apply to both scrubber event markers and the event feed.

| File | Change |
|------|--------|
| `src/components/planning/TimelineReplay.tsx` | Filter chip row, filtered event rendering |

### Chunk 3: Meeting Co-Pilot — RAG Dedup Fix + Batch Dismiss (P3)

**Problem:** RAG suggestion insert loop lacked `23505` unique constraint violation handling, causing errors on rapid transcript triggers. No way to dismiss all suggestions at once.

**Fix:** Added `error?.code === '23505'` handling in the RAG insert loop (matching the pattern already used for primary suggestions). Added "Dismiss all" button to the active suggestions UI.

| File | Change |
|------|--------|
| `src/app/api/meetings/[id]/cohost/route.ts` | `23505` constraint handling in RAG loop |
| `src/components/meetings/MeetingCoHost.tsx` | Batch dismiss button |

### Chunk 4: NL Workflows — Creation Wizard (P3)

**Problem:** Workflows could only be created via ChaSen AI chat. No guided self-service path.

**Fix:** Built a 3-step Sheet wizard: (1) Name + NL rule text, (2) Select trigger event (6 options), (3) Select approval mode (3 options). Reuses `TRIGGER_EVENT_CONFIG` and `APPROVAL_MODE_CONFIG` from `WorkflowManager`. Added "Create Workflow" button to both empty state and populated header.

| File | Change |
|------|--------|
| `src/components/workflows/WorkflowCreateWizard.tsx` | New — 3-step wizard component |
| `src/components/workflows/WorkflowManager.tsx` | Create button, wizard integration |
| `src/hooks/useWorkflows.ts` | `createWorkflow()` POST function |

### Chunk 5: PageShell Adoption — Support + NPS Pages (P2)

**Problem:** Pages used bespoke headers with inconsistent padding/sizing. `PageShell` component existed but wasn't adopted.

**Fix:** Replaced manual headers on Support and NPS pages with `<PageShell title="..." subtitle="..." actions={...}>`. Export/Refresh buttons moved into the `actions` prop. Consistent spacing, typography, and layout.

| File | Change |
|------|--------|
| `src/app/(dashboard)/support/page.tsx` | PageShell adoption |
| `src/app/(dashboard)/nps/page.tsx` | PageShell adoption |

### Chunk 6: Sync Logger Helper + 5 Cron Routes (P4)

**Problem:** 30+ cron routes existed but most didn't write to `sync_history`. The health dashboard reads sync_history but data was sparse.

**Fix:** Created `sync-logger.ts` with `startSyncLog()` / `completeSyncLog()` lifecycle. Adopted in 5 critical cron routes. Each route now writes a `sync_history` row with status, duration, and record counts.

| File | Change |
|------|--------|
| `src/lib/sync-logger.ts` | New — sync history logging helper |
| `src/app/api/cron/health-snapshot/route.ts` | Sync logger adoption |
| `src/app/api/cron/news-fetch/route.ts` | Sync logger adoption |
| `src/app/api/cron/burc-file-watcher/route.ts` | Sync logger adoption |
| `src/app/api/cron/ms-graph-sync/route.ts` | Sync logger adoption |
| `src/app/api/cron/aged-accounts-snapshot/route.ts` | Sync logger adoption |

### Chunk 7: Webhook Alerting for Sync Failures (P4)

**Problem:** Sync failures were silent. No notification reached anyone.

**Fix:** Created `alerting.ts` with `sendSyncAlert()` that posts to `ALERT_WEBHOOK_URL` env var (Teams/Slack compatible). Integrated into `completeSyncLog()` — any route using sync-logger gets failure alerting for free. Gracefully degrades if env var is unset.

| File | Change |
|------|--------|
| `src/lib/alerting.ts` | New — webhook alerting |
| `src/lib/sync-logger.ts` | Auto-alert on `status === 'failed'` |

## Feature Audit After Sprint

| Phase | Total | Live | Wired |
|-------|-------|------|-------|
| 7 (AI Components) | 9 | 9 | 0 |
| 8 (Experimental) | 9 | 9 | 0 |
| 9 (Moonshot) | 7 | 7 | 0 |
| 10 (ChaSen AI) | 16 | 16 | 0 |
| **TOTAL** | **41** | **41** | **0** |

## Browser Verification

All user-facing chunks tested via Playwright:

- **Leading Indicators**: 24 alerts with real client names and meaningful change%. Expand/collapse works.
- **PageShell (Support)**: "Support Health" header with subtitle and action buttons.
- **PageShell (NPS)**: "NPS Analytics" header with subtitle and Export Report button.
- **Workflow Wizard**: 3-step creation flow — name/rule, trigger event, approval mode. Clean open/close.
- **Timeline Filter Chips**: 8 chips visible, toggle hides/shows events on scrubber and feed.

Backend chunks (3, 6, 7) verified by code review — no browser-testable UI.

## Roadmap Updates

- `docs/knowledge-base/05-feature-inventory/phase-audit.md` — Updated to 41 LIVE, 0 WIRED
- `docs/knowledge-base/08-roadmap/priorities.md` — UUID migration marked done, WIRED features marked done, sync logger + alerting marked done
