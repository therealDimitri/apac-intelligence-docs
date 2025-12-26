# Bug Fix: Aged Accounts Export Button Exports Wrong Data

**Date:** 21 December 2025
**Type:** Bug Fix
**Status:** Fixed

## Summary

The Export button on the Aged Accounts Compliance dashboard was exporting a minimal CSE-level summary that lacked useful aged accounts information. Users expected detailed client-level aging data with all aging buckets.

## Previous Behaviour

The export only included:

- CSE Name
- Total Clients
- Total Outstanding
- Percent Under 60 Days
- Percent Under 90 Days
- Health Score
- Meets Goals
- Generated At

This was essentially a summary row per CSE with no client-level detail.

## New Behaviour

The export now generates a comprehensive "Aged Accounts Receivable Report" with three sections:

### 1. Portfolio Summary

- Total Outstanding (USD)
- Total Clients
- Average % Under 60 Days
- Average % Under 90 Days
- Average Health Score

### 2. CSE Compliance Summary

- CSE Name
- Total Clients
- Total Outstanding (USD)
- Percent Under 60 Days
- Percent Under 90 Days
- Health Score
- Meets Goals

### 3. Client Aging Detail

- CSE Name
- Client Name
- Risk Level (low/medium/high/critical)
- Total Outstanding (USD)
- Current
- 1-30 Days
- 31-60 Days
- 61-90 Days
- 91-120 Days
- 121-180 Days
- 181-270 Days
- 271-365 Days
- 365+ Days
- Invoice Count
- Status (Active/Inactive)

## Technical Changes

The `exportToCSV` function in `src/app/(dashboard)/aging-accounts/compliance/page.tsx` was completely rewritten to:

1. Build client-level rows from all CSE data
2. Sort by CSE name, then by total outstanding (descending)
3. Create a multi-section CSV with headers and formatting
4. Include portfolio-level aggregations
5. Properly escape CSV values containing commas

## Files Changed

| File                                                     | Change                                                  |
| -------------------------------------------------------- | ------------------------------------------------------- |
| `src/app/(dashboard)/aging-accounts/compliance/page.tsx` | Rewrote `exportToCSV` function for comprehensive report |

## Export Filename

Changed from: `aging-compliance-YYYY-MM-DD.csv`
To: `aged-accounts-report-YYYY-MM-DD.csv`

## Testing

1. Navigate to `/aging-accounts/compliance`
2. Click the Export button
3. Open the downloaded CSV file
4. Verify all three sections are present
5. Verify client-level aging buckets contain data
