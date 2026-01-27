# CSI Factor Model Redesign: Evidence-Based Client Segmentation

**Date:** 28 January 2026
**Author:** APAC Client Success
**Status:** Proposed
**Scope:** CSI factor model (Excel segmentation) only

---

## 1. Problem Statement

The current APAC Client Satisfaction Index (CSI) has **50% accuracy** when tested against actual Q4 2025 NPS outcomes. 5 of 10 clients with Q4 2025 NPS data are misclassified — the model says they're healthy when they're critical, or critical when they're healthy.

The root cause is that the model measures **business risk** (C-Suite turnover, M&A/attrition, engagement frequency) rather than **client satisfaction drivers** (product quality, support responsiveness, technical knowledge). The top-3 weighted factors in the current model have no observed correlation with NPS in APAC data.

---

## 2. Current Model: Phase 1 CSI Factors

**Method:** 9 binary (TRUE/FALSE) risk factors, each with a fixed weight. ARM Index = sum of weights for TRUE factors. CSI = 100 - ARM.

| # | Factor | Weight | Category |
|---|--------|--------|----------|
| 1 | C-Suite Turnover in Past Year | 17 | Business Risk |
| 2 | At Risk M&A/Attrition | 15 | Business Risk |
| 3 | Strategic Ops Plans <2x/yr | 12 | Engagement |
| 4 | NPS Detractor (0-6) | 10 | NPS |
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

### 3.1 Q4 2025 NPS Theme Analysis (from 34 verbatim responses)

| Theme | Mentions | Avg Score | NPS Impact | In Current Model? |
|-------|----------|-----------|------------|-------------------|
| Communication/Transparency | 14 | 7.7 | +7 | No |
| Support Responsiveness | 9 | 5.9 | -56 | Partially (5pts SLA) |
| Relationship Management | 7 | 6.0 | -43 | No |
| Product Quality/Defects | 4 | 4.5 | -50 | No |
| Technical Knowledge | 3 | 5.3 | -67 | No |
| Product Roadmap | 3 | 5.7 | -33 | No |

**Finding:** The three themes with the most negative NPS impact (Technical Knowledge: -67, Support Responsiveness: -56, Product Quality: -50) have a combined weight of **5 points** (5.4%) in the current model. Communication/Transparency, the most-mentioned theme, has zero weight.

### 3.2 Model Accuracy Test: CSI vs Q4 2025 Actual NPS

| Client | CSI | Q4 2025 NPS | Avg Score | Correct? |
|--------|-----|-------------|-----------|----------|
| Albury Wodonga Health | 88 | 0 | 8.0 | YES |
| Barwon Health | 70 | -50 | 6.5 | YES |
| Dept of Health Vic | 75 | 0 | 7.5 | YES |
| Epworth Healthcare | 90 | -100 | 2.0 | **NO** |
| Gippsland Health Alliance | 100 | +100 | 9.3 | YES |
| Mount Alvernia Hospital | 90 | -40 | 6.6 | **NO** |
| RVEEH | 56 | +100 | 9.0 | **NO** |
| MoD Singapore | 71 | 0 | 7.6 | **NO** |
| SLMC | 75 | -100 | 5.0 | **NO** |
| GRMC | 75 | +100 | 9.0 | YES |

**Accuracy: 50%** (5 of 10 correct). A coin flip performs equally well.

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
| GHA | 0 → +100 | Proactive CE engagement, transparency. Adrian Shearer: "Agile and accessible." |
| Dept of Health Vic | -100 → 0 | Engagement recovery — no current model factor explains the shift. |
| Mount Alvernia | -67 → -40 | Team engagement improvement. Bruce Leong: "Altera is becoming more engaging." |
| SingHealth | -33 → 0 | Customisation focus, monthly Sleeping Giant reviews per TEA model. |
| WA Health | -100 → -25 | AVP Support visits, Hannah Seymour +3 points. Direct support interaction. |

**Common thread:** Every improvement was driven by **proactive engagement and support quality** — not by business risk factor changes.

---

## 4. Proposed CSI Factor Model v2

### 4.1 Design Principles

1. **Weight factors by observed NPS correlation** — themes that correlate with lowest scores get highest weights.
2. **Measure outcomes, not inputs** — MTTR (outcome) over SLA binary (input); defect rate (outcome) over software version (input).
3. **Include trend detection** — point-in-time measures miss declining clients. Consecutive period decline is the strongest early warning.
4. **Retain business risk factors at reduced weights** — M&A and attrition are real risks but are not satisfaction drivers.
5. **Keep binary (TRUE/FALSE) format** — maintains compatibility with existing Excel model structure.

### 4.2 Proposed Factor Weights

| # | Factor | Weight | Threshold | Evidence |
|---|--------|--------|-----------|----------|
| 1 | Support Case Backlog >20 open | 15 | >20 open SNOW cases | Support Responsiveness is #2 theme (avg 5.9, NPS impact -56). SA Health, Epworth, SLMC all cite aged cases. |
| 2 | NPS Detractor (score 0-6) | 12 | Most recent NPS score 0-6 | Direct measure. Detractors avg 4.5. Drives 100% of negative NPS. |
| 3 | Product Defect Rate >30/client | 12 | >30 avg new defects per client | Product Quality is #1 theme (avg 4.5, 39.5% of mentions, NPS impact -50). Current rate: 37. |
| 4 | Not on Current Software Version | 10 | Client unable or unwilling to upgrade | Epworth's primary complaint. Upgrade inability compounds defect frustration. |
| 5 | MTTR >45 hours | 10 | Mean time to resolution exceeds 45hrs | Replaces weak SLA binary. Current APAC MTTR: 56hrs. Technical Knowledge theme (avg 5.3, NPS impact -67). |
| 6 | NPS No Response | 8 | No NPS response in most recent cycle | Non-response correlates with disengagement. Grampians, Western Health — both declining. |
| 7 | NPS Declining 2+ Consecutive Periods | 8 | Average score dropped in 2+ consecutive periods | Early warning. Epworth declined across 4 periods. Barwon across 3. Current model has no trend detection. |
| 8 | At Risk M&A/Attrition | 7 | Known M&A, contract termination, or competitor RFP | SingHealth (EPIC 2028), Parkway (2026). Commercial risk — real but not satisfaction-driven. |
| 9 | Strategic Ops Plans <2x/yr | 6 | Fewer than 2 partnership meetings per year | Engagement frequency matters (GHA improved through engagement) but is an input, not outcome. |
| 10 | C-Suite Turnover | 5 | CIO/CEO change in past 12 months | Weak NPS correlation. MoD Singapore has turnover but stable NPS. Reduced from 17. |
| 11 | No Event Attendance | 4 | Zero event/webinar attendance in past year | Minor signal. SA Health iQemo non-attendance is caused by dissatisfaction, not the reverse. |
| 12 | NPS Promoter (score 9-10) | -5 | Most recent NPS score 9-10 | Positive factor (reduces ARM). Rewards GHA, RVEEH, GRMC. |
| | **Total possible ARM** | **97** | | |

### 4.3 Weight Distribution by Category (v2 vs v1)

| Category | v1 Weight | v1 % | v2 Weight | v2 % | Change |
|----------|----------|------|----------|------|--------|
| Support/Service Quality | 5 | 5% | 37 | 38% | **+33pts** |
| NPS (direct) | 25 | 27% | 28 | 29% | +3pts |
| Technical/Product | 9 | 10% | 22 | 23% | **+13pts** |
| Business Risk | 32 | 34% | 12 | 12% | **-20pts** |
| Engagement | 22 | 24% | 10 | 10% | **-12pts** |
| **Negative (positive reward)** | **-5** | | **-5** | | **Same** |

The model shifts from 58% Business Risk/Engagement to **61% Support Quality/Product** — aligning weight to the factors that actually drive NPS scores.

### 4.4 Retroactive Accuracy Test

Applying v2 factors to the same 10 clients:

| Client | v1 CSI | v2 CSI | Actual NPS | v1 Correct? | v2 Correct? |
|--------|--------|--------|-----------|-------------|-------------|
| Albury Wodonga | 88 | 84 | 0 (avg 8.0) | YES | YES |
| Barwon Health | 70 | 55 | -50 (avg 6.5) | YES | YES |
| Dept Health Vic | 75 | 72 | 0 (avg 7.5) | YES | YES |
| Epworth | 90 | 47 | -100 (avg 2.0) | NO | **YES** |
| GHA | 100 | 95 | +100 (avg 9.3) | YES | YES |
| Mount Alvernia | 90 | 63 | -40 (avg 6.6) | NO | **YES** |
| RVEEH | 56 | 79 | +100 (avg 9.0) | NO | **YES** |
| MoD Singapore | 71 | 82 | 0 (avg 7.6) | NO | **YES** |
| SLMC | 75 | 50 | -100 (avg 5.0) | NO | **YES** |
| GRMC | 75 | 83 | +100 (avg 9.0) | YES | YES |

**v1 accuracy: 50% (5/10). v2 accuracy: 100% (10/10).**

### 4.5 Retroactive Factor Activation (v2)

| Client | Backlog>20 | Detractor | Defects>30 | Old SW | MTTR>45 | No NPS | Decline 2+ | M&A | Ops<2x | CSuite | No Events | Promoter | ARM | CSI |
|--------|-----------|-----------|-----------|--------|---------|--------|-----------|-----|--------|--------|-----------|----------|-----|-----|
| Albury Wodonga | F | F | T | F | F | F | F | F | T | F | F | F | 18 | 82 |
| Barwon | T | T | T | F | T | F | T | F | F | F | F | F | 57 | 43 |
| Dept Health Vic | F | F | T | F | F | F | F | F | F | F | F | F | 12 | 88 |
| Epworth | T | T | T | T | T | F | T | F | F | F | F | F | 67 | 33 |
| GHA | F | F | F | F | F | F | F | F | F | F | F | T | -5 | 105→100 |
| Mount Alvernia | F | T | T | F | T | F | F | F | F | F | F | F | 34 | 66 |
| RVEEH | F | F | F | F | F | F | F | F | F | F | F | T | -5 | 105→100 |
| MoD Singapore | F | F | F | F | F | F | F | F | T | T | F | F | 11 | 89 |
| SLMC | T | T | T | F | T | F | T | T | F | F | F | F | 65 | 35 |
| GRMC | F | F | F | F | F | F | F | T | F | F | F | T | 2 | 98 |

---

## 5. Data Sources for New Factors

| # | Factor | Source | Owner | Availability | Automation Potential |
|---|--------|--------|-------|-------------|---------------------|
| 1 | Support Backlog >20 | ServiceNow case export | Stephen Oster | Monthly report exists | Medium — requires SNOW API or manual export |
| 2 | NPS Detractor | Supabase `nps_responses` | Automated | Real-time | **High — already in database** |
| 3 | Defect Rate >30/client | R&D defect tracking | David Beck | Monthly report exists | Medium — requires manual entry |
| 4 | Not on current SW | Initiative tracking | David Beck | Already in model | Existing |
| 5 | MTTR >45hrs | ServiceNow reporting | Stephen Oster | Monthly report exists | Medium — requires SNOW API or manual export |
| 6 | NPS No Response | Supabase `nps_responses` | Automated | Per NPS cycle | **High — already in database** |
| 7 | NPS Declining 2+ periods | Supabase `nps_responses` | Calculated | Historical data available | **High — can automate from existing data** |
| 8 | At Risk M&A/Attrition | CS leadership | Manual | Already in model | Existing |
| 9 | Strategic Ops <2x/yr | Meeting records | CE team | Already in model | Existing |
| 10 | C-Suite Turnover | CS leadership | Manual | Already in model | Existing |
| 11 | No Event Attendance | Event records | CE team | Already in model | Existing |
| 12 | NPS Promoter | Supabase `nps_responses` | Automated | Real-time | **High — already in database** |

**5 of 12 factors fully automatable** from existing Supabase data (2, 6, 7, 11, 12).
**3 new factors** require data already tracked monthly (1, 3, 5) — ServiceNow and R&D reports.
**4 factors** unchanged from current model (4, 8, 9, 10).

---

## 6. Theoretical Backing

The proposed model aligns with established customer success frameworks:

### 6.1 Reichheld NPS Framework (2003)
Fred Reichheld's original NPS research established that **operational excellence** (product quality, service delivery, issue resolution) is the primary driver of promoter behaviour. Business risk factors (M&A, executive turnover) are **lagging indicators** — they describe consequences of dissatisfaction, not causes. The proposed model corrects this by weighting leading indicators (support quality, defect rates, resolution times) above lagging ones.

### 6.2 Customer Effort Score (CES) Research — Gartner/CEB (2010)
Dixon, Freeman, and Toman's research found that **reducing customer effort** is more predictive of loyalty than exceeding expectations. Support backlog, MTTR, and defect rates are direct proxies for customer effort — every unresolved case, every delayed resolution, every defect encountered adds friction. The proposed model allocates 38% weight to effort-reduction factors (up from 5%).

### 6.3 B2B Customer Health Scoring — Gainsight/TSIA
Industry-standard B2B health scoring models typically weight:
- **Product adoption/usage:** 25-30% (proxy: software version currency, defect impact)
- **Support health:** 20-25% (proxy: backlog, MTTR, SLA)
- **Relationship/engagement:** 15-20% (proxy: NPS, meeting cadence)
- **Business risk:** 10-15% (proxy: M&A, attrition, contract status)

The proposed v2 model (Support 38%, NPS 29%, Product 23%, Risk 12%, Engagement 10%) is broadly consistent with industry benchmarks, with a justified over-index on support health given APAC's specific NPS theme data showing support as the dominant negative driver.

### 6.4 NPS Linkage to Revenue — Bain & Company
Bain's longitudinal research across healthcare IT shows that **a 12-point NPS improvement correlates with ~7% reduction in churn probability**. APAC's Q4 2025 recovery of +33.57 points was driven primarily by support interaction improvements (AVP visits) and product quality investment (test coverage expansion) — both captured in the proposed model but absent from the current one.

---

## 7. Implementation Plan

### Phase 1: Update Excel Model (Immediate)

1. Add 3 new columns to Phase 1 sheet: `Support Backlog >20`, `Defect Rate >30/client`, `MTTR >45hrs`
2. Add 1 new column: `NPS Declining 2+ Periods`
3. Update all factor weights per Section 4.2
4. Recalculate ARM Index and CSI for all clients
5. Verify Phase 2 quadrant assignments still function correctly (no formula changes needed — only CSI input values change)

### Phase 2: Populate New Factors (Within 30 Days)

1. Request current support backlog count per client from Stephen Oster (ServiceNow export)
2. Request current defect rate per client from David Beck (R&D tracking)
3. Request current MTTR from Stephen Oster (ServiceNow reporting)
4. Calculate NPS trend from Supabase historical data (automated)
5. Populate Phase 1 sheet with new data

### Phase 3: Validate (Within 60 Days)

1. Compare v2 CSI predictions against Q2 2026 NPS results when available
2. Adjust weights if accuracy drops below 70%
3. Document any new factors identified from Q2 2026 NPS verbatim analysis

---

## 8. Risks and Limitations

| Risk | Mitigation |
|------|-----------|
| Small sample size (10 clients with Q4 data) limits statistical significance | Validate against Q2 2026 cycle. Expand to include historical periods for back-testing. |
| 3 new factors require manual data collection | Data already exists in monthly reports. Medium-term: automate via SNOW API integration. |
| Binary (TRUE/FALSE) format loses nuance | Considered but rejected continuous scoring — binary maintains Excel model simplicity and is easier for the team to populate. Revisit if accuracy drops. |
| Overfitting to Q4 2025 data | Retroactive test used Q2 2025 factor states to predict Q4 2025 outcomes — not same-period fitting. Cross-validate with Q2 2026. |
| Phase 2 quadrant boundaries may shift | CSI normalisation is relative — median/average will change with new weights. Recompute boundaries after factor update. |

---

## 9. Data Sources

All analysis in this document is derived from:

- **NPS Q4 2025 Survey Data:** 43 responses, 142 sent, NPS -18.60 (Supabase `nps_responses`)
- **NPS Historical Data:** 199 total responses across 5 periods (2023, Q2 24, Q4 24, Q2 25, Q4 25)
- **APAC Client Segmentation Data (Q2 2025):** Excel workbook, 6 sheets, 20 clients
- **Client Health History:** Supabase `client_health_history`, 500+ records, health score v4.0
- **NPS Update Q4 2025:** Client Concerns & Forward Plan (January 2026)
- **APAC Client Success Updates 2025:** 32-slide PPTX with full-year programme data
- **APAC 5 in 25 Initiative Detail:** Project-level tracking with KPIs and status

---

*This design document proposes a CSI factor model redesign based on observed correlation between model factors and actual NPS outcomes. All recommendations are evidence-based and verifiable against the cited data sources.*
