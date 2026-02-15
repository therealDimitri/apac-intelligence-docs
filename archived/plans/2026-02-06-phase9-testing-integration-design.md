# Phase 9 Testing & Integration Design

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create automated E2E tests for Phase 9 features and integrate sentiment analysis into existing UI.

**Architecture:** Playwright tests for each Phase 9 feature; sentiment components added to client pages and tables; alerts merged into dashboard.

**Tech Stack:** Playwright, React, existing sentiment components from Phase 9.6

---

## 1. E2E Test Suite

### Structure

```
tests/e2e/phase9/
├── task-queue.spec.ts      # /tasks
├── network-graph.spec.ts   # /visualisation/network
├── digital-twin.spec.ts    # /twins
├── deal-sandbox.spec.ts    # /sandbox
├── pipeline-3d.spec.ts     # /visualisation/pipeline
├── meeting-cohost.spec.ts  # /meetings/[id]/live
└── sentiment.spec.ts       # Sentiment API routes
```

### Test Pattern

Each test file follows:
1. Navigate to feature page
2. Verify page loads without console errors
3. Test core interactions (buttons, forms, filters)
4. Verify data displays correctly
5. Screenshot on failure

### Auth Strategy

Use Playwright persistent context with existing SSO session.

---

## 2. ClientSentimentPanel Integration

### Location

`src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx`

### Changes

1. Import `ClientSentimentPanel` from `@/components/sentiment`
2. Add component at bottom of RightColumn
3. Pass `clientId` prop (already available in scope)

### Behaviour

- Self-contained data fetching via `useSentimentAnalysis`
- Loading skeleton while fetching
- Empty state if no sentiment data
- Period selector (7d/30d/90d) built-in
- Actionable alerts (acknowledge/dismiss)

---

## 3. SentimentSparkline in Tables

### Tables to Update

| Page | File |
|------|------|
| Portfolio | `src/app/(dashboard)/portfolio/page.tsx` |
| Actions | `src/app/(dashboard)/actions/page.tsx` |
| Meetings | `src/app/(dashboard)/meetings/page.tsx` |
| Support | `src/app/(dashboard)/support/page.tsx` |
| Dashboard At-Risk | Dashboard widget |

### Implementation

Create `ClientNameWithSentiment.tsx` wrapper component:

```tsx
interface Props {
  clientId: string
  clientName: string
}

export function ClientNameWithSentiment({ clientId, clientName }: Props) {
  return (
    <div className="flex items-center gap-2">
      <span>{clientName}</span>
      <SentimentSparkline clientId={clientId} width={60} height={20} />
    </div>
  )
}
```

### Performance

- Sparkline is lightweight SVG (no chart library)
- Each component fetches minimal data (7 points)
- Graceful fallback if no data

---

## 4. Sentiment Alerts Integration

### Current State

- Escalations shown in dashboard widgets
- No centralised notification component

### Integration

1. Modify dashboard alerts widget to query both:
   - `escalations` table
   - `sentiment_alerts` table (status = 'pending')

2. Combine and sort by severity, then date

3. Display using:
   - Existing escalation cards for escalations
   - `SentimentAlertCard` for sentiment alerts

4. Link sentiment alerts to client detail page

### Files to Modify

- Dashboard page or alerts widget component
- Add sentiment count to nav alert badges (if any)

---

## Success Criteria

1. All 7 E2E tests pass
2. ClientSentimentPanel renders on client detail pages
3. Sparklines appear in all client tables
4. Sentiment alerts show in dashboard alerts widget
5. No console errors on any page
