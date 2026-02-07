# Priorities

## Guiding Principles

1. **Data accuracy over features** — A wrong number erodes trust faster than a missing feature
2. **Automate everything** — CSEs shouldn't manually enter data that exists elsewhere
3. **Intelligent defaults** — Show the right information without requiring configuration
4. **Simple workflows** — Every click should feel purposeful, not navigational
5. **Graceful degradation** — AI features enhance but never block core workflows

## Priority 1: Data Integrity (High)

The foundation everything else depends on. Users lose trust if numbers don't match.

| Task | Impact | Complexity |
|------|--------|------------|
| Complete client UUID migration across all API routes | High | Medium |
| Centralise client name mappings in `client_name_aliases` | High | Medium |
| Validate Excel cell references before BURC sync | High | Low |
| Document all BURC Excel cell references in mapping spreadsheet | Medium | Low |
| Add hash-based duplicate detection for activity events | Medium | Low |
| Parameterise fiscal year in sync scripts (currently hardcoded 2026) | Medium | Medium |

## Priority 2: UI/UX Unification (High)

Design system fragmentation (overall 5.5/10) creates inconsistent user experience.

| Task | Impact | Complexity |
|------|--------|------------|
| Create `<PageShell>` component for consistent page layouts | High | Medium |
| Build centralised design tokens (`design-tokens.ts`) | High | Medium |
| Unify data table component (TanStack wrapper) | Medium | Medium |
| Standardise modal/dialog pattern | Medium | Low |
| Create unified form field wrapper | Medium | Low |
| Hide internal pages (`/test-*`, `/chasen-icons`) from production | Low | Low |

## Priority 3: Automation & Intelligence (Medium)

Maximise the value of existing data through intelligent insights.

| Task | Impact | Complexity |
|------|--------|------------|
| Automate Activity Register sync (currently manual CLI only) | High | Low |
| Wire remaining "WIRED" features (4 features, mostly UI polish) | Medium | Low-Medium |
| Add alerting on data staleness (Slack/Teams notifications) | Medium | Medium |
| Seed goal hierarchy tables (currently 0 rows, possibly RLS-blocked) | Medium | Low |
| Automate compliance reconciliation via daily cron | Medium | Low |

## Priority 4: Production Hardening (Medium)

| Task | Impact | Complexity |
|------|--------|------------|
| Add comprehensive sync logging (INSERT/UPDATE/SKIP decisions) | Medium | Low |
| Implement data staleness alerting | Medium | Medium |
| Document and test disaster recovery (what if sync breaks?) | Medium | Low |
| Add health checks for cron routes | Low | Low |

## Priority 5: Feature Polish (Lower)

The 4 "WIRED" features that need minor polish to become fully LIVE:

| Feature | Phase | What's Missing |
|---------|-------|---------------|
| useLeadingIndicators | 7 | Wire real MetricData[] into dashboard |
| Timeline Replay | 8 | Build dedicated visualisation component |
| NL Workflows | 10 | Complete approval workflow UI |
| Meeting Co-Pilot RAG | 10 | Rate limiting and suggestion deduplication |

## What "Done" Looks Like

The platform succeeds when:
- A CSE never needs to open the BURC Excel file directly
- Leadership can answer "how are we tracking?" without asking anyone
- Meeting follow-ups happen automatically, not through memory
- At-risk clients are flagged before they escalate
- The data on screen matches the source spreadsheets exactly
