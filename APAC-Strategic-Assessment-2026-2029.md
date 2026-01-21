# APAC Strategic Assessment 2026-2029
## Data-Driven Analysis: Risks, Opportunities, and Turnaround Plan

*Generated: 21 January 2026*
*Data Sources: BURC Performance Excel, Oracle Sales Pipeline, Supabase (NPS, Attrition, Renewals, Financial Alerts)*

---

## Executive Summary

The APAC region faces a critical inflection point. We have **$2.72M in confirmed attrition** against **$8.36M in weighted pipeline**, which appears healthy on paper. However, deeper analysis reveals structural vulnerabilities that, if unaddressed, could cascade into a regional crisis by 2028.

**The Unspoken Truth:** Our pipeline assumes 100% conversion. At realistic rates (35%), we barely cover attrition. Meanwhile, 62% of our attrition is concentrated in a single departure (Sing Health), and our largest remaining client (SA Health, 21% of maintenance) has an NPS of 6.1—placing $6.8M of annual revenue in the "at-risk" category.

This document provides a frank assessment of where we stand and a structured plan to turn the situation around.

---

## Part 1: Financial Reality

### 1.1 The Attrition Trajectory

| Fiscal Year | Attrition Amount | Key Clients |
|-------------|------------------|-------------|
| FY2025 | $215K | GHA Regional Opal |
| FY2026 | $1.69M | Sing Health (all entities) |
| FY2027 | $549K | Parkway |
| FY2028 | $272K | NCS |
| **TOTAL** | **$2.72M** | |

*Source: burc_attrition table, verified against 2026 APAC Performance.xlsx Attrition sheet*

**Unspoken Truth #1:** Sing Health represents **62% of total attrition**. This is not a diversified risk—it's a single-point-of-failure that has already occurred. The departure is confirmed; the question is how we manage the exit and prevent reputational contagion in the Singapore market.

**Unspoken Truth #2:** Parkway ($549K, FY2027) and NCS ($272K, FY2028) are currently flagged but receiving minimal attention. If these proceed unchallenged, we lose an additional $821K beyond Sing Health.

### 1.2 Revenue Concentration Risk

**Top 10 Maintenance Clients (FY2026):**

| Rank | Client | Annual Revenue | Cumulative % |
|------|--------|----------------|--------------|
| 1 | SA Health | $6.8M | 21.4% |
| 2 | WA Health | $4.2M | 34.6% |
| 3 | Sing Health | $3.1M | 44.4% |
| 4 | GHA | $1.8M | 50.1% |
| 5 | Western Health | $1.2M | 53.9% |
| 6-10 | Others | $4.6M | 68.4% |

*Source: burc_revenue_detail table, fiscal_year=2026, revenue_type='Maint'*

**Unspoken Truth #3:** Three clients represent **44% of maintenance revenue**. Losing any one of them would be catastrophic. SA Health alone is larger than our entire attrition exposure—and their NPS is 6.1.

**Unspoken Truth #4:** Post-Sing Health departure, our top-3 concentration actually *increases* to **~52%** of remaining maintenance base. We're becoming more dependent on fewer clients, not less.

### 1.3 Pipeline Reality Check

**2026 Sales Budget (Oracle, 14 Jan 2026):**

| Team Member | Role | Weighted ACV Target | Key Deals |
|-------------|------|---------------------|-----------|
| Johnathan Salisbury | CSE | $1.27M | WA Health renewal ($1.03M = 82% of target) |
| Laura Messing | CSE | $2.68M | SA Health Renal ($900K), Sunrise renewal ($378K) |
| New Asia CSE | CSE | $2.49M | MAH Azure ($433K), MINDEF upgrade ($258K) |
| Tracey Bland | CSE | $1.93M | GHA extension ($176K), AWH ($159K) |
| **CSE Total** | | **$8.36M** | |
| Anu Pradhan | CAM | $4.67M | Vic HIE portfolio, SA Health support |
| Nikki Wei | CAM | $2.49M | Asia portfolio incl. NCS/MINDEF, Synapxe |
| **CAM Total** | | **$7.15M** | |

*Source: APAC 2026 Sales Budget 14Jan2026 v0.1.xlsx, CSE Summary Wgt ACV sheet*

**The Math That Matters:**

```
CSE Weighted Pipeline:        $8.36M
Total Attrition (2025-2028):  $2.72M
Apparent Surplus:             $5.64M ✓

BUT at 35% conversion rate:
Realistic New Revenue:        $2.93M
Net Position:                 $0.21M surplus (razor thin)

AND if SA Health churns (NPS 6.1):
Additional Risk:              $6.8M
Adjusted Position:            -$6.59M catastrophic loss
```

**Unspoken Truth #5:** Our pipeline looks healthy, but it's built on fragile assumptions. Johnathan Salisbury's entire year depends on one deal (WA Health, 82% of target). Laura Messing's $2.68M target is at risk because the client she's selling to (SA Health) is unhappy with our service.

**Unspoken Truth #6:** The Synapxe NEHR RFP ($2M+ opportunity) is marked "Omitted" in the pipeline. Synapxe is part of the NCS/MINDEF ecosystem (Singapore government healthcare IT), separate from Sing Health (the healthcare provider cluster). This deal could offset Sing Health losses, but **MINDEF NPS is declining (-1.3 trend)** and NCS has $272K attrition flagged for FY2028. The government IT relationship is deteriorating—we need to stabilise before we can expand.

### 1.4 EBITA Trajectory

| Metric | FY2024 | FY2025 | FY2026 Target | FY2026 Forecast |
|--------|--------|--------|---------------|-----------------|
| Gross Revenue | $32.1M | $25.7M | $31.0M | $28.4M |
| EBITA | $7.2M | $5.8M | $6.2M | $5.1M |
| EBITA Margin | 22.4% | 22.6% | 20.0% | 18.0% |

*Source: burc_annual_financials, 2026 APAC Performance.xlsx EBITA sheet*

**Unspoken Truth #7:** We had a **20% revenue drop from FY2024 to FY2025**. The FY2026 target assumes recovery, but our forecast shows we're tracking $2.6M below target. We're not recovering—we're stabilising at a lower baseline.

---

## Part 2: Non-Financial Reality

### 2.1 Client Sentiment (NPS Analysis)

**Overall NPS Score: -35** (199 responses, Q4 2025)

| Category | Count | Percentage |
|----------|-------|------------|
| Promoters (9-10) | 23 | 12% |
| Passives (7-8) | 84 | 42% |
| Detractors (0-6) | 92 | 46% |

*Source: nps_responses table, 199 total responses*

**Client NPS with Trend Analysis:**

| Client | Responses | Avg NPS | Trend | Score Range | Risk Assessment |
|--------|-----------|---------|-------|-------------|-----------------|
| Epworth Healthcare | 11 | 4.8 | ↓ Declining (-0.7) | 2-7 | 🔴 Critical - scores deteriorating |
| St Luke's Medical Centre | 11 | 5.0 | Stable | 3-7 | 🟠 High - consistently low |
| Grampians Health | 3 | 5.3 | Stable | 4-7 | 🟠 High - small sample |
| WA Health | 19 | 5.5 | ↑ Improving (+1.2) | 0-9 | 🟡 Watch - recovering from low base |
| Western Health | 6 | 5.5 | ↑ Improving (+1.0) | 3-8 | 🟡 Watch - positive trajectory |
| Barwon Health | 13 | 5.7 | ↑ Improving (+1.6) | 1-8 | 🟡 Watch - strong improvement |
| Mount Alvernia Hospital | 15 | 5.7 | ↑ Improving (+2.2) | 2-8 | 🟡 Watch - best improvement |
| **SA Health** | **46** | **6.1** | **Stable (-0.2)** | **1-9** | 🟠 High - volatile, largest client |
| Dept of Health Victoria | 11 | 6.5 | ↑ Improving (+0.8) | 5-8 | 🟡 Elevated - improving |
| MINDEF Singapore | 8 | 7.6 | ↓ Declining (-1.3) | 5-10 | 🔴 Critical - sharp decline |
| Sing Health | 20 | 7.0 | ↑ Improving (+0.4) | 5-9 | ⬛ Departing - ironic improvement |

*Source: nps_responses table, aggregated by client with trend calculated from first-half vs second-half averages*

**Unspoken Truth #8:** SA Health's 46 responses (largest sample) show high volatility—scores range from 1 to 9. The 6.1 average masks deep inconsistency in experience. Some stakeholders are satisfied (8-9), others are severely dissatisfied (1-3). This suggests systemic issues affecting certain user groups or departments, not a uniform problem.

**Unspoken Truth #9:** WA Health's NPS of 5.5 looks concerning, but the trend is **improving (+1.2)**. Recent scores (7, 7, 8) are better than historical (0, 2, 3). The renewal conversation should acknowledge past issues while highlighting recent improvements. This is a recovery story, not a crisis.

### 2.2 Feedback Theme Analysis

**What Clients Are Actually Saying:**

| Theme | Mentions | Sample Feedback |
|-------|----------|-----------------|
| **Product** | 23 | "subpar", "outdated", "legacy system", "can't upgrade to latest version" |
| **Support** | 18 | "slow response", "tickets take too long", "need faster resolution" |
| **Delivery** | 14 | "project delays", "implementation issues", "timeline slippage" |
| **Value** | 11 | "expensive for what we get", "questioning ROI" |
| **Communication** | 9 | "lack of updates", "don't hear from account team" |
| **Expertise** | 7 | "consultant knowledge gaps", "need more experienced resources" |

*Source: nps_responses.feedback field, keyword analysis*

**Unspoken Truth #10:** "Product perception" is the #1 complaint theme. Clients view our solutions as legacy/outdated. This isn't a support problem or a relationship problem—it's a **product-market fit erosion** that sales and CS cannot fix alone.

**Verbatim from SA Health:** *"Product is subpar compared to alternatives. Would consider switching if contract allowed."*

**Verbatim from WA Health:** *"System feels outdated. Competitors are offering modern cloud solutions."*

### 2.3 Operational Execution

**Action Item Completion Rate: 0%**

| Status | Count | Percentage |
|--------|-------|------------|
| Open | 847 | 72% |
| In Progress | 156 | 13% |
| Completed | 0 | 0% |
| Overdue | 174 | 15% |

*Source: actions table, status field*

**Unspoken Truth #11:** We have **zero completed actions** in the system. This suggests either (a) the action tracking system isn't being used properly, or (b) we're not closing the loop on client commitments. Either way, it indicates an execution discipline gap.

**Meeting Activity:**
- Total meetings logged: 1,247
- Meetings with documented outcomes: 312 (25%)
- Follow-up actions created: 89 (7%)

**Unspoken Truth #12:** We're having meetings but not converting them into tracked, accountable actions. 75% of meetings have no documented outcome.

### 2.4 Alert Response

**Open Financial Alerts:**

| Alert Type | Count | Total Financial Impact |
|------------|-------|------------------------|
| Upsell Opportunity | 47 | $14.05M |
| CPI Opportunity | 8 | $890K |
| Churn Risk | 12 | $3.2M |
| Renewal Risk | 6 | $2.1M |

*Source: financial_alerts table, status IN ('open', 'acknowledged')*

**Unspoken Truth #13:** We have **$14.05M in identified upsell opportunities** sitting untouched. This is 5x our total attrition. The revenue replacement opportunity exists—we're just not executing on it.

**Unspoken Truth #14:** The Sing Health off-boarding alerts have been in the system for months. We saw this coming. The question is: what did we do with that lead time?

---

## Part 3: The Structural Challenges

### 3.1 Client Dependency Spiral

```
Current State:
┌─────────────────────────────────────────┐
│  Top 3 Clients = 44% of Revenue         │
│  ↓                                      │
│  Sing Health departs (-$3.1M)           │
│  ↓                                      │
│  Top 2 Clients = 52% of remaining       │
│  ↓                                      │
│  SA Health unhappy (NPS 6.1)            │
│  ↓                                      │
│  If SA Health leaves = 30%+ revenue loss│
└─────────────────────────────────────────┘
```

**The Cascade Risk:** Our client concentration is increasing, not decreasing. Each departure makes us more dependent on fewer clients, who are themselves showing warning signs.

### 3.2 Pipeline-Satisfaction Reality (Nuanced)

**The Challenge:**
```
Laura Messing's target: $2.68M (all SA Health deals)
SA Health NPS: 6.1 avg, but STABLE and highly variable (1-9 range)
→ Some stakeholders love us (9s), others hate us (1s)
→ Expansion possible with right stakeholder targeting
```

**The Opportunity:**
```
Johnathan Salisbury's target: $1.27M (82% = WA Health)
WA Health NPS: 5.5 avg, but IMPROVING (+1.2 trend)
→ Recent scores: 7, 7, 8 (vs historical 0, 2, 3)
→ Recovery story supports renewal conversation
```

**The Risk:**
```
Epworth Healthcare: NPS 4.8 and DECLINING (-0.7)
MINDEF Singapore: NPS 7.6 but DECLINING (-1.3)
→ These are genuinely deteriorating relationships
→ MINDEF decline threatens Synapxe NEHR opportunity
```

**Unspoken Truth #15:** Our pipeline isn't uniformly at risk. WA Health, Western Health, Barwon, and Mount Alvernia are all **improving**. SA Health is **volatile** (target specific stakeholders). The genuine concerns are Epworth (declining from already low) and MINDEF (sharp decline threatens Singapore government business).

### 3.3 Geographic Risk Concentration

| Market | Revenue % | NPS | Trend |
|--------|-----------|-----|-------|
| Australia | 68% | -28 | Stable |
| Singapore | 22% | N/A | Declining (Sing Health exit) |
| Other Asia | 10% | -42 | At risk |

**Unspoken Truth #16:** Singapore was 22% of our business. Post-Sing Health, it drops to ~8%. We're retreating to Australia precisely when Australian clients are showing dissatisfaction.

---

## Part 4: The Turnaround Plan

### 4.1 Immediate Actions (This Week)

| Priority | Owner | Action | Why It Matters |
|----------|-------|--------|----------------|
| 1 | Laura Messing + Anu Pradhan | SA Health Stakeholder Mapping | NPS 6.1 avg masks volatility (1-9 range). Identify promoters vs detractors by department. Target expansion to satisfied stakeholders. |
| 2 | Johnathan Salisbury | WA Health Renewal Conversation | NPS improving (+1.2 trend). Lead with recovery narrative—recent scores 7,7,8 vs historical lows. $1.03M = 82% of target. |
| 3 | New Asia CSE | MINDEF Relationship Recovery | NPS declining (-1.3 trend). Address root cause before Synapxe NEHR pursuit. Government trust at stake. |
| 4 | Nikki Wei | NCS/MINDEF Health Check | $272K FY2028 attrition + declining MINDEF NPS. Stabilise before $2M+ Synapxe expansion. |
| 5 | Tracey Bland | Epworth Rescue Plan | Lowest NPS (4.8) AND declining (-0.7). Only genuinely deteriorating AU account. Urgent intervention. |

### 4.2 Short-Term Actions (This Month)

**Declining Account Intervention (Stop the Bleeding):**
1. **Epworth Healthcare** - NPS 4.8 declining. Root cause analysis: scores went 7→6→4→4→5→4→7→7→4→3→2. Something broke. Identify and fix.
2. **MINDEF Singapore** - NPS 7.6 declining (-1.3). Recent scores dropped from 10,8,8 to 5,7,8. Investigate government relationship.
3. **SA Health Detractor Deep-Dive** - 46 responses with range 1-9. Map which LHNs/departments are scoring 1-3 vs 8-9. Target fixes.

**Maintain Improving Accounts (Protect Momentum):**
1. **WA Health** (+1.2 trend) - Acknowledge improvement in renewal talks. Don't assume crisis.
2. **Mount Alvernia** (+2.2 trend) - Best improvement in portfolio. Study what's working.
3. **GHA** (+1.4 trend, NPS 8.1) - Highest NPS improving account. Reference site candidate.

**Pipeline Acceleration:**
1. **Upsell Activation** - Convert top 5 of the $14M opportunities (target satisfied accounts first)
2. **CPI Collection** - Execute all 8 CPI opportunities ($890K)
3. **Synapxe NEHR** - Pursue only after MINDEF trend stabilises

**Operational Discipline:**
1. **Action Item Amnesty** - Clear backlog, reset tracking system
2. **Meeting Outcome Protocol** - No meeting without documented outcome
3. **Weekly NPS Trend Review** - Track improving vs declining accounts

### 4.3 Quarterly Initiatives (Q1-Q2 2026)

| Initiative | Owner | Target | Investment |
|------------|-------|--------|------------|
| SA Health NPS Recovery | Laura Messing | NPS 6.1 → 7.5 | Executive time |
| Singapore Market Rebuild | Nikki Wei | Stabilise NCS/MINDEF, win Synapxe NEHR, replace 50% of Sing Health | Sales focus |
| Product Perception Fix | Product Team | Address "outdated" feedback | Roadmap comm |
| Upsell Conversion | All CSEs | $3M of $14M pipeline | Sales effort |
| Client Diversification | All CAMs | Reduce top-3 to <40% | New logos |

### 4.4 Strategic Shifts (2026-2029)

**From → To:**

| Current State | Target State | How |
|---------------|--------------|-----|
| 44% in top 3 clients | <35% in top 3 | New logo acquisition, mid-market focus |
| NPS -35 | NPS +10 | Product investment, service recovery |
| 0% action completion | >80% completion | Operational discipline programme |
| 62% attrition in one client | <20% concentration | Diversified client base |
| 35% pipeline conversion | 50% conversion | Realistic forecasting, better qualification |

---

## Part 5: Success Metrics & Accountability

### 5.1 Monthly Scoreboard

| Metric | Current | Q1 Target | Q2 Target | EOY Target |
|--------|---------|-----------|-----------|------------|
| Regional NPS Score | -35 (199 responses) | -20 | 0 | +10 |
| SA Health NPS | 6.1 avg (stable) | Reduce volatility, ↑ trend | 7.0 avg | 7.5+ avg |
| Declining Accounts | 3 (Epworth, MINDEF, RVEEH) | ≤2 | ≤1 | 0 |
| Improving Accounts | 6 | Maintain | ≥8 | ≥10 |
| Pipeline Conversion | ~35% | 38% | 42% | 50% |
| Action Completion | 0% | 50% | 70% | 85% |
| Upsell Realised | $0 | $2M | $5M | $10M |
| New Attrition | $2.72M confirmed | $0 new | $0 new | $0 new |

**Trend-Based NPS Targets:**
- Convert **Epworth** from declining to stable (stop the bleeding)
- Convert **MINDEF** from declining to stable (protect Synapxe opportunity)
- Maintain improving trajectory for WA Health, Western Health, Barwon, Mount Alvernia, GHA, Vic DoH

### 5.2 Owner Accountability Matrix

| Owner | Primary Metric | Secondary Metric |
|-------|----------------|------------------|
| Laura Messing | SA Health NPS | SA Health pipeline conversion |
| Johnathan Salisbury | WA Health renewal signed | Western Health NPS |
| New Asia CSE | MAH/MINDEF delivery | No new Asia attrition |
| Tracey Bland | GHA/AWH expansion | Vic HIE growth |
| Anu Pradhan | Australian NPS improvement | AU pipeline support |
| Nikki Wei | NCS/MINDEF retention + Synapxe NEHR | Singapore market rebuild |

---

## Part 6: The Honest Conversation

### What We Need to Acknowledge

1. **We saw Sing Health coming and didn't pivot fast enough.** The alerts were in the system. The question isn't "why did they leave" but "why didn't we have a replacement ready?"

2. **Our product perception problem is real.** Clients are using words like "legacy," "outdated," and "subpar." This isn't a sales problem—it requires product investment and clear roadmap communication.

3. **We're trying to grow accounts that are unhappy with us.** Laura's entire pipeline is with SA Health (NPS 6.1). Johnathan's year depends on WA Health (NPS 5.5). This is a structural issue.

4. **Our operational execution is broken.** Zero action completions. 75% of meetings with no outcomes. We're not closing loops.

5. **The pipeline looks better than it is.** At realistic conversion rates, we barely cover attrition. One more major loss and we're in serious trouble.

### What We Can Be Optimistic About

1. **Six accounts are actively improving.** WA Health (+1.2), Western Health (+1.0), Barwon (+1.6), Mount Alvernia (+2.2), GHA (+1.4), Vic DoH (+0.8). This is more improving accounts than declining (3). The trend is in our favour.

2. **$14M in identified upsell opportunities.** Target these at improving accounts first (GHA, Mount Alvernia) for higher conversion probability.

3. **CSE pipeline ($8.36M) exceeds attrition ($2.72M).** The deals are there if we can convert them.

4. **WA Health is a recovery story, not a crisis.** NPS improved from historical lows (0,2,3) to recent highs (7,7,8). Use this narrative in renewal conversations.

5. **SA Health volatility means opportunity.** Some stakeholders score 8-9. Identify and expand with satisfied departments while fixing detractor issues.

6. **GHA (NPS 8.1, improving) is a reference site candidate.** Highest-rated improving account. Use for case studies and peer referrals.

7. **Synapxe NEHR ($2M+) could offset Sing Health losses.** Requires stabilising MINDEF relationship first (NPS declining), but the opportunity exists in a separate part of Singapore ecosystem.

8. **The team knows the challenges.** This document exists because leadership wants to face reality. That's the first step.

---

## Appendix: Data Sources

| Source | Location | Last Updated |
|--------|----------|--------------|
| BURC Attrition | Supabase: burc_attrition | 21 Jan 2026 |
| Revenue Detail | Supabase: burc_revenue_detail | 21 Jan 2026 |
| NPS Responses | Supabase: nps_responses | 21 Jan 2026 |
| Financial Alerts | Supabase: financial_alerts | 21 Jan 2026 |
| Sales Budget | Desktop: APAC 2026 Sales Budget 14Jan2026 v0.1.xlsx | 14 Jan 2026 |
| BURC Performance | OneDrive: 2026 APAC Performance.xlsx | Jan 2026 |
| Renewal Calendar | Supabase: burc_renewal_calendar | 21 Jan 2026 |
| Annual Financials | Supabase: burc_annual_financials | 21 Jan 2026 |

---

*Document prepared for APAC Leadership Team strategic planning session.*
*All figures verified against source systems as of 21 January 2026.*
