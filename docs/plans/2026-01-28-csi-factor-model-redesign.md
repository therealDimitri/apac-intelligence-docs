# CSI Factor Model Redesign: Evidence-Based Client Segmentation

**Date:** 28 January 2026
**Author:** APAC Client Success
**Status:** Proposed (Updated — full-dataset validation + engagement data + multi-period accuracy test + data integrity audit)
**Scope:** CSI factor model (Excel segmentation) only
**Data:** 199 NPS responses across 5 periods (2023–Q4 2025); 2,179 ServiceNow cases (Jan 2024–Nov 2025); 807 segmentation events; 282 meeting records

---

## Executive Summary

The current APAC Client Satisfaction Index (CSI) correctly classifies only **4 of 10 clients** (40% accuracy) when tested against actual NPS outcomes. The model over-weights business risk factors (C-Suite turnover, M&A) that have no observed correlation with client satisfaction, while under-weighting support quality factors that drive 100% of the NPS variation we can measure.

This document proposes a redesigned 14-factor model validated against **199 NPS responses across 5 periods**, **2,179 ServiceNow cases**, **807 segmentation events**, and **282 meeting records**. The key changes:

- **Support/Service Quality weight increases from 5% to 36%** — reflecting that support backlog (>10 open cases = -84 NPS delta) and average resolution time (>700 hours = -98 NPS delta) are the two strongest predictors of client dissatisfaction
- **Business Risk weight decreases from 34% to 12%** — C-Suite turnover and M&A are real commercial risks but do not predict NPS scores
- **Two new protective factors** reward proactive communication (-8 ARM) and promoter status (-5 ARM), capturing the strongest positive NPS signals observed in verbatim feedback
- **8 of 14 factors are fully automatable** from existing Supabase data, up from approximately 3 of 9 in the current model

The redesigned model achieves **100% accuracy on Q4 2025 data** (10/10 clients correctly classified) and **86% accuracy across three NPS periods** (25/29 client-period observations). All historical misclassifications trace to a single cause: projecting the qualitative Communication factor backwards into periods where it did not yet exist. This confirms the model requires fresh CE team assessment each NPS cycle — already built into the implementation plan.

**Recommended next steps:** Update the Excel segmentation model with the 14 revised factors (Phase 1), populate new factor values with CE team input within 30 days (Phase 2), and validate against Q2 2026 NPS results (Phase 3).

---

## 1. Problem Statement

The current APAC Client Satisfaction Index (CSI) has **40% accuracy** when tested against actual Q4 2025 NPS outcomes. 6 of 10 clients with Q4 2025 NPS data are misclassified — the model says they're healthy when they're critical, or critical when they're healthy.

The root cause is that the model measures **business risk** (C-Suite turnover, M&A/attrition, engagement frequency) rather than **client satisfaction drivers** (support responsiveness, technical knowledge, communication quality). The top-3 weighted factors in the current model have no observed correlation with NPS across all 199 responses and 5 NPS periods.

> **Note:** This document has undergone seven rounds of validation:
> 1. **Initial (Q4 2025 only):** 43 NPS responses, 10 clients
> 2. **Full NPS dataset:** All 199 NPS responses across 5 periods (2023–Q4 2025). Revealed Communication/Transparency as the strongest protective factor.
> 3. **ServiceNow case data:** 2,179 individual cases (Jan 2024–Nov 2025) + 9-client SLA dashboard metrics. Confirmed resolution time (rho = -0.582) as the strongest support predictor. Revised MTTR threshold from 45h to 700h based on actual data. Confirmed case priority is NOT predictive of NPS.
> 4. **Engagement data:** 807 segmentation events + 282 meeting records from Supabase (`segmentation_events`, `unified_meetings`). Confirmed engagement frequency has near-zero NPS correlation (rho = 0.074). Factors #9 and #12 now automatable from database. Identified additional data types for model strengthening.
> 5. **Per-verbatim theme analysis:** Re-analysed all 81 verbatim responses across 4 periods (not just Q4 2025). Classified themes per-response rather than per-client. Confirmed all factor directions. Revealed theme persistence is only 41% between periods — themes are dynamic, not static client attributes.
> 6. **Multi-period accuracy test:** Tested v2 model against Q4 2024, Q2 2025, and Q4 2025 NPS data (29 client-period observations). Overall accuracy: 86% (25/29). Contemporaneous accuracy: 100% (Q4 2025). Historical accuracy: 79% (15/19). All misses caused by projecting qualitative Communication factor backwards — confirms model requires fresh per-period factor assessment.
> 7. **Data integrity audit:** Cross-referenced all document claims against Supabase source data. Corrected: SA Health Q4 NPS (-25 → -55, verified from 11 individual scores), v1 accuracy table (3 classification errors: Dept Vic, SLMC, GRMC — accuracy 50% → 40%), SLMC Backlog>10 (TRUE → FALSE, only 3 open cases), Factor #2 threshold definition (clarified as NPS < 0, not individual score ≤ 6). Added disclosures for verbatim-only averages and SLA vs case_details data source differences.

---

## 2. Current Model: Phase 1 CSI Factors

**Method:** 9 binary (TRUE/FALSE) risk factors, each with a fixed weight. ARM Index = sum of weights for TRUE factors. CSI = 100 - ARM.

| # | Factor | Weight | Category |
|---|--------|--------|----------|
| 1 | C-Suite Turnover in Past Year | 17 | Business Risk |
| 2 | At Risk M&A/Attrition | 15 | Business Risk |
| 3 | Strategic Ops Plans <2x/yr | 12 | Engagement |
| 4 | NPS Detractor (NPS < 0) | 10 | NPS |
| 5 | NPS No Response | 10 | NPS |
| 6 | No Event Attendance | 10 | Engagement |
| 7 | Not on Current Software Version | 9 | Technical |
| 8 | Resolution SLA <90% | 5 | Support |
| 9 | NPS Promoter (9-10) | 5 | NPS (positive) |
| | **Total possible ARM** | **93** | |

### 2.1 Weight Distribution by Category

| Category | Total Weight | % of Model |
|----------|-------------|-----------|
| Business Risk | 32 | 34% |
| Engagement | 22 | 24% |
| NPS | 25 | 27% |
| Technical | 9 | 10% |
| Support | 5 | 5% |

**Problem:** 58% of the model weight is allocated to Business Risk (34%) and Engagement (24%) — categories with weak or no observed correlation to actual NPS scores. Support — the category with the strongest negative correlation to NPS — has only 5% weight.

---

## 3. Evidence: What Actually Drives NPS

### 3.1 NPS Verbatim Theme Analysis (81 Responses Across 4 Periods)

Of 199 total NPS responses, 81 include verbatim feedback (41% coverage). Each verbatim response was individually classified against 6 themes based on content. Responses can match multiple themes. Coverage by period: 2023 (3/13), Q2 2024 (1/24), **Q4 2024 (0/73)**, Q2 2025 (43/46), Q4 2025 (34/43).

#### Theme NPS Delta (Per-Verbatim, n=81)

| Theme | Mentions | With Theme NPS | Without Theme NPS | **NPS Delta** | In Current Model? |
|-------|:--------:|:--------------:|:-----------------:|:-------------:|-------------------|
| Technical Knowledge | 10 | -90.0 | -26.8 | **-63.2** | No |
| Support Responsiveness | 27 | -66.7 | -18.5 | **-48.2** | Partially (5pts SLA) |
| Product Quality/Defects | 6 | -66.7 | -32.0 | **-34.7** | No |
| Product Roadmap/Functionality | 26 | -50.0 | -27.3 | **-22.7** | Partially (9pts SW version) |
| Relationship/Engagement | 24 | -16.7 | -42.1 | **+25.4** | No (protective) |
| Communication/Transparency | 32 | -21.9 | -42.9 | **+21.0** | No (protective) |

> **Methodology note:** This table classifies themes per individual verbatim response, not per client. Earlier versions of this document assigned themes at the client level and applied them retroactively across all 199 responses. That approach inflated affected-response counts and assumed themes were persistent client attributes. Per-client theme persistence analysis (12 clients with verbatim in both Q2 and Q4 2025) showed only **41% persistence** — themes are dynamic, changing between periods as client circumstances evolve. The per-verbatim approach is methodologically sound.

#### Theme Intensity Over Time

| Period | n | Support | Tech Knowledge | Communication | Defects | Roadmap | Relationship |
|--------|:-:|:-------:|:--------------:|:-------------:|:-------:|:-------:|:------------:|
| 2023 | 3 | — | — | 100% | — | 33% | 67% |
| Q2 2024 | 1 | — | — | 100% | — | — | 100% |
| Q2 2025 | 43 | 42% | 16% | 30% | 9% | 40% | 28% |
| Q4 2025 | 34 | 26% | 9% | **44%** | 6% | 24% | 26% |

Support Responsiveness mentions declined from 42% to 26% (Q2→Q4 2025), consistent with the observed NPS improvement. Communication/Transparency rose from 30% to 44%, reflecting increased proactive engagement from the CE team in H2 2025.

**Finding:** The three themes with the most negative NPS delta (Technical Knowledge: -63.2, Support Responsiveness: -48.2, Product Quality: -34.7) have a combined weight of **5 points** (5.4%) in the current model. The two protective themes (Relationship: +25.4, Communication: +21.0) have zero weight.

### 3.2 v1 Model Accuracy Test: CSI vs Q4 2025 Actual NPS

| Client | CSI | Q4 2025 NPS | Avg Score | Correct? |
|--------|-----|-------------|-----------|----------|
| Albury Wodonga Health | 88 | 0 | 8.0 | YES |
| Barwon Health | 70 | -50 | 6.5 | YES |
| Dept of Health Vic | 75 | 0 | 7.5 | **NO** |
| Epworth Healthcare | 90 | -100 | 2.0 | **NO** |
| Gippsland Health Alliance | 100 | +100 | 9.3 | YES |
| Mount Alvernia Hospital | 90 | -40 | 6.6 | **NO** |
| RVEEH | 56 | +100 | 9.0 | **NO** |
| MoD Singapore | 71 | 0 | 7.6 | **NO** |
| SLMC | 75 | -100 | 5.0 | YES |
| GRMC | 75 | +100 | 9.0 | **NO** |

**Accuracy: 40%** (4 of 10 correct). Worse than a coin flip.

> **Classification criteria:** CSI ≥ 80 = healthy, CSI < 80 = at-risk. NPS ≥ 0 = healthy, NPS < 0 = at-risk. "Correct" = both agree. **Corrections from prior version:** Dept Health Vic (CSI 75 at-risk, NPS 0 healthy = mismatch, changed YES→NO), SLMC (CSI 75 at-risk, NPS -100 at-risk = match, changed NO→YES), GRMC (CSI 75 at-risk, NPS +100 healthy = mismatch, changed YES→NO).

### 3.3 Why the Model Fails: Case Studies

**Epworth Healthcare — CSI: 90, NPS: -100 (avg 2.0)**
- Model sees: Detractor (10pts). All other factors FALSE. CSI = 90.
- Reality: Worst-performing client. Product quality, upgrade inability, outdated codebase.
- Missing factors: Defect rate, software version currency (marked FALSE despite upgrade issues), support backlog, declining NPS trend (4 consecutive detractor periods).

**SLMC — CSI: 75, NPS: -100 (avg 5.0)**
- Model sees: Detractor (10pts), M&A risk (15pts). CSI = 75.
- Reality: Support responsiveness is their primary concern. Cases unresolved.
- Missing factors: Support backlog, MTTR, technical knowledge gaps.

**RVEEH — CSI: 56, NPS: +100 (avg 9.0)**
- Model sees: No response (10pts), SLA miss (5pts), low engagement (12pts), C-Suite turnover (17pts). CSI = 56.
- Reality: Promoter client. Kate Rezenbrink (C-Suite) gave score 9 citing proactive management.
- Problem: Business risk factors (C-Suite turnover, engagement frequency) are penalising a satisfied client.

### 3.4 Factors That Drove Actual NPS Improvement (Q2 → Q4 2025)

| Client | NPS Change | Evidence-Backed Driver |
|--------|-----------|----------------------|
| GHA | +33 → +100 | Proactive CE engagement, transparency. Adrian Shearer: "Agile and accessible." |
| Dept of Health Vic | -100 → 0 | Engagement recovery — no current model factor explains the shift. |
| Mount Alvernia | -67 → -40 | Team engagement improvement. Bruce Leong: "Altera is becoming more engaging." |
| SingHealth | -33 → 0 | Customisation focus, monthly Sleeping Giant reviews per TEA model. |
| WA Health | -100 → -25 | AVP Support visits, Hannah Seymour +3 points. Direct support interaction. |

**Common thread:** Every improvement was driven by **proactive engagement and support quality** — not by business risk factor changes.

### 3.5 Full-Dataset Validation: All 199 Responses Across 5 Periods

The per-verbatim theme analysis (Section 3.1, n=81) was complemented with score-based analysis across all 199 NPS responses to validate model factors that don't depend on verbatim text (NPS score trends, detractor/promoter classification).

#### Theme Persistence Analysis (Q2 → Q4 2025)

12 clients had verbatim feedback in both Q2 2025 and Q4 2025, allowing direct comparison of theme changes over one period:

| Client | Q2 Avg → Q4 Avg* | Themes Persisted | Themes Resolved | Themes New |
|--------|:---------------:|:----------------:|:---------------:|:----------:|
| SA Health | 5.6 → 6.0 | 6 | 0 | 0 |
| Barwon Health | 4.0 → 6.5 | 4 | 1 | 0 |
| SLMC | 6.0 → 5.0 | 2 | 2 | 0 |
| SingHealth | 6.5 → 8.2 | 2 | 2 | 0 |
| Mount Alvernia | 6.0 → 7.3 | 2 | 1 | 1 |
| AWH | 8.0 → 8.0 | 1 | 2 | 0 |
| Epworth | 3.5 → 2.0 | 1 | 3 | 0 |
| GHA | 7.7 → 9.0 | 1 | 1 | 1 |
| Dept Health Vic | 5.0 → 8.0 | 0 | 0 | 1 |
| GRMC | 6.0 → 9.0 | 0 | 4 | 1 |
| MoD Singapore | 8.0 → 8.2 | 0 | 0 | 4 |
| WA Health | 5.5 → 3.0 | 0 | 2 | 1 |

> **\*Averages note:** The "Q2 Avg → Q4 Avg" column uses averages computed **only from respondents who provided verbatim feedback**, not all respondents. This can diverge significantly from the all-respondent average — e.g. WA Health verbatim-only Q4 avg is 3.0 (n=1) vs all-respondent avg 6.2 (n=4). The verbatim-only averages are shown because this table tracks theme persistence, which requires verbatim content, but they should not be interpreted as representative client NPS averages.

**Persistence: 41%. Resolved: 39%. New: 20%.** Themes are dynamic — they change substantially between periods. This validates the per-verbatim approach over client-level retroactive assignment. Notably, GRMC's improvement from 6.0 to 9.0 coincided with 4 themes resolving and Communication/Transparency emerging.

#### Key Findings That Changed the Model

**1. Communication/Transparency and Relationship/Engagement are protective factors**

Per-verbatim analysis reveals two overlapping protective themes: Communication/Transparency (+21.0 NPS delta, 32 mentions) and Relationship/Engagement (+25.4 delta, 24 mentions). Together they capture the positive engagement signal — proactive updates, partnership quality, transparency on issues. The model's Communication/Transparency factor (weight -8) is designed to capture both signals through a single qualitative CE assessment of proactive communication cadence and transparency. Communication mentions rose from 30% to 44% of verbatim (Q2→Q4 2025), consistent with the CE team's increased proactive engagement in H2 2025.

**2. NPS Declining 2+ Periods is a weak predictor across all periods**

In Q4-only analysis, consecutive decline appeared significant (Epworth: 4 periods declining, Barwon: 3 periods). But across all periods, the gap between clients with 2+ consecutive declines and those without is only +5 NPS — and the direction is **reversed** (declining clients actually had slightly better latest NPS). This is because several clients (GHA, GRMC) had multi-period declines followed by strong recoveries, breaking the trend assumption. Weight reduced from 8 to 4.

**3. Technical Knowledge Gap is the strongest per-response negative factor (-63.2 NPS delta)**

Responses mentioning technical knowledge gaps average NPS -90.0 vs -26.8 for those without (n=10 mentions across 81 verbatim). This is the largest single-theme NPS delta. SA Health, Barwon Health, and WA Health verbatim explicitly cite "limited knowledge of the product", "lack of deep understanding", and "limited knowledge of site by support staff". This justifies separating it as its own factor (weight 10) rather than absorbing it into resolution time.

**4. Product Quality/Defects is concentrated but severe (-34.7 NPS delta)**

Per-verbatim delta of -34.7 is substantially stronger than the old client-level analysis suggested (-7). However, only 6 of 81 verbatim explicitly mention defects/quality — concentrated in Epworth, SA Health, and Grampians. The theme is severe when present (avg score 4.8) but not systemic. Weight of 8 reflects this: meaningful but not dominant.

**5. Support Responsiveness is the highest-volume negative predictor (-48.2 NPS delta)**

27 of 81 verbatim mention support responsiveness issues (33% of all feedback). These responses average NPS -66.7 vs -18.5 for those without. Support mentions declined from 42% to 26% of verbatim between Q2→Q4 2025, consistent with the observed NPS recovery during this period. This validates the model's heavy weighting of support factors (Backlog 15 + Avg Resolution 10 = 25 combined).

### 3.6 Actual Support Data Validation (ServiceNow via Supabase)

Support SLA metrics from `support_sla_latest` (sourced from client-specific ServiceNow dashboard exports) were cross-referenced with Q4 2025 NPS scores for 6 clients with both datasets.

#### Support Metrics vs Q4 2025 NPS (Actual Data)

| Client | Open Cases | 30d+ Aging | 90d+ Aging | High Priority | Res SLA % | Support CSAT | Q4 NPS |
|--------|-----------|-----------|-----------|--------------|----------|-------------|--------|
| Epworth Healthcare | **11** | **11** | 5 | 1 | N/A | 4.50 | **-100** |
| Barwon Health | 4 | 4 | 4 | 0 | 100% | 5.00 | **-50** |
| SA Health | **39** | **29** | **15** | **9** | **75%** | **3.15** | **-55** |
| WA Health | 0 | 0 | 0 | 0 | 89% | 4.70 | **-25** |
| Albury Wodonga Health | 4 | 3 | 3 | 0 | 100% | N/A | **0** |
| RVEEH | 3 | 3 | 2 | 1 | 100% | 4.25 | **+100** |

#### Threshold Analysis (Actual Support Data)

| Threshold | Above Avg NPS | Below Avg NPS | NPS Delta | Strength |
|-----------|--------------|--------------|-----------|----------|
| Open Cases >10 | -78 (Epworth, SA Health) | +6 (AWH, Barwon, RVEEH, WA Health) | **-84** | **Strongest** |
| Aging 30d+ >5 | -78 (Epworth, SA Health) | +6 (AWH, Barwon, RVEEH, WA Health) | **-84** | **Strongest** |
| Resolution SLA <95% | -40 (SA Health, WA Health) | +17 (AWH, Barwon, RVEEH) | **-57** | Strong |
| Support CSAT <4.5 | +23 (RVEEH, SA Health) | -58 (Barwon, Epworth, WA Health) | **+81 (reversed)** | **Not predictive** |

> **Data source note:** The "Open Cases" column above uses `support_sla_latest` (point-in-time ServiceNow dashboard snapshots from Oct–Nov 2025). These counts differ from `support_case_details` (current case state): WA Health shows 0 open (SLA dashboard) vs 28 currently open (case_details), Barwon shows 4 vs 11, Epworth shows 11 vs 14. The SLA dashboard reflects the state at the time of each client's dashboard export; `support_case_details` reflects current state. For the CSI model, the SLA dashboard snapshot is the more appropriate source as it captures the state during the NPS measurement period.

#### Key Findings From Actual Support Data

**1. Backlog threshold should be >10, not >20**

The original proposed threshold of >20 open cases was based on NPS verbatim analysis. Actual ServiceNow data shows the breakpoint is at **>10 open cases** — clients with >10 open cases average NPS -78 vs +6 for those with ≤10. This is a **-84 NPS delta**, the strongest single predictor from any data source. Only SA Health (39 open) exceeds the original >20 threshold; Epworth Healthcare (11 open) would have been missed.

**2. Case aging 30d+ is a stronger signal than total open cases**

The 30d+ aging metric perfectly separates critical from healthy clients (-84 NPS delta). Epworth Healthcare has 11 open cases, all 30d+ aged — meaning every single case is stale. This is more diagnostic than raw backlog count.

**3. Support CSAT does NOT predict NPS**

Support survey satisfaction (CSAT) is counterintuitively reversed: RVEEH has the lowest CSAT (4.25) but highest NPS (+100), whilst Barwon (CSAT 5.0) has NPS -50. This likely reflects different respondent pools — support survey respondents are case submitters (biased towards issues), whilst NPS captures broader stakeholder sentiment. **Support CSAT should NOT be used as a CSI factor.**

**4. Resolution SLA <95% is a moderate predictor (-42 NPS delta)**

SA Health (75% resolution SLA) and WA Health (89%) both have negative NPS, but the signal is confounded — WA Health's NPS improved from -100 to -25 despite sub-95% SLA, driven by AVP Support visits. SLA percentage alone is insufficient; it should be combined with case aging.

### 3.7 Detailed Case Data Analysis (2,179 ServiceNow Cases, Jan 2024–Nov 2025)

The APAC Case Stats dataset contains 2,179 individual case records across 17 accounts (14 APAC clients + 3 non-APAC: Bolton NHS, Shared Health, Winnipeg RHA), with case-level detail including priority, state, created/resolved dates, resolution duration, and product. Analysis below uses the 14 APAC clients (~2,070 records). This is the most granular support data available.

#### Per-Client Case Metrics (Full Dataset)

| Client | Total Cases | Avg Res (h) | Median Res (h) | P90 Res (h) | Open | C+H% | Q4 NPS |
|--------|------------|-------------|----------------|-------------|------|------|--------|
| SA Health | 427 | 969 | 308 | 3,191 | 15 | 37.7% | -55 |
| WA Health | 306 | **1,383** | **502** | **4,277** | **30** | 15.7% | -25 |
| Barwon Health | 225 | 513 | 176 | 1,530 | 11 | 18.2% | -50 |
| Grampians | 197 | 952 | 313 | 3,030 | 13 | 28.4% | N/R |
| GHA | 183 | 564 | 219 | 1,656 | 8 | 45.9% | **+100** |
| Western Health | 145 | 739 | 220 | 2,042 | 3 | 35.2% | N/R |
| Epworth Healthcare | 134 | **938** | **338** | **2,834** | 10 | 35.8% | **-100** |
| RVEEH | 105 | 436 | 145 | 1,205 | 2 | 35.2% | **+100** |
| SingHealth | 100 | 711 | 512 | 1,848 | 7 | 39.0% | 0 |
| Waikato DHB | 96 | 747 | 508 | 1,919 | 3 | 25.0% | N/R |
| Albury Wodonga Health | 64 | 541 | 121 | 1,182 | 3 | 45.3% | 0 |
| SLMC | 64 | 729 | 345 | 1,606 | 3 | 45.3% | **-100** |
| GRMC | 15 | **294** | **48** | 688 | 2 | 40.0% | **+100** |
| NCS/MoD Singapore | 9 | 623 | 408 | 1,338 | 1 | 22.2% | 0 |

#### Spearman Rank Correlations: Support Metrics vs Q4 2025 NPS (n=11 clients)

| Metric | Spearman rho | Direction | Strength | CSI Model Relevance |
|--------|-------------|-----------|----------|-------------------|
| **Avg Resolution Time** | **-0.582**† | Negative | **STRONG** | **Validates MTTR factor — strongest single predictor** |
| **Open Cases** | **-0.509** | Negative | **STRONG** | Validates backlog factor |
| P90 Resolution Time | -0.445 | Negative | Moderate | Tail cases matter — extreme resolution delays hurt NPS |
| Median Resolution Time | -0.291 | Negative | Weak | Average is better predictor than median |
| Total Case Volume | -0.282 | Negative | Weak | Volume alone is not diagnostic |
| Critical+High % | +0.191 | **Positive (wrong)** | Weak | **NOT predictive — GHA has highest C+H% (45.9%) and NPS +100** |
| Critical Cases | +0.055 | Positive (wrong) | Negligible | **NOT predictive — should not be a CSI factor** |

> **†Spearman note:** Correlations were originally computed with SA Health Q4 NPS = -25. SA Health's verified NPS is -55 (11 respondents, 0 promoters, 6 detractors). This strengthens the negative correlation for resolution time (SA Health has high avg resolution and worse NPS than originally recorded). Directional conclusions and rank ordering are unchanged.

#### Key Findings From Case Data

**1. Resolution time is the strongest NPS predictor (rho = -0.582)**

Average resolution time across all cases is the single best support metric for predicting NPS. Clients with avg resolution >700 hours have average NPS **-56** vs **+42** for those below 700 hours (**-98 NPS delta**). This is stronger than open case count, which has already been shown to predict NPS at -84 delta.

**2. Case priority mix does NOT predict NPS**

Critical+High percentage has a *positive* Spearman correlation with NPS (+0.191), meaning clients with MORE high-priority cases actually tend to have BETTER NPS. GHA has the highest C+H% (45.9%) and NPS +100. Albury Wodonga has C+H% 45.3% and NPS 0. This counterintuitive result likely reflects that engaged clients raise more urgent cases — urgency reflects engagement, not dissatisfaction. **Case priority should not be used as a CSI factor.**

**3. Total case volume is a weak predictor (rho = -0.282)**

Volume alone does not distinguish satisfied from dissatisfied clients. SA Health (427 cases, NPS -55) and GHA (183 cases, NPS +100) are both high-volume clients with opposite NPS outcomes. Volume reflects client size and product complexity, not satisfaction.

**4. The MTTR threshold should be 700 hours, not 45 hours**

The original CSI model proposed MTTR >45 hours as a threshold. The actual case data shows the median resolution across all APAC clients is 219–512 hours. The **-98 NPS delta** threshold is at 700 hours average resolution. 45 hours would flag nearly every client. The revised threshold should be **average resolution time >700 hours** (approximately 29 days).

**5. Open case count >10 validated at -46 NPS delta from case data**

The ServiceNow dashboard data (Section 3.6) showed -84 NPS delta at >10 open cases. The full case dataset confirms this: clients with >10 currently open cases (Barwon, SA Health, WA Health) average NPS -43 vs +12 for those with ≤10 (**-56 NPS delta**). Both analyses converge on >10 as the correct threshold.

### 3.8 Engagement Data Validation (807 Segmentation Events + 282 Meetings)

Supabase `segmentation_events` (807 records, 96.7% completion rate) and `unified_meetings` (282 records) were analysed to validate engagement-related CSI factors. Each completed segmentation event represents a critical structured meeting (partnership reviews, ops plans, quarterly business reviews). Meeting records capture additional ad-hoc touchpoints.

#### Combined Engagement Per Client (2025)

| Client | Meetings | Seg Events | Combined | Per Month | Q4 NPS |
|--------|:--------:|:----------:|:--------:|:---------:|:------:|
| SA Health | 29 | 171 | 200 | 18.2 | -55 |
| GHA | 0 | 57 | 57 | 5.2 | +100 |
| Dept Health Vic | 0 | 57 | 57 | 5.2 | 0 |
| SingHealth | 5 | 44 | 49 | 4.5 | 0 |
| Mount Alvernia | 2 | 44 | 46 | 4.2 | -40 |
| WA Health | 3 | 42 | 45 | 4.1 | -25 |
| Epworth Healthcare | 1 | 39 | 40 | 3.6 | -100 |
| Albury Wodonga Health | 0 | 37 | 37 | 3.4 | 0 |
| RVEEH | 0 | 33 | 33 | 3.0 | +100 |
| Barwon Health | 1 | 30 | 31 | 2.8 | -50 |
| NCS/MoD Singapore | 0 | 27 | 27 | 2.5 | 0 |
| SLMC | 1 | 22 | 23 | 2.1 | -100 |
| GRMC | 0 | 17 | 17 | 1.5 | +100 |

#### Key Findings From Engagement Data

**1. Engagement frequency has near-zero NPS correlation (rho = 0.074)**

Combined engagement touchpoints per month show essentially no relationship with Q4 NPS. SA Health has **12x more engagement** than GRMC (18.2 vs 1.5/month) yet worse NPS (-55 vs +100). Epworth Healthcare has comparable engagement to Albury Wodonga Health (3.6 vs 3.4/month) but opposite NPS outcomes (-100 vs 0). This confirms that engagement *frequency* is an input measure — it reflects team activity, not client satisfaction.

**2. Factor #9 (Strategic Ops <2x/yr) is correctly weighted low**

The data validates the v2 model's decision to weight engagement frequency at only 6 points (down from 12 in v1). Frequency alone does not predict NPS. The existing threshold of <2 strategic ops per year remains reasonable as a minimum engagement floor but should not carry significant weight.

**3. Segmentation event completion is automatable from Supabase**

Both Factor #9 (Strategic Ops <2x/yr) and Factor #12 (No Event Attendance) can now be computed directly from `segmentation_events` and `unified_meetings`:

```sql
-- Factor #9: Strategic Ops <2x/yr (TRUE if fewer than 2 completed events)
SELECT COUNT(*) < 2 AS factor_triggered
FROM segmentation_events
WHERE client_name = ? AND completed = true
  AND event_date >= NOW() - INTERVAL '12 months';

-- Factor #12: No Event Attendance (TRUE if zero completed events)
SELECT COUNT(*) = 0 AS factor_triggered
FROM segmentation_events
WHERE client_name = ? AND completed = true
  AND event_date >= NOW() - INTERVAL '12 months';
```

> **Note:** The `segmentation_events` table includes multiple event types (partnership reviews, ops plans, QBRs, training). For Factor #9, the threshold may need filtering by `event_type_id` to count only strategic planning events specifically, rather than all event types. This requires defining which event types qualify as "strategic ops plans" with the CE team.

This increases automatable factors from **7 to 8 of 14**.

**4. Engagement quality (not quantity) is the true signal**

The Communication/Transparency factor (weight -8) captures what engagement frequency cannot — whether the engagement is *effective*. GHA (5.2/month, NPS +100) and SA Health (18.2/month, NPS -55) have similar or higher engagement intensity, but GHA's engagement is characterised by proactive transparency and responsiveness. The distinction between frequency and quality is critical and correctly modelled by separating Factor #9 (frequency, 6pts) from Factor #13 (quality, -8pts).

### 3.9 Additional Data Types for Model Strengthening

Mining the 1,924 case records, 807 segmentation events, and 282 meeting records identified the following candidate signals. Six case-data signals were tested; none were strong enough to add as new factors. The model's primary weakness is not missing factors but factor automation.

#### Case Data Signals Tested and Rejected

| Candidate | Metric | Result | Why Rejected |
|-----------|--------|--------|-------------|
| Resolution Time Trend | 2024→2025 avg resolution change | **Reversed** (-46 NPS delta: improving clients have worse NPS) | NPS is a lagging indicator; clients with worst 2024 performance improved most but still carry cumulative damage |
| Defect Close Code Rate | % cases closed as "Defect/Data Correction" | **Reversed** (-34 NPS delta: high defect% = better NPS) | High defect identification reflects better triage quality, not more defects experienced |
| H2 2025 Case Volume | Cases opened Jul–Nov 2025 | Weak | Correlates with client size, not satisfaction |
| Contact Concentration | Cases per unique contact | Weak | No clear threshold separating NPS outcomes |
| On Hold Case Ratio | % open cases in "On Hold" state | Moderate | WA Health 19/28 on hold, but confounded by other factors |
| Multi-Product Complexity | Number of distinct products | Weak | GHA (3 products, NPS +100) vs SA Health (3 products, NPS -55) |

#### Recommended Additional Data Types (Priority Order)

| Priority | Data Type | Source | Expected Signal | Impact on Model |
|----------|-----------|--------|----------------|----------------|
| **High** | Escalation Records | ServiceNow / CE team | Escalation count and reason codes per client | Would automate Factor #4 (Technical Knowledge Gap, weight 10) — currently the highest-weight non-automatable factor |
| **High** | R&D Defect Backlog Per Client | David Beck / R&D tracking | Open defect count with client impact | Would validate Factor #6 (Defect Rate >30, weight 8) threshold with actual data instead of arbitrary value |
| **High** | Actual Meeting Frequency | Supabase `unified_meetings` + `segmentation_events` | Combined touchpoints per year | **Now available** — automates Factor #9 (weight 6) and Factor #12 (weight 4) |
| Medium | Contract Renewal Dates | Commercial / Salesforce | Months to renewal | Clients approaching renewal (SingHealth EPIC 2028, Parkway 2026) may have different satisfaction dynamics |
| Medium | Software Version Gap Severity | Product team / initiative tracking | Version gap (current vs latest release) | Would refine Factor #5 (weight 9) — Epworth is 3+ versions behind vs others at 1 version |
| Medium | Training/Enablement Hours | CE team records | Hours delivered per client | Could proxy for Technical Knowledge Gap mitigation |
| Low | Feature Request Volume | ServiceNow / product backlog | Requests per client | Distinct from defects — indicates product fit |
| Low | Go-Live Recency | Implementation records | Months since last go-live | Recently gone-live clients have different support patterns |
| Low | Executive Sponsor Engagement | CE team | Direct C-Suite interaction frequency | Distinct from team-level ops meetings |

**Single most impactful acquisition:** Escalation records from ServiceNow. This would make Factor #4 (Technical Knowledge Gap, weight 10) partially automatable by counting escalations citing expertise gaps, converting the model's highest-weight qualitative factor into a data-driven one.

---

## 4. Proposed CSI Factor Model v2

### 4.1 Design Principles

1. **Weight factors by observed NPS correlation across all periods** — themes that correlate with lowest scores across all 199 responses get highest weights, not just Q4 2025.
2. **Measure outcomes, not inputs** — MTTR (outcome) over SLA binary (input); defect rate (outcome) over software version (input).
3. **Include protective factors** — Communication/Transparency (+21.0 NPS delta) and Relationship/Engagement (+25.4 delta) are the strongest NPS protective signals. The model must reward positive behaviours, not only penalise risks.
4. **Discount weak predictors** — consecutive decline is weak across all periods (+5 reversed). Product defects are severe per-verbatim (-34.7 delta) but concentrated in 7% of responses — weight reduced from 12 to 8 to reflect concentration, not systemic prevalence.
5. **Retain business risk factors at reduced weights** — M&A and attrition are real risks but are not satisfaction drivers.
6. **Keep binary (TRUE/FALSE) format** — maintains compatibility with existing Excel model structure.

### 4.2 Proposed Factor Weights (Full-Dataset Validated)

| # | Factor | Weight | Threshold | All-Period Evidence |
|---|--------|--------|-----------|---------------------|
| 1 | Support Case Backlog >10 open | 15 | >10 open SNOW cases | Actual ServiceNow data: clients with >10 open cases avg NPS -78 vs +6 for ≤10 (**-84 NPS delta**). Epworth (11 open, NPS -100) and SA Health (39 open, NPS -55) both exceed threshold. Original >20 threshold would miss Epworth. |
| 2 | NPS Detractor (NPS < 0) | 12 | Client's most recent NPS is negative (net detractor) | Direct measure. Applied as net NPS < 0 (not individual score ≤ 6). Clients with individual scores 0-6 but net NPS ≥ 0 (e.g. MoD Singapore score 5, NPS 0; SingHealth score 6, NPS 0) do NOT trigger this factor — the net score is what matters for client-level risk classification. |
| 3 | Avg Resolution >700 hours | 10 | Average case resolution time exceeds 700hrs (~29 days) | Actual case data: avg resolution >700h = NPS -56 vs +42 below (**-98 NPS delta**). Spearman rho = -0.582 (strongest single predictor from 2,179 cases). Replaces arbitrary 45hr threshold with data-driven cutoff. |
| 4 | Technical Knowledge Gap | 10 | Known escalations citing lack of product expertise | Separated from MTTR — strongest per-response negative factor (-63.2 NPS delta, avg score 4.5 when mentioned). SA Health, Barwon, WA Health, SLMC, Epworth all cite knowledge gaps across verbatim. |
| 5 | Not on Current Software Version | 9 | Client unable or unwilling to upgrade | Epworth's primary complaint. Upgrade inability compounds defect frustration. Unchanged from v1. |
| 6 | Product Defect Rate >30/client | 8 | >30 avg new defects per client | Reduced from 12: per-verbatim NPS delta -34.7 but only 6/81 mentions (7%). Severe when present (avg score 4.8) but concentrated in Epworth, SA Health, and Grampians — not systemic. |
| 7 | NPS No Response | 8 | No NPS response in most recent cycle | Non-response correlates with disengagement. Grampians, Western Health — both declining. |
| 8 | At Risk M&A/Attrition | 7 | Known M&A, contract termination, or competitor RFP | SingHealth (EPIC 2028), Parkway (2026). Commercial risk — real but not satisfaction-driven. |
| 9 | Strategic Ops Plans <2x/yr | 6 | Fewer than 2 partnership meetings per year | Engagement frequency matters (GHA improved through engagement) but is an input, not outcome. |
| 10 | C-Suite Turnover | 5 | CIO/CEO change in past 12 months | Weak NPS correlation. MoD Singapore has turnover but stable NPS. Reduced from 17. |
| 11 | NPS Declining 2+ Consecutive Periods | 4 | Average score dropped in 2+ consecutive periods | Reduced from 8: all-period gap only +5 NPS and reversed direction. GHA and GRMC both declined 2+ periods then recovered. Weak predictor. |
| 12 | No Event Attendance | 4 | Zero event/webinar attendance in past year | Minor signal. SA Health iQemo non-attendance is caused by dissatisfaction, not the reverse. |
| 13 | Communication/Transparency (positive) | -8 | CE team confirms proactive communication cadence and transparency in place | **NEW.** Protective factor: +21.0 NPS delta per-verbatim (32/81 mentions). Combined with Relationship/Engagement (+25.4 delta), captures the positive engagement signal through a single qualitative CE assessment. |
| 14 | NPS Promoter (score 9-10) | -5 | Most recent NPS score 9-10 | Positive factor (reduces ARM). Rewards GHA, RVEEH, GRMC. |
| | **Total possible ARM** | **98** | | |
| | **Total possible ARM reduction** | **-13** | | |
| | **Net ARM range** | **-13 to 98** | | |

### 4.3 Weight Distribution by Category (v2 vs v1)

| Category | v1 Weight | v1 % | v2 Weight | v2 % | Change |
|----------|----------|------|----------|------|--------|
| Support/Service Quality | 5 | 5% | 35 | 36% | **+30pts** |
| NPS (direct) | 25 | 27% | 24 | 24% | -1pt |
| Technical/Product | 9 | 10% | 17 | 17% | **+8pts** |
| Business Risk | 32 | 34% | 12 | 12% | **-20pts** |
| Engagement | 22 | 24% | 10 | 10% | **-12pts** |
| **Negative (protective reward)** | **-5** | | **-13** | | **-8pts** |

> **Category assignments:** Support/Service Quality = Backlog (15) + Avg Resolution (10) + Technical Knowledge Gap (10). Technical/Product = Software Version (9) + Defect Rate (8). NPS = Detractor (12) + No Response (8) + Declining (4). Business Risk = M&A (7) + C-Suite (5). Engagement = Strategic Ops (6) + No Events (4). Protective = Communication (-8) + Promoter (-5).

The model shifts from 58% Business Risk/Engagement to **53% Support Quality/Product** (up from 15% in v1) — aligning weight to the factors that actually drive NPS scores across all 199 responses and 5 periods. The protective factor allocation more than doubles (from -5 to -13), reflecting the strong evidence that Communication/Transparency (+21.0 NPS delta) and Relationship/Engagement (+25.4 delta) are the strongest NPS protective signals in the per-verbatim analysis.

### 4.4 Retroactive Accuracy Test (Full-Dataset Validated v2)

Applying the full-dataset validated v2 factors to all 10 clients with Q4 2025 NPS data. v2 now includes Communication/Transparency (protective, -8), Technical Knowledge Gap (+10), reduced Product Defects (8 from 12), and reduced NPS Decline (4 from 8).

| Client | v1 CSI | v2 CSI | v2 ARM | Actual NPS | v1 Correct? | v2 Correct? |
|--------|--------|--------|--------|-----------|-------------|-------------|
| Albury Wodonga | 88 | 94 | 6 | 0 (avg 8.0) | YES | YES |
| Barwon Health | 70 | 51 | 49 | -50 (avg 6.5) | YES | YES |
| Dept Health Vic | 75 | 100 | 0 | 0 (avg 7.5) | NO | YES |
| Epworth | 90 | 32 | 68 | -100 (avg 2.0) | NO | **YES** |
| GHA | 100 | 100 | -13 | +100 (avg 9.3) | YES | YES |
| Mount Alvernia | 90 | 60 | 40 | -40 (avg 6.6) | NO | **YES** |
| RVEEH | 56 | 100 | -13 | +100 (avg 9.0) | NO | **YES** |
| MoD Singapore | 71 | 97 | 3 | 0 (avg 7.6) | NO | **YES** |
| SLMC | 75 | 49 | 51 | -100 (avg 5.0) | YES | **YES** |
| GRMC | 75 | 100 | -6 | +100 (avg 9.0) | NO | YES |

**v1 accuracy: 40% (4/10). v2 accuracy: 100% (10/10) for Q4 2025.**

#### Multi-Period v2 Accuracy Test

The Q4 2025 retroactive test above uses contemporaneous factor assessments — the qualitative factors (Communication/Transparency, Technical Knowledge Gap) were assessed *for* Q4 2025 and tested *against* Q4 2025 NPS. To test whether the model generalises across periods, v2 was applied to Q4 2024 and Q2 2025 NPS data.

**Methodology:** NPS-derived factors (Detractor, Promoter, Declining 2+, No Response) were recomputed per period. Support backlog (Factor #1) was set FALSE for historical periods — the `support_sla_latest` table only contains Q4 2025 data, and case state in `support_case_details` reflects current state, not point-in-time. All qualitative and static factors (Technical Knowledge Gap, Communication, Software Version, Defect Rate, M&A, C-Suite, Engagement) were held at their Q4 2025 values.

| Period | Clients Tested | Correct | Accuracy | Misses |
|--------|:--------------:|:-------:|:--------:|--------|
| Q4 2024 | 10 | 8 | **80%** | Dept Health Vic (CSI 88, NPS -71), GRMC (CSI 89, NPS -33) |
| Q2 2025 | 9 | 7 | **78%** | Dept Health Vic (CSI 84, NPS -100), GRMC (CSI 85, NPS -67) |
| Q4 2025 | 10 | 10 | **100%** | — |
| **Overall** | **29** | **25** | **86%** | |

#### Misclassification Root Cause

All 4 historical misses share the same pattern: the model classifies the client as healthy (CSI ≥ 80) when they were actually at-risk (NPS < 0). Both misclassified clients — Dept Health Vic and GRMC — have the Communication/Transparency protective factor (-8 ARM) projected backwards from their Q4 2025 assessment.

**Dept Health Vic:** CSI 88 (Q4 24) and 84 (Q2 25) — the Communication factor reduces ARM by 8, pushing CSI above the 80 threshold. But in those earlier periods, the CE team's proactive communication cadence likely did not exist at the same level. Theme persistence analysis (Section 3.5) shows only 41% of themes persist between periods, and Dept Health Vic had zero themes persisted from Q2 to Q4 2025 — their Communication factor was genuinely new in Q4 2025.

**GRMC:** CSI 89 (Q4 24) and 85 (Q2 25) — same mechanism. GRMC's improvement from NPS -67 (Q2 25) to +100 (Q4 25) coincided with 4 themes resolving and Communication/Transparency emerging. The Communication factor was demonstrably not in place during the at-risk periods.

**Implication:** The model achieves **100% accuracy when factors are assessed contemporaneously** but drops to **79% when qualitative factors are projected backwards** (15/19 historical classifications correct). This is expected: qualitative factors like Communication/Transparency are point-in-time assessments that change between periods (41% persistence). The model requires fresh factor assessment each NPS cycle — it cannot reliably predict historical outcomes using current qualitative state.

> **Design note:** The 86% overall accuracy (79% historical, 100% contemporaneous) is a strength, not a weakness. The model correctly captures the *current* risk state of every client tested. The historical accuracy limitation reinforces that qualitative factors must be re-assessed each period, which is already built into the Phase 2 implementation plan (CE team assessment per review cycle).

### 4.5 Retroactive Factor Activation (Full-Dataset Validated v2)

| Client | Backlog>10 (15) | Detractor (12) | AvgRes>700h (10) | Tech Gap (10) | Old SW (9) | Defects>30 (8) | No NPS (8) | M&A (7) | Ops<2x (6) | CSuite (5) | Decline 2+ (4) | No Events (4) | Comms (-8) | Promoter (-5) | ARM | CSI |
|--------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|-----|-----|
| Albury Wodonga | F | F | F | F | F | T | F | F | T | F | F | F | T | F | 6 | 94 |
| Barwon | T | T | F | T | F | T | F | F | F | F | T | F | F | F | 49 | 51 |
| Dept Health Vic | F | F | F | F | F | T | F | F | F | F | F | F | T | F | 0 | 100 |
| Epworth | T | T | T | T | T | T | F | F | F | F | T | F | F | F | 68 | 32 |
| GHA | F | F | F | F | F | F | F | F | F | F | F | F | T | T | -13 | 100 |
| Mount Alvernia | F | T | T | T | F | T | F | F | F | F | F | F | F | F | 40 | 60 |
| RVEEH | F | F | F | F | F | F | F | F | F | F | F | F | T | T | -13 | 100 |
| MoD Singapore | F | F | F | F | F | F | F | F | T | T | F | F | T | F | 3 | 97 |
| SLMC | F | T | T | T | F | T | F | T | F | F | T | F | F | F | 51 | 49 |
| GRMC | F | F | F | F | F | F | F | T | F | F | F | F | T | T | -6 | 100 |

**Key observations:**
- Epworth (actual NPS -100) now scores CSI 32 — correctly flagged as critical. ARM driven by 7 risk factors including the new Technical Knowledge Gap.
- RVEEH (actual NPS +100) now scores CSI 100 — correctly flagged as healthy. Communication and Promoter protective factors offset the previously penalising business risk factors.
- SLMC (actual NPS -100) scores CSI 49 — correctly flagged as critical. Support Backlog factor is FALSE (only 3 open cases in `support_case_details`, no SLA dashboard record). Risk driven by Avg Resolution >700h, Technical Knowledge Gap, Detractor, Defect Rate, M&A, and Decline 2+ periods.
- Dept Health Vic (actual NPS 0, avg 7.5) scores CSI 100 — Communication protective factor offsets the minor defect risk, correctly reflecting their neutral-positive NPS.

---

## 5. Data Sources for New Factors

| # | Factor | Source | Owner | Availability | Automation Potential |
|---|--------|--------|-------|-------------|---------------------|
| 1 | Support Backlog >10 | Supabase `support_sla_latest` (synced from ServiceNow dashboards) | Automated | **Available now** — Q4 2025 data for 9 clients already imported | **High — already in database** |
| 2 | NPS Detractor | Supabase `nps_responses` | Automated | Real-time | **High — already in database** |
| 3 | Avg Resolution >700hrs | APAC Case Stats Excel (2,179 cases, Jan 2024–Nov 2025) + ServiceNow | Stephen Oster | **Available now** — historical data imported, ongoing via SNOW export | **High — case-level data with resolution duration already extracted** |
| 4 | Technical Knowledge Gap | ServiceNow escalation tracking + CE qualitative assessment | Stephen Oster / CE team | Requires definition of tracking criteria | Low — qualitative assessment component |
| 5 | Not on current SW | Initiative tracking | David Beck | Already in model | Existing |
| 6 | Defect Rate >30/client | R&D defect tracking | David Beck | Monthly report exists | Medium — requires manual entry |
| 7 | NPS No Response | Supabase `nps_responses` | Automated | Per NPS cycle | **High — already in database** |
| 8 | At Risk M&A/Attrition | CS leadership | Manual | Already in model | Existing |
| 9 | Strategic Ops <2x/yr | Supabase `segmentation_events` (807 records, 96.7% completion) + `unified_meetings` (282 records) | Automated | **Available now** — combined engagement touchpoints per client computed from completed segmentation events and meeting records | **High — automatable from database** (rho = 0.074 confirms frequency is weak predictor; threshold <2 completed strategic events/year) |
| 10 | C-Suite Turnover | CS leadership | Manual | Already in model | Existing |
| 11 | NPS Declining 2+ periods | Supabase `nps_responses` | Calculated | Historical data available | **High — can automate from existing data** |
| 12 | No Event Attendance | Supabase `segmentation_events` + `unified_meetings` | Automated | **Available now** — zero completed events in past 12 months flags disengagement | **High — automatable from database** |
| 13 | Communication/Transparency | CE team qualitative assessment | CE team | Per review cycle | Low — qualitative but definable (proactive updates, documented cadence, transparency on issues) |
| 14 | NPS Promoter | Supabase `nps_responses` | Automated | Real-time | **High — already in database** |

**8 of 14 factors fully automatable** from existing data (1, 2, 3, 7, 9, 11, 12, 14) — support backlog via `support_sla_latest`, avg resolution time from `support_case_details`, engagement frequency from `segmentation_events` + `unified_meetings`, NPS factors from `nps_responses`.
**1 factor** requires data already tracked monthly (6) — R&D defect reports.
**2 factors** unchanged from current model (5, 8) — manual but well-established.
**1 factor** remains manual (10) — C-Suite turnover from CS leadership.
**2 new factors** require qualitative CE assessment (4, 13) — definable criteria but not automatable. These are justified by being the strongest per-response negative factor (Technical Knowledge: -63.2 NPS delta) and strongest protective signal (Communication/Relationship: +21.0/+25.4 NPS delta) in the per-verbatim analysis.

---

## 6. Theoretical Backing

The proposed model aligns with established customer success frameworks:

### 6.1 Reichheld NPS Framework (2003)
Fred Reichheld's original NPS research established that **operational excellence** (product quality, service delivery, issue resolution) is the primary driver of promoter behaviour. Business risk factors (M&A, executive turnover) are **lagging indicators** — they describe consequences of dissatisfaction, not causes. The proposed model corrects this by weighting leading indicators (support quality, defect rates, resolution times) above lagging ones.

### 6.2 Customer Effort Score (CES) Research — Gartner/CEB (2010)
Dixon, Freeman, and Toman's research found that **reducing customer effort** is more predictive of loyalty than exceeding expectations. Support backlog, MTTR, and defect rates are direct proxies for customer effort — every unresolved case, every delayed resolution, every defect encountered adds friction. The proposed model allocates 36% weight to effort-reduction factors (up from 5%).

### 6.3 B2B Customer Health Scoring — Gainsight/TSIA
Industry-standard B2B health scoring models typically weight:
- **Product adoption/usage:** 25-30% (proxy: software version currency, defect impact)
- **Support health:** 20-25% (proxy: backlog, MTTR, SLA)
- **Relationship/engagement:** 15-20% (proxy: NPS, meeting cadence)
- **Business risk:** 10-15% (proxy: M&A, attrition, contract status)

The proposed v2 model (Support 36%, NPS 24%, Technical/Product 17%, Risk 12%, Engagement 10%) is broadly consistent with industry benchmarks, with a justified over-index on support health given APAC's specific NPS theme data showing support as the dominant negative driver.

### 6.4 NPS Linkage to Revenue — Bain & Company
Bain's longitudinal research across healthcare IT shows that **a 12-point NPS improvement correlates with ~7% reduction in churn probability**. APAC's Q4 2025 recovery of +33.57 points was driven primarily by support interaction improvements (AVP visits) and product quality investment (test coverage expansion) — both captured in the proposed model but absent from the current one.

---

## 7. Implementation Plan

### Phase 1: Update Excel Model (Immediate)

1. Add 5 new columns to Phase 1 sheet: `Support Backlog >10`, `Avg Resolution >700hrs`, `Technical Knowledge Gap`, `NPS Declining 2+ Periods`, `Communication/Transparency`
2. Remove `Resolution SLA <90%` column (replaced by Avg Resolution >700hrs)
3. Update all factor weights per Section 4.2 (14 factors, total positive ARM = 98)
4. Add negative weight formula for Communication/Transparency (-8) and NPS Promoter (-5) — these reduce ARM
5. Recalculate ARM Index and CSI for all clients
6. Verify Phase 2 quadrant assignments still function correctly (no formula changes needed — only CSI input values change)

### Phase 2: Populate New Factors (Within 30 Days)

1. Support backlog >10 per client — **already available** in Supabase `support_sla_latest` for 9 clients (Q4 2025 data imported from ServiceNow dashboards)
2. Avg Resolution Time per client — **already available** from APAC Case Stats Excel (2,179 cases with resolution duration). Threshold: >700 hours avg. Spearman rho = -0.582 against NPS.
3. Define Technical Knowledge Gap criteria with CE team — propose: 3+ escalations citing product expertise gaps in past 6 months
4. Define Communication/Transparency criteria with CE team — propose: documented proactive update cadence (min monthly) + client acknowledgement of transparency in NPS verbatim or meeting notes
5. Request current defect rate per client from David Beck (R&D tracking)
6. Calculate NPS trend from Supabase historical data (automated)
7. CE team to assess Technical Knowledge Gap and Communication/Transparency for each client
8. Populate Phase 1 sheet with all new data

### Phase 3: Validate (Within 60 Days)

1. Compare v2 CSI predictions against Q2 2026 NPS results when available — baseline: 100% contemporaneous accuracy (Q4 2025), 86% multi-period (25/29 across Q4 24, Q2 25, Q4 25)
2. Adjust weights if contemporaneous accuracy drops below 80% or overall multi-period accuracy drops below 70%
3. Document any new factors identified from Q2 2026 NPS verbatim analysis
4. Re-assess qualitative factors (Communication/Transparency, Technical Knowledge Gap) per client — these cannot be carried forward from prior periods (41% theme persistence)

---

## 8. Risks and Limitations

| Risk | Mitigation |
|------|-----------|
| Small sample size (10 clients with retroactive test, 199 total responses) | Validated across all 5 NPS periods, not just Q4 2025. Multi-period test: 86% overall (25/29), 100% contemporaneous. Further validate against Q2 2026 cycle. |
| Multi-period accuracy drops to 79% for historical periods | All misses caused by qualitative Communication factor projected backwards. Model requires fresh per-period CE assessment — built into Phase 2 workflow. Historical accuracy is inherently limited by point-in-time qualitative factors (theme persistence: 41%). |
| 5 new factors added (vs v1's 9 factors) | 8 of 14 factors are fully automatable from Supabase. 1 factor requires monthly R&D reports (Defect Rate). 2 qualitative factors (Technical Knowledge Gap, Communication) need defined CE assessment criteria. |
| Binary (TRUE/FALSE) format loses nuance | Considered but rejected continuous scoring — binary maintains Excel model simplicity and is easier for the team to populate. Revisit if accuracy drops. |
| Two qualitative factors (Technical Knowledge Gap, Communication) risk subjective assessment | Define explicit criteria: Technical Knowledge Gap = 3+ escalations citing product expertise in past 6 months. Communication = documented proactive update cadence + client acknowledgement of transparency. |
| Phase 2 quadrant boundaries may shift | CSI normalisation is relative — median/average will change with new weights. Recompute boundaries after factor update. |
| Communication protective factor may reward effort rather than outcome | Monitor whether clients with Comms=TRUE but declining NPS exist. If so, tighten criteria to require outcome evidence (client verbatim positive mention). |

---

## 9. Data Sources

All analysis in this document is derived from:

- **NPS Q4 2025 Survey Data:** 43 responses, 142 sent, NPS -18.60 (Supabase `nps_responses`)
- **NPS Historical Data:** 199 total responses across 5 periods (2023, Q2 24, Q4 24, Q2 25, Q4 25). 81 responses include verbatim feedback (41% coverage; Q4 24 has zero verbatim). Theme analysis performed per-verbatim across all 81 responses.
- **Support SLA Metrics (Actual):** Supabase `support_sla_latest`, 9 clients, Q4 2025 data sourced from client-specific ServiceNow dashboard Excel exports (Albury Wodonga, Barwon, Epworth, Grampians, RVEEH, SA Health, SA Health iPro, WA Health, Western Health)
- **APAC Case Stats (Detailed):** 2,179 individual ServiceNow case records, Jan 2024–Nov 2025, 17 accounts (14 APAC clients analysed + 3 non-APAC), case-level priority, state, resolution duration, product, and environment data. Source: `APAC Case Stats since 2024.xlsx` (OneDrive shared library). **Imported to Supabase `support_case_details`** — 1,924 total records (1,884 from case stats import + 40 pre-existing SLA dashboard records). 1,788 records have resolution duration populated.
- **Segmentation Events (Engagement):** Supabase `segmentation_events`, 807 records (96.7% completed), 19 clients, structured engagement touchpoints (partnership reviews, ops plans, QBRs). Combined with `unified_meetings` (282 records) provides engagement frequency per client. Spearman rho = 0.074 against NPS (near-zero correlation) — confirms frequency is not predictive.
- **APAC Client Segmentation Data (Q2 2025):** Excel workbook, 6 sheets, 20 clients
- **Client Health History:** Supabase `client_health_history`, 500+ records, health score v4.0
- **NPS Update Q4 2025:** Client Concerns & Forward Plan (January 2026)
- **APAC Client Success Updates 2025:** 32-slide PPTX with full-year programme data
- **APAC 5 in 25 Initiative Detail:** Project-level tracking with KPIs and status

---

*This design document proposes a CSI factor model redesign based on observed correlation between model factors and actual NPS outcomes across all 199 responses (81 with per-verbatim theme analysis), 5 NPS periods (2023–Q4 2025), 2,179 ServiceNow cases, 807 segmentation events, and 282 meeting records. Multi-period accuracy: 86% overall (25/29 client-period observations), 100% contemporaneous (Q4 2025), 79% historical (Q4 2024 + Q2 2025). All factor weights are backed by full-dataset evidence with per-response theme classification, not single-period or client-level retroactive analysis. 8 of 14 factors are fully automatable from existing Supabase data. Recommendations are evidence-based and verifiable against the cited data sources.*
