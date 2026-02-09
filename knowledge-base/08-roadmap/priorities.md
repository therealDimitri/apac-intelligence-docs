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
| Add hash-based duplicate detection for activity events | Medium | Low | Open |
| ~~Parameterise fiscal year in sync scripts (currently hardcoded 2026)~~ | Medium | Medium | ✅ DONE |

## Priority 2: UI/UX Unification (High)

Design system fragmentation (overall 5.5/10) creates inconsistent user experience.

| Task | Impact | Complexity | Status |
|------|--------|------------|--------|
| ~~Create `<PageShell>` component for consistent page layouts~~ | High | Medium | ✅ DONE — adopted by 11+ pages |
| Build centralised design tokens (`design-tokens.ts`) | High | Medium | Open |
| Unify data table component (TanStack wrapper) | Medium | Medium | Open |
| Standardise modal/dialog pattern | Medium | Low | Open |
| Create unified form field wrapper | Medium | Low | Open |
| ~~Hide internal pages (`/test-*`, `/chasen-icons`) from production~~ | Low | Low | ✅ DONE |

## Priority 3: Automation & Intelligence (Medium)

Maximise the value of existing data through intelligent insights.

| Task | Impact | Complexity | Status |
|------|--------|------------|--------|
| ~~Automate Activity Register sync (currently manual CLI only)~~ | High | Low | ✅ DONE |
| ~~Wire remaining "WIRED" features~~ | Medium | Low-Medium | ✅ DONE (0 WIRED, 41 LIVE) |
| Add alerting on data staleness (Slack/Teams notifications) | Medium | Medium | Open |
| ~~Seed goal hierarchy tables~~ | Medium | Low | ✅ DONE |
| Automate compliance reconciliation via daily cron | Medium | Low | Open |

## Priority 4: Production Hardening (Medium)

| Task | Impact | Complexity |
|------|--------|------------|
| Add comprehensive sync logging (INSERT/UPDATE/SKIP decisions) | Medium | Low |
| Implement data staleness alerting | Medium | Medium |
| Document and test disaster recovery (what if sync breaks?) | Medium | Low |
| Add health checks for cron routes | Low | Low |

## What "Done" Looks Like

The platform succeeds when:
- A CSE never needs to open the BURC Excel file directly
- Leadership can answer "how are we tracking?" without asking anyone
- Meeting follow-ups happen automatically, not through memory
- At-risk clients are flagged before they escalate
- The data on screen matches the source spreadsheets exactly
