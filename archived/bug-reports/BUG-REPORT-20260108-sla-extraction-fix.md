# Bug Report: SLA Compliance Percentage Not Extracted from Excel Files

**Date:** 8 January 2026
**Status:** Fixed
**Commits:** `48b445f` (scripts), `3d0b9fff` (main)

## Issue Summary

The Support Health page was showing "N/A%" for SLA compliance for all clients, despite the source Excel files containing actual SLA data.

## Root Cause

The `extractSLACompliance()` function in `scripts/sync-sla-reports.mjs` was looking for SLA values incorrectly. It searched for rows where the **first cell** contained text like "response compliance" or "resolution compliance", but the actual Excel structure is:

```
Row: Section header (e.g., "Monthly Response Time Compliance")
Row: Column headers (Month | SLA Met | SLA Missed | Grand Total | Compliance %)
Rows: Monthly data (Sept'25 | 31 | 0 | 31 | 100%)
Row: Grand Total | 72 | 0 | 72 | 100%  <-- Compliance % in LAST column
```

The compliance percentage is in the **last column** of the **Grand Total row**, not in the first cell.

## Solution

Updated `extractSLACompliance()` to:

1. **Track current section** - Detect section headers like "Monthly Response Time Compliance", "Resolution Compliance", "Ongoing Engagement Compliance"

2. **Find Grand Total row** - Look for rows where first cell equals "grand total"

3. **Extract percentage from last column** - Scan backwards from last column to find the compliance percentage

4. **Handle both formats** - Support decimal values (0.893) and percentage values (89.3)

### Code Change (sync-sla-reports.mjs)

```javascript
// Track which section we're in
let currentSection = null;

for (let i = 0; i < data.length; i++) {
  const row = data[i];
  const firstCell = String(row[0] || '').toLowerCase().trim();

  // Detect section headers
  if (firstCell.includes('response') && firstCell.includes('time') && firstCell.includes('compliance')) {
    currentSection = 'response';
  }
  if (firstCell.includes('resolution') && firstCell.includes('compliance')) {
    currentSection = 'resolution';
  }

  // Look for "Grand Total" row - this has the overall compliance percentage
  if (firstCell === 'grand total') {
    // Find the compliance percentage (usually last non-empty column)
    for (let j = row.length - 1; j >= 1; j--) {
      const val = row[j];
      const numVal = parseFloat(val);
      if (!isNaN(numVal)) {
        // Convert decimal to percentage if needed
        const compliancePercent = numVal <= 1 ? numVal * 100 : numVal;

        if (currentSection === 'response') response = compliancePercent;
        if (currentSection === 'resolution') resolution = compliancePercent;
        break;
      }
    }
  }
}
```

## Client-Specific Notes

Different clients have different Excel structures:

| Client | Sheet Name | Notes |
|--------|------------|-------|
| WA Health | "SLA Compliance" | Standard structure |
| Barwon Health | "SLA Compliance" | Standard structure |
| Grampians | "SLA Compliance" | Standard structure |
| RVEEH | "SLA Compliance" | Standard structure |
| Albury Wodonga | "SLA Compliance" | Standard structure |
| SA Health | "Resolution Compliance" | Separate sheets for each SLA type |

The import script handles this with `findSheet(workbook, 'SLA Compliance', 'Resolution Compliance', 'Response')`.

## Verification

After re-running the sync:

| Client | Response SLA | Resolution SLA |
|--------|--------------|----------------|
| WA Health | 100% | 89.3% |
| Barwon Health | 100% | 100% |
| Grampians | 100% | 100% |
| RVEEH | 100% | 100% |
| Albury Wodonga | 100% | 100% |
| SA Health | N/A | 100% |

## Files Modified

- `scripts/sync-sla-reports.mjs` - Fixed `extractSLACompliance()` function

## Lessons Learned

1. **Always verify Excel structure** - Different clients may have different worksheet layouts
2. **Test with actual data** - The original code was written without testing against real Excel files
3. **SLA data is in Grand Total rows** - Not in section headers
