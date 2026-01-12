# Strategic Planning UX Enhancement Recommendations

**Date:** 12 January 2026
**Status:** In Progress
**Research Sources:** MEDDPICC Framework, "Conversations That Win the Complex Sale" by Erik Peterson

---

## Executive Summary

Based on research of leading sales platforms (Salesforce, HubSpot, Gong, Clari, MEDDICC.com) and the "Conversations That Win the Complex Sale" methodology, this document outlines UX improvements for Territory Planning and Account Deep-Dive workflows.

---

## 1. MEDDPICC Framework Enhancements

### Current Implementation
- `MEDDPICCScoreCard.tsx` - 1-5 scoring per element with colour-coded progress bars
- AI-detected signals with apply functionality
- Recommended actions panel

### Recommended Improvements

#### 1.1 Stage-Gated Qualification
Link MEDDPICC scores to opportunity stages:

| Stage | Required Elements | Minimum Score |
|-------|-------------------|---------------|
| Discovery | Identify Pain (I) | 2/5 |
| Qualification | Metrics (M), Champion (C1) | 3/5 each |
| Proposal | Economic Buyer (E), Decision Criteria (D1) | 3/5 each |
| Negotiation | Decision Process (D2), Paper Process (P) | 4/5 each |
| Commit | All elements | 28/40 total |

#### 1.2 Deal Health Indicators
- Traffic-light system: Green (28+), Yellow (16-27), Red (<16)
- Compact 8-segment horizontal bar for territory rollups
- Hover to reveal element scores

---

## 2. "Conversations That Win" Integration

### Key Concepts from Erik Peterson

#### Value Wedge Framework
- **Unique Capabilities**: What only we can do
- **Customer Importance**: How critical to their success
- **Competitive Comparison**: How competitors fall short
- **Defensibility**: Why this can't be replicated

#### Unconsidered Needs
- Pain points the customer doesn't know they have
- Quantified cost of inaction
- Urgency triggers
- Proof points and case studies

#### Status Quo Challenge
- 60% of deals lost to "no decision"
- Must challenge current state
- Highlight hidden costs and risks

### Implementation: BURC Alignment

| BURC Element | Peterson Framework |
|--------------|-------------------|
| Business | Customer Results - What outcomes matter |
| Unconsidered | Unconsidered Needs - Hidden problems |
| Relevance | Value Wedge - Why us specifically |
| Compelling | Status Quo Challenge - Why change now |

---

## 3. Territory Planning Workflow

### ICP-Based Account Scoring
Weight account attributes:
- Industry Fit: 1.5x
- Company Size: 1.0x
- Tech Stack Fit: 1.5x
- Buying Signals: 2.0x
- Relationship Strength: 1.0x
- Expansion Potential: 1.5x

### Account Prioritisation Matrix
- Y-axis: ARR (revenue)
- X-axis: ICP Score (fit)
- Quadrants:
  - **Protect & Grow**: High ARR, High Fit
  - **Develop**: Low ARR, High Fit
  - **Maintain**: High ARR, Low Fit
  - **Evaluate**: Low ARR, Low Fit

### Pipeline Coverage Dashboard
Recommended coverage: 3-6x target
- Raw pipeline and weighted pipeline
- Coverage gauge with healthy zone highlighted
- Waterfall: Starting ARR → +Expansion → -Churn → =Net ARR

### Territory Health Scorecard

| Dimension | Metrics | Weight |
|-----------|---------|--------|
| Revenue Health | ARR retention, NRR, at-risk ARR | 30% |
| Pipeline Health | Coverage ratio, MEDDPICC avg, win rate | 25% |
| Customer Health | Avg NPS, CSI distribution, engagement | 25% |
| Relationship Health | Stakeholder coverage, champion strength | 20% |

---

## 4. Account Deep-Dive Enhancements

### Power-Interest Stakeholder Grid
Plot stakeholders on:
- Y-axis: Power (influence level)
- X-axis: Interest (engagement level)

Quadrants:
- **Manage Closely**: High power, high interest → Key players
- **Keep Satisfied**: High power, low interest → Keep informed
- **Keep Informed**: Low power, high interest → Show consideration
- **Monitor**: Low power, low interest → Minimal effort

### Relationship Strength Timeline
- Track sentiment changes over time
- Record touchpoints and notes
- Show trend (improving/stable/declining)
- Alert when contact overdue

### Risk-Action Linkage (Implemented)
- Link actions directly to risks they mitigate
- Visual indicator showing which risks have mitigation plans
- Coverage assessment (fully/partially/unaddressed)

---

## 5. Metrics Visualisation

### NPS Display
- Gauge chart: -100 to +100 with red/amber/green zones
- Stacked distribution: Promoters/Passives/Detractors
- Trend line with annotations

### Revenue Metrics
- **ARR**: Annual Recurring Revenue
- **TCV**: Total Contract Value
- **Weighted ACV**: Probability-adjusted pipeline value
- **NRR**: Net Revenue Retention

### Dashboard Layout
1. Hero metrics row with sparklines
2. ARR waterfall chart
3. Pipeline funnel by stage
4. Risk heatmap (ARR × risk level)

---

## 6. Priority Implementation Plan

### High Priority (Phase 1)
1. [x] Risk-Action linkage
2. [ ] Stage-gated MEDDPICC validation
3. [ ] Pipeline coverage with target indicator
4. [ ] Power-Interest stakeholder grid option

### Medium Priority (Phase 2)
5. [ ] Value Wedge preparation panel
6. [ ] Territory comparison view
7. [ ] Relationship strength timeline
8. [ ] ICP scoring matrix

### Future Enhancements (Phase 3)
9. [ ] AI signal auto-apply threshold
10. [ ] Meeting preparation automation
11. [ ] Territory review cadence reminders

---

## 7. Workflow Improvements

### Pre-Meeting Preparation
- T-24h: Auto-generate meeting brief
- T-1h: Push talking points notification
- During: Quick-access MEDDPICC sidebar
- Post: Debrief form with score updates

### Territory Review Cadence
- **Daily**: Overdue actions, meeting follow-ups
- **Weekly**: Pipeline movement, MEDDPICC changes
- **Monthly**: Account health trends, engagement gaps
- **Quarterly**: Territory rebalancing, target recalibration

---

## Sources

- HubSpot MEDDPICC Implementation
- Oliv.ai MEDDIC Guide
- MEDDICC Operating System (meddicc.com)
- Ebsta Deal Qualification
- DemandFarm Relationship Mapping
- "Conversations That Win the Complex Sale" by Erik Peterson
- Anaplan Territory Planning Best Practices
- Outreach Pipeline Coverage Guidelines
- Creately Power-Interest Grid
- CustomerGauge NPS Visualisation
