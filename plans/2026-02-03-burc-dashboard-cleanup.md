# BURC Dashboard Cleanup Plan

**Date:** 3 February 2026
**Component:** `src/components/burc/BURCExecutiveDashboard.tsx`

## Summary

Clean up the BU Performance (BURC Executive Dashboard) page by removing unused/redundant UI elements and verifying data accuracy.

---

## Task 1: Remove Alerts/Warning Card

**Location:** Lines 1072-1101

**Action:** Remove the entire alerts banner section that displays:
- "1 critical and 2 warning alerts require attention"
- Pipeline Coverage threshold alert
- Net Revenue Retention threshold alert
- At-risk clients threshold alert

**Code to remove:**
- The `{alerts.length > 0 && (...)}` conditional block
- Related state: `alerts`, `criticalAlerts`, `warningAlerts` (lines 1021-1022)
- Data fetch from `burc_active_alerts` table (lines 416-420)
- Alert modal state and component (lines 2295-2445)

**Rationale:** User requested removal - these alerts are redundant with data shown elsewhere on the dashboard.

---

## Task 2: Remove "Pipeline (Not Forecast)" Entry

**Location:** Lines 1757-1773 (inside Total Pipeline expanded view)

**Action:** Remove the grey "Pipeline (Not Forecast)" sub-card showing:
- 44 deals
- $7.2M value

**Keep:**
- "In Forecast" sub-card ($12.3M, 28 deals)
- "Weighted Revenue" sub-card ($7.9M, 41% of total)
- Total Value and Opportunities count in header

**Rationale:** User only wants to see forecast pipeline, not speculative pipeline.

---

## Task 3: Verify Attrition Risk Card ✓

**Location:** Lines 1852-1943

**Verification Results:**
| Metric | Dashboard | Database | Status |
|--------|-----------|----------|--------|
| 2026 Churn | $675.0K | $675.0K (`burc_executive_summary.total_at_risk`) | ✓ Match |
| Accounts at Risk | 8 | 8 records in `burc_attrition_risk` | ✓ Match |
| Multi-Year Total | $2.1M | $2,073.5K (sum of `total_at_risk`) | ✓ Match |

**Impacted Clients Shown:**
- Sing Health DMD Licences: $45.0K (Mar 2026)
- GHA Regional Opal: $200.0K (Jul 2026)
- Sing Health KKH iPro and Capsule: $18.0K (Nov 2026)

**Action:** No changes needed - data is accurate.

---

## Task 4: Verify Overdue & Upcoming Renewals Card ✓

**Location:** Lines 1945-2068

**Verification Results:**
| Overdue Contract | Dashboard | Database | Status |
|------------------|-----------|----------|--------|
| Royal Victorian Eye & Ear | $29.1K (31 Dec 2024) | $29.1K (2024-12-31) | ✓ Match |
| Gippsland Health Alliance | $124.8K (14 Jul 2025) | $124.8K (2025-07-14) | ✓ Match |
| Grampians Health | $145.5K (30 Sep 2025) | $145.5K (2025-09-30) | ✓ Match |
| Epworth Healthcare | $149.9K (15 Nov 2025) | $149.9K (2025-11-15) | ✓ Match |
| **Total Overdue** | **4 ($449.3K)** | **4 ($449.3K)** | ✓ Match |

**Action:** No changes needed - data is accurate.

---

## Task 5: Verify Net Revenue Impact Bar ✓

**Location:** Lines 2071-2111

**Calculation Verification:**
```
Weighted Pipeline:     $7,930,000  (from burc_executive_summary)
Total At Risk:         $  675,000  (from burc_executive_summary)
─────────────────────────────────
Net Impact:            $7,255,000  ≈ $7.3M ✓

Coverage Ratio:        7,255,000 / 7,930,000 = 91.5% ≈ 91% ✓
```

**Action:** No changes needed - calculation is accurate.

---

## Task 6: Remove FY26 Progress Card

**Location:** Lines 2144-2145

**Component:** `<YTDProgress targets={ytdTargets} fiscalYearProgress={fiscalYearProgress} />`

**Action:** Remove:
- The YTDProgress component render
- Related state: `ytdTargets` (lines 963-985)
- Related calculation: `fiscalYearProgress` (lines 1003-1010)

**What it currently shows:**
- Revenue Retention: 99% (Target: 100%)
- Gross Retention: 96% (Target: 92%)
- Rule of 40: 48 (Target: 40)
- 58% through year indicator

**Rationale:** User requested removal - metrics are already shown in the main KPI cards above.

---

## Task 7: Pipeline Reconciliation Card - Explanation

**Location:** Lines 2270-2275

**Component:** `<BURCReconciliation />`

**Purpose:** Compares two data sources to identify discrepancies:

1. **Pipeline Total**: Sum of all deals in `burc_pipeline_detail` (FY2026)
2. **Waterfall Total**: Sum from BURC waterfall categories (Business Case, Best Case, etc.)
3. **Variance**: Pipeline Total - Waterfall Total

**Current State:** Shows $0 for all three values, indicating either:
- No data in the reconciliation API
- The two sources are perfectly reconciled (unlikely)
- The feature is incomplete/not populated

**Logic Flow:**
1. Fetches from `/api/analytics/burc/reconciliation?year=2026`
2. Compares pipeline deals against waterfall forecast categories
3. Flags deals that appear in pipeline but not in waterfall (or vice versa)
4. Shows overall reconciliation status: RECONCILED | REVIEW | CRITICAL

**Recommendation:** Investigate why all values are $0 - likely needs data population or API fix.

---

## Implementation Order

1. **Remove Alerts Card** - Simple removal, no data dependencies
2. **Remove Pipeline (Not Forecast)** - Simple removal from expanded view
3. **Remove FY26 Progress Card** - Simple removal, no data dependencies
4. **Investigate Pipeline Reconciliation** - May need API/data work

## Files to Modify

- `src/components/burc/BURCExecutiveDashboard.tsx` - Main changes
- Potentially `src/components/burc/ExecutiveQuickGlanceWidgets.tsx` - If YTDProgress cleanup needed

## Testing Checklist

- [ ] Dashboard loads without errors
- [ ] Alerts banner no longer appears
- [ ] Total Pipeline card expands but only shows In Forecast and Weighted Revenue
- [ ] FY26 Progress card no longer appears
- [ ] All remaining cards display correct data
- [ ] No console errors
- [ ] Build passes
