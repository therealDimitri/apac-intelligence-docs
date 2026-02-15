# Account Planning Coach — Comprehensive UX Overhaul

**Date:** 10 February 2026
**Type:** Feature Development + Bug Fixes + AI Enhancement
**Status:** Complete

## Summary

Shipped 10 bug fixes across 3 workstreams (My Plans page, Plan Detail navigation, ChaSen AI Coach) in 4 phases. Major deliverables: plan grouping, sub-step navigation architecture, methodology-specific AI coaching with auto-suggestions, and dynamic client-specific quick tips. 19 files changed (+5,368 / -3,542 lines).

**Commit:** `f6d8294c` — All 4 phases

## Workstream A: My Plans Page (4 items)

| # | Type | Description |
|---|------|-------------|
| A1 | BUG | Status value mismatch — `statusConfig` keys didn't match DB values. Fixed to: `draft`, `in_progress`, `pending_review`, `approved`, `archived` |
| A2 | FEATURE | Plan rename — auto-generate default names (`"{Territory} Strategic Plan FY{year}"`), display on PlanCard, click-to-edit inline rename |
| A3 | FEATURE | Plan grouping — Group By dropdown (owner/status/territory/client) with collapsible sections showing plan count + avg completion % |
| A4 | FEATURE | Approval workflow — wired existing `ApprovalPanel` into plan detail, role-based visibility, status badges on cards |

**Files:** `planning/page.tsx`, `planning/strategic/[id]/page.tsx`, `api/planning/strategic/route.ts`

## Workstream B: Plan Detail Navigation (5 items)

| # | Type | Description |
|---|------|-------------|
| B1 | BUG | Removed Quick Jump buttons (redundant — sidebar + breadcrumbs already provide navigation) |
| B2 | BUG | Removed WizardMinimap circular orbit widget (visual clutter, duplicated step nav) |
| B3 | BUG | Discovery scroll-to-top — `handleStepChange` now resets scroll on step navigation |
| B4 | FEATURE | Sub-step navigation — `SubStep` type, parent/child sidebar tree, step components render only active sub-section, breadcrumbs show `Step > Sub-step`, Next/Previous traverses sub-steps |
| B4e | BUG | Setup dropdown consistency — standardised CSE and Collaborator dropdown styling |

**Sub-step mapping:**

| Parent Step | Sub-Steps |
|---|---|
| Setup | _(single view)_ |
| Discovery | Summary, Gap Discovery, Client Gap Diagnosis |
| Stakeholders | Overview, Tactical Empathy, Black Swan Discovery, "That's Right" Moment, Calibrated Questions, Accusation Audit |
| Opportunities | AI Tips, Plan Coverage, Opportunity Qualification, StoryBrand Narratives, Forecast Simulation |
| Risks | Risk Overview, Recovery Confidence, Accusation Audit, Recovery Narrative, Mitigation Strategy |
| Actions | Plan Summary, Action Readiness, Actions |

**Files:** `planning/strategic/new/page.tsx`, `steps/*.tsx`, `steps/types.ts`
**Deleted:** `WizardMinimap.tsx` (both copies), `wizard/index.ts` export removed

## Workstream C: ChaSen AI Coach (6 items)

| # | Type | Description |
|---|------|-------------|
| C1 | FEATURE | Sub-step aware coaching buttons — methodology-specific per step (Gap Selling for Discovery, Voss for Stakeholders, MEDDPICC for Opportunities, Wortmann for Recovery) |
| C2 | FEATURE | 6 new AI action types in `usePlanAI`: `gap_summary_analysis`, `gap_client_diagnosis`, `coverage_analysis`, `tactical_empathy_coach`, `accusation_audit_coach`, `recovery_narrative_coach` |
| C3 | FEATURE | Backend prompt specialisation — 6 specialised prompt builders per methodology in both `new/ai/route.ts` and `[id]/ai/route.ts`, with data-driven fallbacks |
| C4 | FEATURE | Auto-generate suggestions on sub-step entry — 1.5s debounce, ref-based cache (`Map<stepKey, AIResponse>`), separate state from manual insights |
| C5 | FEATURE | `AISuggestionCard` component — loading shimmer, 250-char preview with expand/collapse, copy, thumbs up/down feedback, actionable suggestion pills |
| C6 | FEATURE | Dynamic quick tips — reference specific client names, health scores, NPS values, ARR figures (e.g., "SA Health's NPS dropped to -46 — investigate root causes") |

**Files:** `AIInsightsPanel.tsx`, `AISuggestionCard.tsx` (new), `usePlanAI.ts`, `new/ai/route.ts`, `[id]/ai/route.ts`

## Architecture Decisions

### Auto-Suggestion Dual-State Pattern
The `usePlanAI` hook's shared `lastResponse` handles user-triggered insights, while a separate `autoSuggestions` state with direct `fetch()` calls handles auto-generated ones. This prevents auto-fire from overwriting manual responses. The ref-based cache means revisiting a sub-step loads instantly.

### Sub-Step Rendering Strategy
Each step component receives `activeSubStep: string | null`. When set, it renders ONLY that sub-section using conditional guards: `(!activeSubStep || activeSubStep === 'id')`. When null (steps without sub-steps like Setup), everything renders.

### Prompt Builder Chain
`InsightType` (UI button) → `AIActionType` (hook method) → `action` parameter → backend switch → specialised prompt builder → MatchaAI (Claude Sonnet 4.5). Each prompt builder references the methodology by name and instructs the AI to use specific client names with data points.

## Verification Results

| Area | Test | Result |
|------|------|--------|
| My Plans | Status badges (Draft/In Progress/Approved) | Pass |
| My Plans | Stats bar (51 total, 46 drafts, 2 in progress, 1 approved) | Pass |
| My Plans | Group by Owner (5 groups with plan counts + avg %) | Pass |
| Plan Detail | Discovery scroll-to-top | Pass |
| Plan Detail | Quick Jump and WizardMinimap removed | Pass |
| Plan Detail | Sub-step breadcrumbs (e.g., "Risks > Risk Overview") | Pass |
| AI Coach | Methodology-specific buttons per step | Pass |
| AI Coach | Auto-suggestions loading card on step entry | Pass |
| AI Coach | Dynamic tips with client names ("SA Health health: 31") | Pass |
