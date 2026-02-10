# Priorities

> Last updated: 10 February 2026

## Guiding Principles

1. **Data accuracy over features** — A wrong number erodes trust faster than a missing feature
2. **Automate everything** — CSEs shouldn't manually enter data that exists elsewhere
3. **Intelligent defaults** — Show the right information without requiring configuration
4. **Simple workflows** — Every click should feel purposeful, not navigational
5. **Graceful degradation** — AI features enhance but never block core workflows

## Completed Priorities (Phases 1-4)

All original priorities shipped. See git history for details.

- **P1: Data Integrity** — Client UUID migration, name aliases, BURC validation, dedup, fiscal year params
- **P2: UI/UX Unification** — PageShell (25+ pages), design tokens, DataTable, modals, FormRenderer + ARIA
- **P3: Automation & Intelligence** — Activity sync, 44 features LIVE, staleness alerting, goal hierarchy, compliance cron
- **P4: Production Hardening** — Sync logging (34/34 routes), webhook alerting, disaster recovery, health checks

## Priority 5: Design System Polish (Medium)

Raise UX coherence from 7.5/10 to ~8.5/10. Focus on the three lowest-scoring fragmentation areas.

| Task | Impact | Complexity | Score | Status |
|------|--------|------------|-------|--------|
| Unify loading states (Suspense/skeleton/spinner inconsistency) | Medium | Medium | 8/10 | Done |
| Migrate hand-rolled tables to enhanced DataTable (4 pages: knowledge, sales-hub, news-intelligence, operating-rhythm) | Medium | Medium | 7/10 | Done |
| Migrate simple forms to ModalFormDialog (AddContactModal, MilestoneFormModal) | Medium | Medium | 7/10 | Done |
| Adopt `LayoutTokens.card` for consistent card patterns | Low | Low | 6/10 | |
| Consolidate duplicate component patterns (badges, status indicators) | Low | Medium | 6/10 | |

## Priority 6: Goal Detail Phase 2 — Accordion Layout (Medium)

Research from P3 sprint: Baymard Institute found horizontal tabs have 27% content miss rate vs 8% for vertical sections. Linear, Notion, and Asana use collapsible accordion sections for detail views.

| Task | Impact | Complexity | Status |
|------|--------|------------|--------|
| Replace horizontal tabs with vertically stacked collapsible sections | High | Medium | |
| Sticky metadata sidebar on wide viewports | Medium | Medium | |
| Single-open accordion mode (each section collapses when another opens) | Medium | Low | |

## Priority 7: Performance & Bundle Size (Medium)

939 `'use client'` directives, 1,149 `console.log` statements. Opportunity for cleanup.

| Task | Impact | Complexity | Status |
|------|--------|------------|--------|
| Audit and remove stale `console.log` statements from production code | Low | Low | |
| Identify and lazy-load heavy client components (Three.js, D3, Recharts) | Medium | Medium | |
| Implement route-level code splitting for AI Lab / Visualisations | Medium | Medium | |
| Add Next.js `loading.tsx` files for major route groups | Medium | Low | |

## Priority 8: Testing & Quality (Low)

No test suite currently in place. Build incrementally starting with critical paths.

| Task | Impact | Complexity | Status |
|------|--------|------------|--------|
| Set up Vitest + React Testing Library infrastructure | Medium | Low | |
| Add tests for critical API routes (BURC sync, goals CRUD, actions CRUD) | High | Medium | |
| Add tests for shared hooks (useGanttData, useLeadingIndicators, useAnomalyDetection) | Medium | Medium | |
| Add Playwright E2E tests for core user workflows (login → dashboard → client detail) | High | High | |

## Priority 9: Accessibility Audit (Low)

FormFieldWrapper has ARIA support; broader audit needed for keyboard navigation, screen readers, and colour contrast.

| Task | Impact | Complexity | Status |
|------|--------|------------|--------|
| Audit keyboard navigation across all major pages | Medium | Medium | |
| Add skip-to-content links and focus management | Medium | Low | |
| Verify colour contrast ratios meet WCAG 2.1 AA | Medium | Low | |
| Add `aria-live` regions for dynamic content (alerts, toasts, data updates) | Medium | Medium | |

## What "Done" Looks Like

The platform succeeds when:
- A CSE never needs to open the BURC Excel file directly
- Leadership can answer "how are we tracking?" without asking anyone
- Meeting follow-ups happen automatically, not through memory
- At-risk clients are flagged before they escalate
- The data on screen matches the source spreadsheets exactly
- Every page loads fast, looks consistent, and works with keyboard alone
