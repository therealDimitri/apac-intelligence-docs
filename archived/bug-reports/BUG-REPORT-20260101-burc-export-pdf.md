# Bug Report: BURC Export Report PDF Function

**Date:** 1 January 2026
**Status:** Fixed
**Severity:** Medium (Missing functionality)
**Component:** BURC Financials page (`/financials`)

## Issue Description

The "Export Report" button on the BURC Financials page had no onClick handler, making it non-functional. Users expected to download a PDF report of the BURC financial data.

## Root Cause

The button was implemented in the UI but the export functionality was never connected.

```tsx
// Before - No onClick handler
<button className="px-4 py-2 text-sm text-gray-600 hover:bg-gray-100 rounded-lg transition-colors flex items-center gap-2">
  <Download className="h-4 w-4" />
  Export Report
</button>
```

## Solution

Implemented a comprehensive PDF export function using jsPDF that generates a multi-page report including:

### PDF Content

1. **Report Header**
   - Title: "BURC Financial Report"
   - Generation timestamp
   - Data sync timestamp

2. **EBITA Performance**
   - Target EBITA (2026)
   - YTD Actual vs Target
   - Variance
   - Percentage of target achieved

3. **Revenue Pipeline**
   - Committed Revenue
   - Best Case
   - Pipeline
   - Total Potential

4. **Revenue Waterfall Detail**
   - All waterfall items with amounts

5. **Professional Services Pipeline**
   - Backlog
   - Best Case
   - Pipeline
   - Business Case

6. **Top Maintenance Clients**
   - Top 10 clients by annual maintenance value

7. **Revenue Alerts Summary** (New page)
   - Total alerts count
   - Critical alerts count
   - Revenue at risk
   - Opportunities
   - Top 10 alerts by financial impact

8. **CSI Ratios** (New page)
   - All 5 CSI ratios with targets
   - Underlying financials (Revenue, OPEX, EBITA)

9. **Footer**
   - Page numbers
   - Report branding

## Changes Made

### File: `src/app/(dashboard)/financials/page.tsx`

1. **Added jsPDF import**:
```tsx
import jsPDF from 'jspdf'
```

2. **Added `handleExportReport` function** (~150 lines):
   - Helper functions for PDF formatting (addTitle, addSectionTitle, addRow, addDivider)
   - Auto page break handling
   - Currency formatting using existing `formatCurrency` utility
   - Multi-page support with proper page numbering

3. **Connected button**:
```tsx
<button
  onClick={handleExportReport}
  className="px-4 py-2 text-sm text-gray-600 hover:bg-gray-100 rounded-lg transition-colors flex items-center gap-2"
>
  <Download className="h-4 w-4" />
  Export Report
</button>
```

## Dependencies

- `jspdf` (^3.0.4) - Already installed in project

## PDF Output

- Filename format: `BURC-Report-YYYY-MM-DD.pdf`
- Page size: A4 (default)
- Font: Helvetica (built-in)
- Colour scheme: Grayscale with proper hierarchy

## Testing

1. Navigate to BURC Financials page (`/financials`)
2. Click "Export Report" button
3. Verify PDF downloads with correct filename
4. Open PDF and verify:
   - All sections are present
   - Data matches the dashboard values
   - Page breaks occur appropriately
   - Footer shows on all pages

## Future Enhancements

1. **Tab-specific exports**: Export only the currently active tab's data
2. **Date range selection**: Allow user to select reporting period
3. **Include charts**: Use html2canvas to capture chart images
4. **Email option**: Send report directly to email
5. **Scheduled exports**: Auto-generate weekly/monthly reports
