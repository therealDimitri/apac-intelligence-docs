# Feature: BURC-Only Opportunities (Not in Target)

**Date**: 16 January 2026
**Status**: Implemented
**Related Commits**: 1a34754f, eb343c8, 40a52af4

---

## Overview

Added functionality to display opportunities that exist in the BURC file but are NOT in the Sales Budget. These opportunities are now visible in the planning wizards with an amber "Not in Target" badge, distinguishing them from "In Target" opportunities.

---

## Problem Statement

Previously, the planning wizards only displayed opportunities from the `sales_pipeline_opportunities` table (Sales Budget). Opportunities tracked in the BURC file that were not yet in the Sales Budget were invisible to users, creating a gap in pipeline visibility.

---

## Solution

### 1. BURC File Analysis Script

Created `scripts/analyze-burc-file.mjs` to:
- Parse the 2026 APAC Performance.xlsx file
- Extract opportunities from "Rats and Mice Only" and "Dial 2 Risk Profile Summary" sheets
- Match against Sales Budget using multiple strategies:
  - Oracle agreement number matching
  - Exact name matching (normalised)
  - Fuzzy matching (>85% Levenshtein similarity)
  - Keyword overlap matching (>60% overlap, minimum 2 keywords)
- Insert unmatched opportunities into `pipeline_opportunities` table with `in_target = false`

### 2. Database Schema

The `pipeline_opportunities` table now includes:
- `in_target` boolean field - `true` for Sales Budget opportunities, `false` for BURC-only
- `burc_source_sheet` - "Rats and Mice" or "Dial 2 Risk Profile"
- `burc_match` - always `true` for records from this table

### 3. UI Updates

**Badge Logic:**
- **In Target** (green): Opportunity exists in Sales Budget Excel
- **Not in Target** (amber): Opportunity exists in BURC only

**Files Updated:**
- `src/contexts/PlanningPortfolioContext.tsx` - Added `not_in_target` to PipelineTargetStatus type
- `src/app/(dashboard)/planning/strategic/new/page.tsx` - Fetches from both sources
- `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx` - Dynamic badge rendering
- `src/app/(dashboard)/planning/territory/new/page.tsx` - Same updates for territory planning

---

## BURC-Only Opportunities Identified

Initial analysis found 37 opportunities in BURC but not in Sales Budget, including:

| Client | Examples |
|--------|----------|
| Mindef Singapore | NCS CCR 0051 Opal PR8, CCR 0041 SCM Dispensary Tab, SQL Licence |
| SA Health | TQEH AIMS, Meds Management, AI Scribe Connector, ECG Worklist |
| WA Health | Renewal components (Maintenance, Reversal) |
| SingHealth | SCM 25.1 Upgrade, NEHR Replacement |
| GHA | Sunrise Support Renewals (3PP, Regional Opal, Atalasoft) |
| APAC Regional | AI Scribe Connector, ECG Worklist Integration, Expansion Pack |

---

## How to Re-run Analysis

If the BURC file is updated with new opportunities:

```bash
node scripts/analyze-burc-file.mjs
```

This will:
1. Re-parse the BURC Excel file
2. Match against current Sales Budget
3. Insert any new unmatched opportunities as "Not in Target"
4. Skip duplicates (checked by Oracle number and name)

---

## Related Documentation

- [Data Connections Audit](./DATA-CONNECTIONS-AUDIT-20260116.md)
- [Bug Report: BURC Matching Fix](./BUG-REPORT-BURC-MATCHING-20260116.md)
