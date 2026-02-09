# Priorities

## Guiding Principles

1. **Data accuracy over features** — A wrong number erodes trust faster than a missing feature
2. **Automate everything** — CSEs shouldn't manually enter data that exists elsewhere
3. **Intelligent defaults** — Show the right information without requiring configuration
4. **Simple workflows** — Every click should feel purposeful, not navigational
5. **Graceful degradation** — AI features enhance but never block core workflows

## Priority 1: Data Integrity (High)

The foundation everything else depends on. Users lose trust if numbers don't match.

| Task | Impact | Complexity | Status |
|------|--------|------------|--------|
| ~~Complete client UUID migration across all API routes~~ | High | Medium | ✅ DONE (Phases A-E shipped) |
| ~~Centralise client name mappings in `client_name_aliases`~~ | High | Medium | ✅ DONE |
| ~~Validate Excel cell references before BURC sync~~ | High | Low | ✅ DONE |
| ~~Document all BURC Excel cell references in mapping spreadsheet~~ | Medium | Low | ✅ DONE |
| ~~Add hash-based duplicate detection for activity events~~ | Medium | Low | ✅ DONE (DB trigger + UNIQUE constraint + ON CONFLICT in all 4 insertion paths) |
| ~~Parameterise fiscal year in sync scripts (currently hardcoded 2026)~~ | Medium | Medium | ✅ DONE |

## Priority 2: UI/UX Unification (High)

Design system coherence (7/10, up from 5.5). Remaining gaps: hex colours in financial-analytics, clients page custom table, react-hook-form migration.

| Task | Impact | Complexity | Status |
|------|--------|------------|--------|
| ~~Create `<PageShell>` component for consistent page layouts~~ | High | Medium | ✅ DONE — adopted by 11+ pages |
| ~~Build centralised design tokens (`design-tokens.ts`)~~ | High | Medium | ✅ DONE — LayoutTokens, TypographyClasses, InteractiveTokens + PageShell adoption |
| ~~Unify data table component (TanStack wrapper)~~ | Medium | Medium | ✅ DONE — 4 pages migrated to useAdvancedTable |
| ~~Standardise modal/dialog pattern~~ | Medium | Low | ✅ DONE — overlay barrel, BottomSheet deprecated, Drawer migration |
| ~~Create unified form field wrapper~~ | Medium | Low | ✅ DONE — FormFieldWrapper + 11 fields retrofitted with ARIA |
| ~~Hide internal pages (`/test-*`, `/chasen-icons`) from production~~ | Low | Low | ✅ DONE |

## Priority 3: Automation & Intelligence (Medium)

Maximise the value of existing data through intelligent insights.

| Task | Impact | Complexity | Status |
|------|--------|------------|--------|
| ~~Automate Activity Register sync (currently manual CLI only)~~ | High | Low | ✅ DONE |
| ~~Wire remaining "WIRED" features~~ | Medium | Low-Medium | ✅ DONE (0 WIRED, 41 LIVE) |
| ~~Add alerting on data staleness (Slack/Teams notifications)~~ | Medium | Medium | ✅ DONE (staleness-check cron + Teams webhooks via alerting.ts) |
| ~~Seed goal hierarchy tables~~ | Medium | Low | ✅ DONE |
| ~~Automate compliance reconciliation via daily cron~~ | Medium | Low | ✅ DONE (/api/cron/compliance-reconciliation) |

## Priority 4: Production Hardening (Medium)

| Task | Impact | Complexity | Status |
|------|--------|------------|--------|
| ~~Add sync-logger helper + adopt in 5 critical cron routes~~ | Medium | Low | ✅ DONE |
| ~~Add webhook alerting for sync failures~~ | Medium | Low | ✅ DONE |
| ~~Extend sync logging to remaining cron routes (INSERT/UPDATE/SKIP)~~ | Medium | Low | ✅ DONE (34/34 routes use startSyncLog/completeSyncLog) |
| ~~Implement data staleness alerting~~ | Medium | Medium | ✅ DONE (staleness-check cron + STALENESS_THRESHOLDS + dedup) |
| ~~Document and test disaster recovery (what if sync breaks?)~~ | Medium | Low | ✅ DONE (07-infrastructure/disaster-recovery.md) |
| ~~Add health checks for cron routes~~ | Low | Low | ✅ DONE (CRON_SCHEDULES covers all 34 routes in /api/health) |

## What "Done" Looks Like

The platform succeeds when:
- A CSE never needs to open the BURC Excel file directly
- Leadership can answer "how are we tracking?" without asking anyone
- Meeting follow-ups happen automatically, not through memory
- At-risk clients are flagged before they escalate
- The data on screen matches the source spreadsheets exactly
