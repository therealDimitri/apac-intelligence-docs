# Per-Client Gap Discovery Confidence

**Date:** 2026-02-11
**Status:** Approved
**Approach:** Client-Tabbed Scorecard (Approach A)

## Problem

Gap Discovery Confidence is currently scored once for the entire portfolio (5 questions, 1-5 scale, max 25). CSEs manage 5-10 clients, and their understanding varies significantly per client. A single portfolio score masks weak spots — a CSE might deeply understand 3 clients but have zero discovery on 2 others.

## Design

### Data Model

Add `clientConfidenceScores` to `DiscoveryDiagnosisData`, keyed by client ID. Existing `confidenceScores` and `totalScore` become computed portfolio averages for backward compatibility.

```typescript
interface DiscoveryDiagnosisData {
  clientConfidenceScores: Record<string, GapDiagnosisConfidence>  // NEW: per-client
  confidenceScores: GapDiagnosisConfidence  // computed average (backward compat)
  totalScore: number                         // computed average total
  clients: DiscoveryClientAnalysis[]
  notes?: string
  aiSuggestions?: DiscoverySuggestions
  dataEvidence?: DataEvidence[]
}
```

**Migration:** If `clientConfidenceScores` is empty but `confidenceScores` exists, the UI renders legacy mode (current single-set behaviour). New assessments populate per-client.

### Client Tab Bar

Positioned between the Score Gate indicator and the Gap Discovery Confidence questionnaire. Each tab represents a portfolio client.

**Tab badge states:**
- `—` (grey) — not started
- `8/25` (amber) — in progress, below 12/25 minimum
- `18/25` (green) — meets threshold
- `✓` (green tick) — 12+ and all 5 questions answered

**Portfolio tab** (last position): Read-only averaged scores with client breakdown table. No editing.

**Question text:** Client name injected into each question. E.g., "How well do you understand the current problems **Epworth Healthcare** is experiencing?"

### Interaction & Efficiency

- **Auto-advance:** After scoring all 5 questions for a client, auto-advance to next incomplete tab with toast notification
- **AI pre-fill:** Single "Pre-fill from data" button uses health scores, NPS, support data to set initial scores. Pre-filled scores get an "AI" dot indicator
- **Keyboard nav:** Left/right arrows switch clients. 1-5 keys score questions. Power users complete all scores in <2 minutes
- **Skip:** "Defer" link marks a client as excluded from averages. Flagged in Summary as "Deferred — no gap assessment"

### Pre-fill Heuristics

| Data Signal | Score Mapping |
|---|---|
| Health < 60 | `understandProblems: 2` (known issues) |
| Health 60-80 | `understandProblems: 3` (some awareness) |
| NPS available | `articulateFutureState: 3` (feedback = some visibility) |
| NPS verbatims exist | `articulateFutureState: 4` (specific feedback) |
| No recent meetings (90d) | `knowCostOfInaction: 1` (not discussed) |
| Gap diagnosis filled | `quantifiedImpact: 3` (some work done) |
| Cost of inaction > 0 | `knowCostOfInaction: 4` (quantified) |

### Score Gate & Validation

- **Per-client minimum:** 12/25 (lowered from portfolio-wide 15 since per-client is more granular)
- **Portfolio average minimum:** 15/25
- **Gate display:** "3 of 5 clients ready. 2 need attention" with clickable client names
- **Below Minimum alert:** Lists specific clients needing work, clickable to jump to their tab
- **Next button:** Blocked until all non-skipped clients hit 12/25 AND portfolio average hits 15/25

### Summary Sub-Step Update

- "Confidence Score" card becomes a mini bar chart — one bar per client
- New "Lowest Client" callout highlights who needs the most discovery work
- Skipped clients shown as "Deferred" in grey

## Component Architecture

### New (1 file)

- `src/components/planning/methodology/ClientConfidenceTabs.tsx` — Tab bar, badges, auto-advance, pre-fill, keyboard nav. Wraps existing `SelfAssessmentScoring` components scoped to active client.

### Modified (4 files)

- `src/lib/planning/types.ts` — Add `clientConfidenceScores` field
- `src/app/(dashboard)/planning/strategic/new/steps/DiscoveryDiagnosisStep.tsx` — Replace direct `QuestionnaireSection` in gap-discovery sub-step with `ClientConfidenceTabs`. Update Summary sub-step with per-client breakdown.
- `src/app/(dashboard)/planning/strategic/new/page.tsx` — Route AI suggestion handler to active client. Compute portfolio averages from per-client data.
- `src/components/planning/methodology/index.ts` — Export new component

### Unchanged

- `SelfAssessmentScoring` — receives per-client scores, renders identically
- `ScoreGateIndicator` — receives computed averages
- `ScoreLegend`, `AIPrePopulation`, `QuestionnaireSection` — no changes
