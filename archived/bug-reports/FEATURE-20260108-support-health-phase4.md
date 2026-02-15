# Feature: Support Health Page - Phase 4 (Advanced Features)

**Date:** 8 January 2026
**Status:** ✅ Completed
**Related:** FEATURE-20260108-support-health-phase1.md, FEATURE-20260108-support-health-phase2.md, FEATURE-20260108-support-health-phase3.md

## Overview

Phase 4 adds advanced reporting and automation features to the Support Health page:
- Excel export with formatted multi-sheet workbook
- Scheduled weekly email reports with ChaSen branding
- Print-friendly dashboard view with optimised CSS

## Files Created

### 1. Excel Export API

**`src/app/api/support-metrics/export/route.ts`**

Multi-sheet Excel workbook export with:

| Sheet | Description |
|-------|-------------|
| Summary | Report header, total statistics, health distribution |
| Client Metrics | Full client data with all support metrics |
| At-Risk Clients | Filtered view of clients with health < 70% |
| Service Credits | Quarterly SLA performance and credits (if data exists) |
| Known Problems | Tracked issues by priority/status (if data exists) |

**Features:**
- Auto-sized column widths
- Date-stamped filename
- Formatted percentages and currency values
- Primary issue identification for at-risk clients

**Usage:**
```
GET /api/support-metrics/export
Response: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
```

### 2. Email Template

**`src/emails/templates/SupportHealthReport.tsx`**

React Email template with ChaSen branding for weekly reports:

| Section | Content |
|---------|---------|
| Header | Report title and date |
| Portfolio Overview | Avg health score, open cases, critical cases |
| Health Distribution | Healthy/At Risk/Critical client counts |
| SLA Performance | Response and Resolution SLA percentages |
| Clients Requiring Attention | Table of at-risk clients with scores |
| Top Performers | Best performing clients |
| Notable Changes | Week-over-week score changes |
| Key Insights | AI-generated observations |

**Props Interface:**
```typescript
interface SupportHealthReportProps {
  recipientName: string
  reportDate: string
  summary: {
    totalClients: number
    avgHealthScore: number
    clientsHealthy: number
    clientsAtRisk: number
    clientsCritical: number
    totalOpenCases: number
    totalCriticalCases: number
    totalAging30Plus: number
    avgResponseSla: number
    avgResolutionSla: number
  }
  atRiskClients: ClientMetric[]
  topPerformers: ClientMetric[]
  recentChanges?: ChangeRecord[]
  insights?: string[]
}
```

### 3. Scheduled Email Cron

**`src/app/api/cron/support-health-report/route.ts`**

Weekly cron job for sending support health reports:

**Features:**
- Fetches live data from `support_sla_metrics` table
- Calculates summary statistics and insights
- Identifies at-risk clients (score < 70)
- Identifies top performers (score >= 85)
- Generates AI insights based on metrics
- Logs all email sends to `email_logs` table
- Protected by CRON_SECRET in production

**Default Recipients:**
- To: Dimitri Leimonitis
- CC: Stephen Oster

**Schedule:** Every Monday at 8:00 AM (AEST)

### 4. Print Styles Component

**`src/components/support/PrintStyles.tsx`**

CSS-in-JS component for print-friendly output:

| Feature | Implementation |
|---------|----------------|
| Page Layout | A4 landscape, 1cm margins |
| Hidden Elements | Nav, sidebar, buttons, tooltips |
| Table Styling | Borders, compact font, avoid page breaks |
| Colour Preservation | Force print colours for health indicators |
| Charts | Avoid page breaks, consistent sizing |
| Grid Layout | Maintain 2-column layout for panels |

**Print Classes:**
- `.print:hidden` - Hide elements when printing
- `.print:block` - Show elements only when printing
- `@media print` - All print-specific styles

### 5. Page Updates

**`src/app/(dashboard)/support/page.tsx`**

Updated with export and print functionality:

**New Features:**
- Export dropdown menu with Excel and Print options
- Refresh button with last-refreshed timestamp
- Print-friendly styles via `<PrintStyles />` component
- Loading states during export

**UI Components:**
- `DropdownMenu` for export options
- `Button` with icons for actions
- Local storage persistence for refresh timestamp

### 6. Vercel Cron Configuration

**`vercel.json`**

Cron job schedules for automated tasks:

| Endpoint | Schedule | Description |
|----------|----------|-------------|
| `/api/cron/support-health-report` | Monday 8:00 AM | Weekly support health email |
| `/api/cron/cse-emails?type=monday` | Monday 7:00 AM | CSE weekly briefing |
| `/api/cron/cse-emails?type=wednesday` | Wednesday 7:00 AM | CSE mid-week update |
| `/api/cron/cse-emails?type=friday` | Friday 7:00 AM | CSE end-of-week summary |
| `/api/cron/health-snapshot` | Daily 6:00 AM | Client health snapshots |
| `/api/cron/aged-accounts-snapshot` | Daily 5:00 AM | Aging accounts snapshots |
| `/api/cron/compliance-snapshot` | Daily 4:00 AM | Compliance snapshots |

## Export Index Updates

**`src/emails/templates/index.ts`**
- Added `SupportHealthReport` export

**`src/components/support/index.ts`**
- Added `PrintStyles` export

## Testing

### Manual Testing Steps

1. **Excel Export:**
   - Navigate to `/support` page
   - Click "Export" dropdown
   - Select "Export to Excel"
   - Verify workbook downloads with multiple sheets
   - Check formatting and data accuracy

2. **Print:**
   - Navigate to `/support` page
   - Click "Export" dropdown
   - Select "Print Report"
   - Verify print preview shows clean layout
   - Confirm navigation/buttons are hidden

3. **Email Preview:**
   - Access email preview at `/api/emails/preview?template=SupportHealthReport`
   - Verify branding and layout
   - Check responsive design

4. **Cron Endpoint:**
   - Test locally: `GET /api/cron/support-health-report`
   - Verify email sends successfully
   - Check `email_logs` table for record

### Verified Behaviour

- ✅ TypeScript compilation passes
- ✅ Excel export generates valid XLSX file
- ✅ Print styles hide navigation correctly
- ✅ Email template renders with ChaSen branding
- ✅ Cron endpoint returns success response

## Dependencies

| Package | Purpose |
|---------|---------|
| `xlsx` | Excel file generation |
| `resend` | Email delivery |
| `@react-email/components` | Email templating |
| `@react-email/render` | Email HTML rendering |

## Environment Variables

Required for email functionality:
- `RESEND_API_KEY` - Resend API key for sending emails
- `CRON_SECRET` - Secret for protecting cron endpoints in production

## Future Enhancements

Potential improvements for Phase 5:
- PDF export option
- Custom report scheduling (user-configurable)
- Email subscription management
- Historical trend charts in email
- Slack/Teams integration for alerts
