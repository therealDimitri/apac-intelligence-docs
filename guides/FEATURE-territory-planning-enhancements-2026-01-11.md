# Territory Planning Page Enhancements

**Date:** 11 January 2026
**Page:** `/planning/territory/new`
**File:** `src/app/(dashboard)/planning/territory/new/page.tsx`

---

## Summary

Multiple UX improvements and bug fixes to the CSE Territory Strategy planning workflow, focusing on the Top Opportunities selection, Revenue Targets table, and Risk Assessment sections.

---

## Changes Made

### 1. Epworth Client Logo Fix
**Commit:** `5c296fd0`

**Issue:** Epworth HealthCare logo was not displaying (showing "EH" fallback instead).

**Root Cause:** The client name "Epworth HealthCare" (capital C) from Salesforce didn't match the alias "Epworth Healthcare" (lowercase c) in the logo mapping.

**Fix:**
- Added "Epworth HealthCare" alias to Supabase `client_name_aliases` table
- Added fallback alias in `src/lib/client-logos-local.ts`

**Files Modified:**
- `src/lib/client-logos-local.ts`

---

### 2. Top Opportunities Selection Instructions
**Commit:** `5c296fd0`

**Enhancement:** Added a blue instructional panel explaining how to select opportunities.

**Instructions Added:**
- Review your pipeline below - sorted by highest value by default
- Click the checkbox next to each opportunity you want to prioritise
- Focus on deals with strong MEDDPICC scores (20+) and near-term close dates
- Look for BURC/Focus Deal badges - these are pre-identified priority deals
- Maximum 20 opportunities - this ensures focus and quality execution

---

### 3. Value vs FY26 Target Metric
**Commit:** `5c296fd0`

**Enhancement:** Added "vs FY26 Target" column to the selection summary card.

**Features:**
- Shows percentage of annual target covered by selected opportunities
- Displays target amount (e.g., "of $400k")
- Green when >= 100%, amber when below

---

### 4. Increased Max Selections to 20
**Commits:** `a0c21184`, `4322ddda`

**Change:** Increased `MAX_SELECTIONS` from 5 → 10 → 20

**Updated Text:**
- "Select up to 20 strategic opportunities to focus on"
- "How to Select Your Top 20 Opportunities"
- "Maximum 20 opportunities"

---

### 5. Column Header Definitions
**Commit:** `a0c21184`

**Enhancement:** Added descriptive subtitles and tooltips to pipeline table headers.

| Column | Subtitle | Tooltip |
|--------|----------|---------|
| ✓ | — | Select opportunities to include in your territory plan |
| Opportunity | Deal name from Salesforce | Click row to expand details |
| Client | Account name | Client organisation |
| Tags | BURC / Focus | BURC = Business Unit Review Committee priority |
| Stage | Sales stage | Pipeline → Qualify → Best Case → Commit → Won |
| Wgt ACV | ACV × Probability | Weighted ACV = risk-adjusted forecast value |
| Close | Expected date | When the deal is forecast to close |

---

### 6. Removed MEDDPICC Column from Selection
**Commit:** `57d60461`

**Rationale:** MEDDPICC scoring should happen after opportunities are selected, not during the selection step.

**Change:** Removed the MEDDPICC column from the pipeline selection table to simplify the workflow.

---

### 7. Navigation Z-Index Fix
**Commit:** `8eb27d19`

**Issue:** "Next" button was appearing behind the ChaSen chat widget on 14" and 16" MacBook displays.

**Fix:**
- Added `z-[10000]` to navigation container
- Added `pb-20` bottom padding to prevent overlap
- Added `shadow-lg` to Next button for visibility

---

### 8. Centered Table Columns
**Commit:** `8eb27d19`

**Enhancement:** Centered all columns in the Quarterly Revenue Targets table.

**Affected:**
- Header row (all 6 columns)
- Body rows (Quarter, TCV, Wgt ACV Target, Wgt ACV Pipeline, Coverage, Confidence)
- Footer row (FY26 Total)

---

### 9. 100% Target Color Fix
**Commit:** `b30de4e3`

**Issue:** "vs FY26 Target" showed amber at 100% when it should be green.

**Root Cause:** The colour check used raw percentage (e.g., 99.6%) while display used rounded (100%).

**Fix:** Changed to use `roundedPercent` for both display and colour check:
```typescript
const roundedPercent = Math.round(percentOfTarget)
const isOnTrack = roundedPercent >= 100
```

---

### 10. Risk Assessment Client Auto-Populate
**Commit:** `d58bca19`

**Enhancement:** Changed Client Name field from text input to dropdown.

**Features:**
- Populated with portfolio clients for easy selection
- Auto-fills Revenue at Risk with client's ARR when selected
- Placeholder: "Select a client..."

---

## Testing Checklist

- [ ] Epworth logo displays correctly
- [ ] Selection instructions appear in blue panel
- [ ] vs FY26 Target shows percentage and target amount
- [ ] Can select up to 20 opportunities
- [ ] Column headers have subtitles visible
- [ ] MEDDPICC column is not visible in selection table
- [ ] Next button visible above ChaSen widget on all displays
- [ ] Revenue Targets table columns are centered
- [ ] 100% target shows green colour
- [ ] Risk Assessment client dropdown shows portfolio clients
- [ ] Revenue at Risk auto-fills when client selected

---

## Related Files

| File | Changes |
|------|---------|
| `src/app/(dashboard)/planning/territory/new/page.tsx` | Main page component |
| `src/lib/client-logos-local.ts` | Client logo mapping |
| `client_name_aliases` (Supabase) | Database alias table |

---

## Commits Summary

| Commit | Description |
|--------|-------------|
| `5c296fd0` | Epworth logo fix + selection instructions + value vs target |
| `a0c21184` | Top 10 opportunities + column definitions |
| `57d60461` | Removed MEDDPICC from selection table |
| `8eb27d19` | Navigation z-index fix + centered table columns |
| `4322ddda` | Increased max selections to 20 |
| `b30de4e3` | Fixed 100% target colour to green |
| `d58bca19` | Client name auto-populate dropdown |
