# APAC Intelligence Dashboard - UI/UX Enhancement Proposal

**Date**: 16 January 2026
**Author**: Executive UI/UX Strategy
**Purpose**: Transform data visibility into actionable intelligence through experimental interface design

---

## Executive Summary

This proposal outlines advanced UI/UX enhancements that transform raw data into intuitive, trustworthy experiences. Based on the comprehensive data audit findings (37.4% BURC match rate, data coverage gaps), these designs address the fundamental need for **data confidence at a glance**.

---

## 1. Data Confidence Indicators

### Current State
Users see "In BURC" / "Not In BURC" badges without context about what this means for decision-making.

### Proposed: Data Trust Score™

Introduce a visual confidence system that communicates data reliability instantly.

```
┌─────────────────────────────────────────────────────────────────┐
│  OPPORTUNITY: SA Health iPro Migration                          │
│                                                                 │
│  ┌─────────────────────────────────────────┐                   │
│  │  DATA CONFIDENCE                        │                   │
│  │  ████████████░░░░  78%                 │                   │
│  │                                         │                   │
│  │  ✓ Oracle Quote Matched                 │                   │
│  │  ✓ Client Verified                      │                   │
│  │  ○ Close Date Unconfirmed               │                   │
│  │  ✓ ACV Within Range                     │                   │
│  └─────────────────────────────────────────┘                   │
│                                                                 │
│  [View Full Lineage] [Flag for Review]                         │
└─────────────────────────────────────────────────────────────────┘
```

**Implementation Principles:**
- **Progressive Disclosure**: Summary score visible, details on hover/click
- **Traffic Light System**: Green (>80%), Amber (50-80%), Red (<50%)
- **Actionable Gaps**: Each unverified item links to resolution workflow

---

## 2. Pipeline Reconciliation Dashboard

### The Problem
97 unmatched opportunities represent blind spots in strategic planning.

### Proposed: Smart Reconciliation Interface

```
┌─────────────────────────────────────────────────────────────────┐
│  PIPELINE RECONCILIATION                           🔄 Live Sync │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Match Health                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ ███████████████░░░░░░░░░░░░░░░░░░░░░  37.4% matched     │   │
│  │ Target: 95% ─────────────────────────────────────►       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌──────────────────────────┐  ┌──────────────────────────┐   │
│  │  NEEDS ATTENTION         │  │  AUTO-SUGGESTED MATCHES  │   │
│  │                          │  │                          │   │
│  │  DoH Victoria (28)    ⚠️  │  │  WA Health → WA Health   │   │
│  │  SA Health (14)       ⚠️  │  │  ✓ 95% confidence        │   │
│  │  GRMC (10)            ⚠️  │  │  [Accept] [Review]       │   │
│  │                          │  │                          │   │
│  │  [Bulk Resolve]          │  │  Mount Alvernia → MAH    │   │
│  └──────────────────────────┘  │  ✓ 92% confidence        │   │
│                                │  [Accept] [Review]       │   │
│                                └──────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  MATCH TIMELINE                                         │   │
│  │  ──────●────────●──────●───────●────────────────────►   │   │
│  │      Jan 10   Jan 12  Jan 14  Jan 16                    │   │
│  │       +23      +10     +5     +0 matches                │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Key Features:**
- **One-Click Resolution**: AI suggests matches, user confirms
- **Bulk Actions**: Resolve entire client groups at once
- **Trend Visibility**: See matching rate over time
- **Zero State**: Clear path when 100% matched

---

## 3. Chasen AI Transparency Panel

### Current State
Users don't know what data Chasen is using to generate responses.

### Proposed: Context Transparency Sidebar

```
┌─────────────────────────────────────────────────────────────────┐
│  CHASEN AI                                      [Collapse ─]    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  💬 "What's the health status of SA Health?"                    │
│                                                                 │
│  ─────────────────────────────────────────────────────────      │
│                                                                 │
│  SA Health shows concerning health metrics:                     │
│  • Health Score: 44/100 (Critical)                              │
│  • NPS: -46 (Detractor)                                         │
│  • Support Score: 93/100 (Excellent)                            │
│                                                                 │
│  The low health score is primarily driven by...                 │
│                                                                 │
│  ─────────────────────────────────────────────────────────      │
│                                                                 │
│  ┌───────────────────────────────────────┐                     │
│  │  📊 DATA SOURCES USED                 │  [Expand All]       │
│  ├───────────────────────────────────────┤                     │
│  │  ▼ client_health_history              │  12 records         │
│  │    └ Latest: 16 Jan 2026              │                     │
│  │  ▼ nps_responses                      │  3 records          │
│  │    └ Latest: Q4 2025                  │                     │
│  │  ▶ unified_meetings                   │  5 records          │
│  │  ▶ actions                            │  8 records          │
│  │                                       │                     │
│  │  ⚠️ Missing Data:                     │                     │
│  │  • No pipeline data for SA Health     │                     │
│  │  • No BURC financial linkage          │                     │
│  └───────────────────────────────────────┘                     │
│                                                                 │
│  [Report Issue] [Improve Answer] [Share Response]               │
└─────────────────────────────────────────────────────────────────┘
```

**Design Principles:**
- **Source Attribution**: Every fact links to its source
- **Freshness Indicators**: Show data recency
- **Gap Highlighting**: Proactively surface missing data
- **Feedback Loop**: Users can correct/improve responses

---

## 4. Strategic Planning Wizard Enhancements

### Current State
Wizard shows BURC badges but doesn't explain implications.

### Proposed: Intelligent Data Quality Warnings

```
┌─────────────────────────────────────────────────────────────────┐
│  STRATEGIC PLANNING WIZARD                                      │
│  Step 3: Opportunity Strategy                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  ⚠️ DATA QUALITY ALERT                                   │   │
│  │                                                          │   │
│  │  14 opportunities in your portfolio are not linked to    │   │
│  │  BURC financial data. This may affect:                   │   │
│  │                                                          │   │
│  │  • Revenue forecasting accuracy                          │   │
│  │  • Pipeline coverage calculations                        │   │
│  │  • Territory target tracking                             │   │
│  │                                                          │   │
│  │  [Review Now] [Proceed Anyway] [Learn More]              │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Plan Coverage (61)                                             │
│  ─────────────────────────────────────────────────────────      │
│                                                                 │
│  ┌────┬────────────────────────────────────────────────────┐   │
│  │ ☐  │ SA Health iPro Migration                           │   │
│  │    │ $450k ACV  │  Q2 2026  │  75%  │  In BURC ✓       │   │
│  │    │                                                    │   │
│  │    │ DATA CONFIDENCE: ████████████░░░  78%             │   │
│  ├────┼────────────────────────────────────────────────────┤   │
│  │ ☐  │ DoH Victoria EMR Phase 2                           │   │
│  │    │ $1.2M ACV  │  Q3 2026  │  50%  │  Not In BURC ⚠️  │   │
│  │    │                                                    │   │
│  │    │ DATA CONFIDENCE: ████░░░░░░░░░░░  32%             │   │
│  │    │ ⚠️ No BURC entry - financial tracking unavailable  │   │
│  │    │ [Create BURC Entry] [Link to Existing]             │   │
│  └────┴────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Key Innovations:**
- **Contextual Warnings**: Explain WHY data matters
- **Inline Resolution**: Fix issues without leaving workflow
- **Progressive Enhancement**: Core functionality works, data quality improves experience

---

## 5. Data Freshness Indicators

### The Problem
Users don't know when data was last synced.

### Proposed: Global Data Freshness Header

```
┌─────────────────────────────────────────────────────────────────┐
│  APAC Intelligence                                              │
│  ─────────────────────────────────────────────────────────      │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  DATA STATUS                                    [Sync]  │   │
│  │                                                         │   │
│  │  BURC Pipeline    ● 2h ago    ───────────────────────  │   │
│  │  Sales Budget     ● 4h ago    ───────────────────────  │   │
│  │  Health Scores    ● Live      ─────────────● (now)     │   │
│  │  NPS Responses    ● 2d ago    ──────● (stale)          │   │
│  │                                                         │   │
│  │  Overall Freshness: 87%                                 │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Design Elements:**
- **Timeline Visualisation**: See sync history at a glance
- **Staleness Warnings**: Amber for >24h, Red for >7d
- **One-Click Refresh**: Trigger sync from UI
- **Intelligent Scheduling**: Show next scheduled sync

---

## 6. Experimental: Conversational Data Exploration

### Vision: Natural Language Data Queries

Move beyond traditional dashboards to conversational exploration.

```
┌─────────────────────────────────────────────────────────────────┐
│  DATA EXPLORER                                    [Voice] [Type]│
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  "Show me opportunities closing in Q2 that aren't in BURC"      │
│                                                                 │
│  ─────────────────────────────────────────────────────────      │
│                                                                 │
│  Found 23 opportunities closing Q2 2026 without BURC entries:   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Interactive Chart                                       │   │
│  │                                                         │   │
│  │        ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░                 │   │
│  │                                                         │   │
│  │  DoH Victoria ████████████████ (12)                     │   │
│  │  GRMC         ████████ (6)                              │   │
│  │  Synapxe      ██████ (4)                                │   │
│  │  Other        █ (1)                                     │   │
│  │                                                         │   │
│  │  Total ACV at Risk: $4.2M                               │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Suggested follow-ups:                                          │
│  • "Why are these not in BURC?"                                 │
│  • "Create BURC entries for these"                              │
│  • "Export to Excel"                                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Innovation Elements:**
- **Natural Language Interface**: Ask questions in plain English
- **Smart Visualisations**: Auto-generate appropriate charts
- **Action Suggestions**: AI recommends next steps
- **Multi-Modal Input**: Voice, text, or click

---

## 7. Micro-Interactions & Delight

### Data Loading States

Replace spinners with contextual loading messages:

```
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│     ◐ Connecting to BURC pipeline...                        │
│     ◑ Matching 155 opportunities...                         │
│     ◒ Calculating confidence scores...                      │
│     ◓ Building your insights...                             │
│                                                              │
│     "Did you know? The Rule of 40 measures if your          │
│      growth rate + profit margin exceeds 40%"               │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Success Celebrations

When match rate improves:

```
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│     🎉 Match Rate Improved!                                  │
│                                                              │
│     37.4% → 52.3%                                           │
│                                                              │
│     +23 opportunities now linked to BURC data               │
│                                                              │
│     [View Matches] [Share Achievement]                       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 8. Implementation Priority Matrix

| Enhancement | Impact | Effort | Priority |
|------------|--------|--------|----------|
| Data Confidence Indicators | High | Medium | P1 |
| Pipeline Reconciliation Dashboard | High | High | P1 |
| Data Freshness Header | Medium | Low | P1 |
| Chasen AI Transparency | High | Medium | P2 |
| Strategic Wizard Enhancements | High | Medium | P2 |
| Conversational Data Explorer | Very High | Very High | P3 |
| Micro-Interactions | Low | Low | P3 |

---

## 9. Design System Additions

### New Components Required

```typescript
// Data Confidence Badge
<DataConfidenceBadge
  score={78}
  factors={['oracle_matched', 'client_verified', 'acv_confirmed']}
  missingFactors={['close_date_unconfirmed']}
  onViewLineage={() => {}}
/>

// Freshness Indicator
<DataFreshnessIndicator
  source="burc_pipeline"
  lastSynced={new Date('2026-01-16T10:00:00')}
  isStale={false}
  onRefresh={() => {}}
/>

// Reconciliation Card
<ReconciliationSuggestion
  sourceOpportunity={salesOpp}
  suggestedMatch={burcOpp}
  confidence={0.92}
  onAccept={() => {}}
  onReject={() => {}}
/>

// AI Source Attribution
<SourceAttribution
  sources={[
    { table: 'client_health_history', count: 12, lastUpdated: '2026-01-16' },
    { table: 'nps_responses', count: 3, lastUpdated: '2025-12-15' },
  ]}
  missingData={['pipeline_data', 'burc_linkage']}
/>
```

### Colour Palette Extensions

```scss
// Data Confidence Colours
$confidence-high: #22C55E;     // Green - 80%+
$confidence-medium: #F59E0B;   // Amber - 50-80%
$confidence-low: #EF4444;      // Red - <50%
$confidence-unknown: #6B7280;  // Gray - No data

// Freshness Colours
$fresh: #22C55E;               // <1 hour
$recent: #84CC16;              // 1-24 hours
$stale: #F59E0B;               // 1-7 days
$outdated: #EF4444;            // >7 days
```

---

## 10. Conclusion

These UI/UX enhancements transform the APAC Intelligence Dashboard from a data display tool into an **intelligent decision support system**. By making data quality visible, actionable, and trustworthy, users can:

1. **Make confident decisions** with Data Trust Scores
2. **Quickly resolve data gaps** with smart reconciliation
3. **Understand AI reasoning** with source transparency
4. **Stay current** with freshness indicators
5. **Explore naturally** with conversational interfaces

The implementation roadmap prioritises high-impact, low-effort improvements first, building toward the vision of truly conversational business intelligence.

---

*Prepared by Executive UI/UX Strategy*
*16 January 2026*
