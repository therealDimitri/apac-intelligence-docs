# Bug Report: CSI Ratios Not Matching 2026 Performance Excel

**Status:** Fixed

## Date
2026-01-19

## Summary
The CSI Ratios displayed on the Executive Dashboard did not match the values in the 2026 APAC Performance Excel file. The dashboard was showing PS=0.00, Sales=10.86, Maint=0.00 instead of the correct values.

## Root Cause
1. **Placeholder OPEX data**: The `burc_csi_opex` table had placeholder values for OPEX ($25k PS OPEX, $12k S&M OPEX, etc.) instead of actual budget figures
2. **Missing revenue data**: PS_NR and Maintenance_NR were $0 for most months
3. **API calculated from wrong source**: The CSI ratios API was calculating ratios from `burc_csi_opex` instead of using the pre-calculated ratios in `burc_csi_ratios` table

## Incorrect vs Correct Values (December 2026)

| Ratio | Displayed (Wrong) | Excel (Correct) | Target |
|-------|-------------------|-----------------|--------|
| PS | 0.00 | **2.52** | ≥2.0 |
| Sales (APAC) | 10.86 | **0.42** | ≥1.0 |
| Maintenance | 0.00 | **4.71** | ≥4.0 |
| R&D | 11.17 | **0.16** | ≥1.0 |
| G&A | 0.9% | **19.2%** | ≤20% |

## Fix Applied

### 1. Updated `burc_csi_ratios` table
Synced pre-calculated ratios directly from rows 122-131 of the "APAC BURC" sheet in the 2026 APAC Performance Excel file.

```typescript
// Row mappings in Excel (0-indexed)
const rowMappings = {
  ps: 125, // Row 126: Professional Services (>2)
  apacMaintenance: 129, // Row 130: APAC Maintenance
  apacSM: 130, // Row 131: APAC S&M
  rd: 124, // Row 125: R&D
  admin: 126, // Row 127: Administration
}
```

### 2. Updated CSI Ratios API
Modified `/api/analytics/burc/csi-ratios` to:
- First check `burc_csi_ratios` table for pre-calculated values
- Fall back to calculating from `burc_csi_opex` only if no pre-calculated data exists
- This ensures the dashboard displays the same values as the Excel file

## Files Modified
- `/src/app/api/analytics/burc/csi-ratios/route.ts` - Updated to use pre-calculated ratios
- `burc_csi_ratios` table - Updated with correct 2026 values

## Scripts Created
- `/scripts/sync-csi-from-excel.ts` - Syncs CSI ratios from Excel to database
- `/scripts/read-csi-excel.ts` - Debug script to read Excel data

## 2026 CSI Ratios (All Months)

| Month | PS | Sales | Maint | R&D | G&A |
|-------|-----|-------|-------|-----|-----|
| Jan | 1.75 | 0.39 | 4.15 | 0.25 | 23.4% |
| Feb | 2.06 | 0.42 | 4.45 | 0.27 | 21.3% |
| Mar | 2.30 | 0.36 | 4.65 | 0.28 | 20.6% |
| Apr | 2.41 | 0.38 | 4.23 | 0.26 | 21.0% |
| May | 2.70 | 0.41 | 4.52 | 0.28 | 20.0% |
| Jun | 2.55 | 0.47 | 4.63 | 0.29 | 19.9% |
| Jul | 2.97 | 4.80 | 4.39 | 1.16 | 9.5% |
| Aug | 3.16 | 1.28 | 14.20 | 0.87 | 8.0% |
| Sep | 3.16 | 0.42 | 4.68 | 0.29 | 17.7% |
| Oct | 3.16 | 0.39 | 4.34 | 0.27 | 18.4% |
| Nov | 2.91 | 0.47 | 5.18 | 0.32 | 17.1% |
| Dec | 2.52 | 0.42 | 4.71 | 0.16 | 19.2% |

## Source Document
- File: `/Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth/APAC Leadership Team - BURC/2026/2026 APAC Performance.xlsx`
- Sheet: "APAC BURC"
- Rows: 122-131

## Recommendations

### Short-term
1. ✅ Sync pre-calculated ratios from Excel to database (DONE)
2. ✅ Update API to use pre-calculated ratios (DONE)

### Long-term
1. Automate Excel sync to run on file change
2. Fix underlying OPEX data in `burc_csi_opex` table to match actual budget
3. Add data validation to flag when calculated ratios differ significantly from Excel values

## Testing
- Build passes with zero TypeScript errors
- Dashboard should now show correct CSI ratios matching the Excel file
