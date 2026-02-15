# Process: CSI Factor Model Data Integrity Audit

**Date:** 28 January 2026
**Status:** Completed
**Type:** Data Integrity Audit
**Document Audited:** `docs/plans/2026-01-28-csi-factor-model-redesign.md`
**Data Sources Verified Against:** Supabase (`nps_responses`, `support_case_details`, `support_sla_latest`)

---

## Overview

Cross-referenced every quantitative claim in the CSI factor model redesign document against source data in Supabase. Identified and corrected 6 discrepancies, updated all downstream calculations, and added methodology disclosures where data source limitations were not transparent.

---

## Audit Method

### Step 1: Identify All Verifiable Claims

Read the full document and catalogued every claim that references a specific number derived from database data:
- NPS scores per client per period
- Open case counts per client
- Factor activation (TRUE/FALSE) per client
- NPS delta calculations for threshold analysis
- Spearman correlation values
- Accuracy percentages (v1 and v2)

### Step 2: Query Source Data

For each verifiable claim, ran a Supabase REST API query to retrieve the underlying records. Key queries:

```bash
# SA Health Q4 2025 individual NPS scores
GET /rest/v1/nps_responses?client_name=eq.SA%20Health&period=eq.Q4%2025&select=score,contact_name,category

# SLMC open cases
GET /rest/v1/support_case_details?client_name=eq.SLMC&state=not.in.(Closed,Canceled,Resolved)&select=case_number,state,opened_at

# All-respondent vs verbatim-only averages (computed per client per period)
GET /rest/v1/nps_responses?period=eq.Q4%2025&select=score,client_name,feedback
```

### Step 3: Compare Document Claims Against Source Data

For each claim, compared the document's stated value against the computed value from source records. Flagged any discrepancy where:
- A number was materially wrong (e.g. NPS -25 vs actual -55)
- A binary factor activation was unsupported by data (e.g. Backlog>10 = TRUE with only 3 cases)
- A methodology was undisclosed and could mislead readers (e.g. verbatim-only averages)
- A classification was logically inconsistent with stated criteria

### Step 4: Fix Discrepancies and Cascade Changes

For each confirmed discrepancy:
1. Fixed the primary value
2. Traced all downstream references to the same value
3. Recalculated any derived metrics (NPS deltas, averages, accuracy counts)
4. Added disclosure notes where methodology limitations existed

### Step 5: Document Changes

Updated the document's validation history (Note block, round 7) to record what was corrected and why.

---

## Discrepancies Found and Fixed

### 1. SA Health Q4 2025 NPS: -25 → -55 (High Severity)

| Detail | Value |
|--------|-------|
| Document claimed | NPS = -25 |
| Supabase actual | NPS = -55 |
| Verification | 11 respondents: scores [8, 8, 8, 8, 7, 6, 6, 6, 5, 3, 1]. Promoters: 0. Detractors: 6. NPS = (0-6)/11×100 = -55 |
| Locations fixed | Sections 3.6, 3.7, 3.8, 3.9, 4.2 (7 occurrences) |

**Cascade impact:** All NPS delta calculations referencing SA Health were recalculated:
- Backlog >10 threshold: -69 → **-84** NPS delta
- Resolution >700h threshold: -92 → **-98** NPS delta
- Case-data backlog >10: -46 → **-56** NPS delta
- Resolution SLA <95%: -42 → **-57** NPS delta
- Support CSAT <4.5: +96 → **+81** (still reversed)

### 2. Section 3.5 Verbatim-Only Averages Undisclosed (Medium Severity)

| Detail | Value |
|--------|-------|
| Issue | "Q2 Avg → Q4 Avg" column used averages from verbatim respondents only, not all respondents |
| Example | WA Health: verbatim-only Q4 avg = 3.0 (n=1) vs all-respondent avg = 6.2 (n=4) — opposite direction |
| Fix | Added footnote disclosing methodology and warning against interpreting as representative client averages |

### 3. v1 Accuracy Table: 3 Classification Errors (Medium Severity)

| Client | Document | Correct | Reason |
|--------|----------|---------|--------|
| Dept Health Vic | YES | **NO** | CSI 75 (at-risk) vs NPS 0 (healthy) = mismatch |
| SLMC | NO | **YES** | CSI 75 (at-risk) vs NPS -100 (at-risk) = match |
| GRMC | YES | **NO** | CSI 75 (at-risk) vs NPS +100 (healthy) = mismatch |

**Impact:** v1 accuracy changed from 50% (5/10) to **40% (4/10)**. Updated in Problem Statement (Section 1), Section 3.2, and Section 4.4. Added explicit classification criteria note.

### 4. Factor #2 Threshold Wording vs Application (Medium Severity)

| Detail | Value |
|--------|-------|
| Factor name | "NPS Detractor (score 0-6)" |
| Actual application | NPS < 0 (net negative) |
| Divergence | MoD Singapore (individual score 5, NPS 0 → FALSE) and SingHealth (individual score 6, NPS 0 → FALSE) have individual detractor scores but net NPS ≥ 0 |
| Fix | Renamed to "NPS Detractor (NPS < 0)" with explicit clarification that net score drives the factor, not individual scores |

### 5. SLMC Backlog>10 = TRUE Unsupported (High Severity)

| Detail | Value |
|--------|-------|
| Document claimed | SLMC Support Backlog >10 = TRUE |
| Supabase actual | 3 open cases in `support_case_details`. No record in `support_sla_latest`. |
| Fix | Changed to FALSE. ARM: 66 → 51. CSI: 34 → 49. Still correctly classified as at-risk (CSI < 80, NPS -100). |

### 6. SLA vs Case Details Open Count Discrepancies (Low-Medium Severity)

| Client | SLA Dashboard | Case Details (Current) |
|--------|:------------:|:---------------------:|
| WA Health | 0 | 28 |
| Barwon Health | 4 | 11 |
| Epworth Healthcare | 11 | 14 |

**Fix:** Added data source note explaining that `support_sla_latest` is a point-in-time snapshot (Oct–Nov 2025) while `support_case_details` reflects current state. SLA dashboard is the more appropriate source for CSI model as it captures state during the NPS measurement period.

---

## Downstream Recalculations

| Metric | Before | After | Section |
|--------|--------|-------|---------|
| v1 accuracy | 50% (5/10) | **40% (4/10)** | 1, 3.2, 4.4 |
| Backlog >10 NPS delta | -69 | **-84** | 3.6, 3.7, 4.2 |
| Resolution >700h NPS delta | -92 | **-98** | 3.7, 4.2 |
| Case-data >10 NPS delta | -46 | **-56** | 3.7 |
| Resolution SLA <95% delta | -42 | **-57** | 3.6 |
| SLMC ARM / CSI | 66 / 34 | **51 / 49** | 4.4, 4.5 |
| >700h avg NPS | -50 | **-56** | 3.7, 4.2 |
| >10 open avg NPS | -62 | **-78** | 3.6, 4.2 |

**Net effect on model conclusions:** All corrections strengthen the evidence for the v2 model. NPS deltas are larger (stronger signal), v1 accuracy is worse (stronger case for redesign), and SLMC's CSI is less extreme but still correctly classified.

---

## Verification Checklist

- [x] Every SA Health NPS reference updated from -25 to -55
- [x] All NPS delta calculations recalculated with corrected SA Health value
- [x] v1 accuracy table corrected (Dept Vic, SLMC, GRMC)
- [x] v1 accuracy percentage updated in all locations (50% → 40%)
- [x] v2 accuracy table v1 column corrected (Dept Vic, SLMC, GRMC)
- [x] SLMC Backlog>10 changed to FALSE in factor activation table
- [x] SLMC ARM/CSI recalculated in both accuracy and activation tables
- [x] Factor #2 renamed and threshold clarified
- [x] Section 3.5 verbatim-only methodology disclosed
- [x] Section 3.6 SLA vs case_details data source note added
- [x] Spearman footnote added noting SA Health NPS correction
- [x] Document validation history updated (round 7)
- [x] Status line updated to include "data integrity audit"

---

## Lessons for Future Audits

1. **Always verify NPS calculations from individual scores** — aggregated NPS values in source documents may use different respondent subsets or rounding
2. **Check binary factor activations against both data sources** — SLMC appeared in the model as Backlog>10=TRUE despite having only 3 open cases, likely carried over from an earlier draft
3. **Disclose when averages use subsets** — verbatim-only averages can directionally contradict all-respondent averages (WA Health: 3.0 vs 6.2)
4. **Verify classification logic is consistently applied** — the v1 accuracy table had 3 errors because NPS=0 clients and CSI=75 clients were inconsistently classified
5. **Document data source timing differences** — SLA dashboard snapshots and current case state can differ by 10x for the same client (WA Health: 0 vs 28 open cases)

---

*Audit performed as part of CSI Factor Model Redesign validation — see `docs/plans/2026-01-28-csi-factor-model-redesign.md` (round 7 in validation history).*
