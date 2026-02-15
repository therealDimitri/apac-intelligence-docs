# Feature: 2026 Pipeline Page with BURC Cross-Reference

**Date:** 12 January 2026
**Status:** Implemented
**Type:** New Feature
**Priority:** High

## Summary

Created a new 2026 Pipeline Overview page that imports opportunity data from the Sales Budget Excel file and cross-references with the BURC Performance file to display status badges.

## Feature Requirements

The user requested a page that:
1. Imports data from `APAC 2026 Sales Budget 6Jan2026.xlsx` (APAC Pipeline by Qtr (2) sheet)
2. Displays all 18 columns: Fiscal Period, Forecast Category, Account Name, Opportunity Name, CSE, CAM, In or Out, < 75K, Upside, Focus Deal, Close Date, Oracle Quote Number, Total ACV, Oracle Quote Status, TCV, Weighted ACV, ACV Net COGS, Bookings Forecast
3. Cross-references with `2026 APAC Performance.xlsx` (Rats and Mice Only, Dial 2 Risk Profile Summary sheets)
4. Displays BURC status badges: Best Case, Backlog (Green/Yellow/Red), Business Case, or Not in BURC (red)

## Implementation

### Files Created

1. **src/app/(dashboard)/pipeline/page.tsx** - Main page component
   - Stats cards (Total Opps, Total ACV, Weighted ACV, Best Case, Backlog, Not in BURC)
   - Filter bar (Search, Quarter, BURC Status, Forecast Category, CSE)
   - Sortable data table with all 18 columns plus BURC Status
   - BURCStatusBadge component with colour-coded badges

2. **src/app/api/pipeline/2026/route.ts** - API route
   - Parses Sales Budget Excel file using xlsx library
   - Parses BURC Performance file for cross-reference
   - Matches opportunities by name/account/Oracle number
   - Returns opportunities with BURC status and summary statistics

### Files Modified

1. **src/components/layout/sidebar.tsx** - Added "2026 Pipeline" link under Financials

### BURC Status Badge Logic

| Status | Colour | Condition |
|--------|--------|-----------|
| Best Case | Blue | Forecast Category = "Best Case" in BURC |
| Backlog (Green) | Green | In Dial 2 Green section |
| Backlog (Yellow) | Yellow | In Dial 2 Yellow section |
| Backlog (Red) | Red | In Dial 2 Red section |
| Business Case | Purple | Forecast Category contains "Bus Case" |
| Not in BURC | Red | Not found in either BURC sheet |

### Cross-Reference Logic

The API attempts to match opportunities using:
1. Exact match by opportunity name (case-insensitive)
2. Partial match (opportunity name contains BURC entry or vice versa)
3. Account name match with Oracle quote number verification

## Data Sources

### Sales Budget File
- Path: `/Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth/Documents/Client Success/Team Docs/Sales Targets/2026/APAC 2026 Sales Budget 6Jan2026.xlsx`
- Sheet: `APAC Pipeline by Qtr (2)`
- Headers at row 6, data starts row 7
- Total rows: ~155 opportunities

### BURC Performance File
- Path: `/Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth/APAC Leadership Team - General/Performance/Financials/BURC/2026/2026 APAC Performance.xlsx`
- Sheets: `Rats and Mice Only`, `Dial 2 Risk Profile Summary`
- Contains forecast categories and colour-coded sections

## UI Features

- **Stats Cards**: Visual summary of pipeline health
- **Filters**: Multiple simultaneous filters with real-time updates
- **Sortable Columns**: Click column headers to sort asc/desc
- **Responsive Table**: Horizontal scroll for all columns
- **Colour-Coded Badges**:
  - In/Out: Green for "In", grey for "Out"
  - BURC Status: Blue (Best Case), Green/Yellow/Red (Backlog), Purple (Business Case), Red (Not in BURC)
- **Currency Formatting**: Automatic M/k suffixes for large values
- **Filtered Totals**: ACV and Weighted ACV update based on active filters

## Testing Performed

- [x] Build passes with zero TypeScript errors
- [x] Page loads 155 opportunities from Excel
- [x] Stats cards display correct totals
- [x] BURC cross-reference identifies 2 Best Case, 153 Not in BURC
- [x] All filters work correctly
- [x] Column sorting works
- [x] BURC status badges display with correct colours
- [x] Page accessible from sidebar under Financials > 2026 Pipeline

## Screenshots

The page displays:
- Header: "2026 Pipeline Overview" with last updated timestamp
- 6 stats cards in a row
- Filter bar with search and dropdowns
- Summary line showing filtered count and totals
- Full data table with 19 columns

## Commit

```
feat: Add 2026 Pipeline page with BURC cross-reference badges
```
