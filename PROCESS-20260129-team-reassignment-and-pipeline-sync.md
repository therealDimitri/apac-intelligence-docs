# Team Reassignment and Pipeline Sync

**Date:** 29 January 2026
**Type:** Data Sync Process

## Summary

Completed two data synchronisation tasks:
1. Team reassignment: Updated all database tables to replace Boon/Gil/Open Role with Nikki Wei
2. Pipeline sync: Imported 64 opportunities from 2026 APAC Performance Excel to database

## Task 1: Team Reassignment

### Background
BoonTeck Lim and Gilbert So left the company. Their Asia + Guam clients were temporarily assigned to Nikki Wei as interim CSE/CAM.

### Tables Updated

| Table | Records | Change |
|-------|---------|--------|
| `client_segmentation` | 4 | Open Role → Nikki Wei |
| `nps_clients` | 5 | Open Role CSE → Nikki Wei |
| `aging_accounts` | 5 | Open Role CSE → Nikki Wei |
| `pipeline_opportunities` | 21 | Open Role CSE/CAM → Nikki Wei |
| `email_recipient_config` | 2 | Boon/Gil → is_active=false |

### Verification
Audit script (`audit_team_assignments.js`) confirmed all tables clean after sync.

## Task 2: Pipeline Sync from Excel

### Source File
`/APAC Leadership Team - General/Performance/Financials/BURC/2026/2026 APAC Performance.xlsx`

Sheet: "Dial 2 Risk Profile Summary"

### Mapping

| Excel Column | Database Column |
|--------------|-----------------|
| Column 0 (Deal Name) | `opportunity_name` |
| Column 1 (F/Cast Category) | `forecast_category` |
| Column 2 (Closure Date) | `close_date` |
| Column 3 (Oracle Agreement #) | `oracle_quote_number` |
| Column 17 (Bookings ACV) | `total_acv` |

Account names were derived from opportunity name patterns:
- "SA Health *" → SA Health
- "GHA *" → Gold Health Alliance
- "GRMC *" → Strategic Asia Pacific Partners, Incorporated
- etc.

### Results

| Metric | Value |
|--------|-------|
| Opportunities synced | 64 |
| Updated existing | 2 |
| Inserted new | 62 |
| Errors | 0 |
| Total pipeline ACV | $36,878,936 |

### CSE Distribution Post-Sync

| CSE | Opportunities |
|-----|---------------|
| Nikki Wei | 84 |
| Tracey Bland | 36 |
| Laura Messing | 19 |
| John Salisbury | 11 |

## Scripts Created

### `audit_team_assignments.js`
Utility script to audit all CSE assignment tables for specific names (Boon/Gil/Open Role).
Useful for future team changes.

## Notes

- Excel values in "Bookings ACV" column were in millions (0.93 = $930,000)
- Summary rows (Green/Yellow/Red headers, totals) were skipped during import
- Existing CSE/CAM assignments were preserved during pipeline sync
- New opportunities default to Nikki Wei as interim CSE/CAM
