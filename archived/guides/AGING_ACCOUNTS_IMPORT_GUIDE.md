# Aging Accounts Import & Automation Guide

Complete guide for importing weekly aging accounts data and keeping it up to date.

## Table of Contents

1. [Overview](#overview)
2. [One-Time Setup](#one-time-setup)
3. [Import Methods](#import-methods)
4. [Automation Options](#automation-options)
5. [Troubleshooting](#troubleshooting)
6. [Database Schema](#database-schema)

---

## Overview

Your aging accounts system now stores data in a database instead of reading from Excel files directly. This provides:

- ✅ **Faster performance** - Database queries are much faster than parsing Excel files
- ✅ **Historical tracking** - Keep all past weeks' data for trend analysis
- ✅ **Automated imports** - Set it and forget it
- ✅ **Better reliability** - No file corruption or access issues
- ✅ **Compliance dashboard** - Real-time aging compliance metrics

### How It Works

```
Weekly Excel File → Import Script → Supabase Database → App/Dashboard
    (manual or automated)
```

---

## One-Time Setup

### Step 1: Apply Database Migration

First, create the database tables:

```bash
node scripts/apply-migration-as-single-block.mjs docs/migrations/20251205_aging_accounts_database.sql
```

This creates:

- `aging_accounts` table (main data)
- `aging_accounts_history` table (historical snapshots)
- `aging_compliance_summary` materialized view (pre-calculated compliance metrics)
- Helper functions and indexes

### Step 2: Verify Setup

Check that tables were created:

```bash
node -e "
const { createClient } = require('@supabase/supabase-js');
const supabase = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);
supabase.from('aging_accounts').select('count').single()
  .then(({ data, error }) => {
    if (error) console.log('✅ Table exists (empty)');
    else console.log('✅ Table exists with data');
  });
"
```

### Step 3: Import Initial Data

Run your first import with the current Excel file:

```bash
node scripts/import-aging-accounts.mjs data/APAC_Intl_10Nov2025.xlsx
```

You should see output like:

```
╔═══════════════════════════════════════════════════╗
║   Aging Accounts Import Script                   ║
╚═══════════════════════════════════════════════════╝

📄 Reading Excel file: APAC_Intl_10Nov2025.xlsx
✓ Found 150 rows in Pivot sheet
✓ Week ending date: 2025-11-10
✓ Parsed 125 aging account records

📊 Summary by CSE:
   BoonTeck Lim: 45 clients, $2,500,000.00
   Laura Vane: 38 clients, $1,800,000.00
   Jonathan Salisbury: 42 clients, $2,200,000.00

💾 Importing 125 records to database...

✓ Batch 1: Imported 125 records
✓ Created historical snapshot for 3 CSEs
✓ Compliance summary refreshed

✅ All done! Check your database for the new data.
```

---

## Import Methods

### Option 1: Manual Command Line (Recommended for Testing)

Run whenever you receive a new file:

```bash
# With specific file path
node scripts/import-aging-accounts.mjs data/APAC_Intl_17Nov2025.xlsx

# Auto-detect latest file in data/ folder
node scripts/import-aging-accounts.mjs
```

**When to use:**

- Testing new file formats
- One-off imports
- Troubleshooting issues

---

### Option 2: Drag & Drop to Folder (Simplest)

1. Save your weekly Excel file to `data/` folder
2. Commit and push to GitHub:
   ```bash
   git add data/APAC_Intl_17Nov2025.xlsx
   git commit -m "Weekly aging accounts update"
   git push
   ```
3. GitHub Actions automatically imports the data!

**When to use:**

- Weekly routine updates
- Multiple team members updating
- Want git history of file changes

**Pros:**

- ✅ Automatic - no scripts to run
- ✅ Git tracks file history
- ✅ Works from any computer

**Cons:**

- ⚠️ Requires git push access
- ⚠️ Large files bloat repository

---

### Option 3: GitHub Actions Manual Trigger

1. Go to GitHub → Actions tab
2. Select "Import Aging Accounts Data" workflow
3. Click "Run workflow"
4. (Optional) Specify file path or use latest
5. Click green "Run workflow" button

**When to use:**

- Quick imports without local setup
- Don't want to commit Excel files to git
- Running from a different computer

**Pros:**

- ✅ No local setup needed
- ✅ Can specify exact file
- ✅ Runs on GitHub's servers

**Cons:**

- ⚠️ Must upload file to repo first
- ⚠️ Slightly slower than local

---

### Option 4: Scheduled Automation (Set It & Forget It)

Already configured! The GitHub Actions workflow runs automatically **every Monday at 9 AM UTC** (5 PM Singapore Time).

**Prerequisites:**

1. Ensure latest Excel file is in `data/` folder before Monday
2. GitHub Actions secrets are configured (see below)

**How it works:**

1. Monday 9 AM UTC: Workflow triggers
2. Finds latest `.xlsx` file in `data/` folder
3. Imports to database
4. You get a notification if it fails

**To change schedule:**

Edit `.github/workflows/import-aging-accounts.yml` cron expression:

```yaml
schedule:
  - cron: '0 9 * * 1' # Every Monday at 9 AM UTC
  # Change to:
  - cron: '0 2 * * 2' # Every Tuesday at 2 AM UTC
  # Or:
  - cron: '0 */6 * * *' # Every 6 hours
```

Use [crontab.guru](https://crontab.guru/) to help with cron syntax.

---

## Automation Options

### A. GitHub Actions (Recommended)

**Pros:**

- ✅ Free (for public repos)
- ✅ Reliable cloud execution
- ✅ Email notifications on failure
- ✅ No server maintenance

**Setup:**

1. Add GitHub Secrets (if not already added):
   - Go to GitHub repo → Settings → Secrets and variables → Actions
   - Add:
     - `NEXT_PUBLIC_SUPABASE_URL` - Your Supabase project URL
     - `SUPABASE_SERVICE_ROLE_KEY` - Your Supabase service role key

2. Enable GitHub Actions:
   - Go to Actions tab
   - Enable workflows if disabled

3. Test manual trigger:
   - Go to Actions → Import Aging Accounts Data
   - Run workflow manually to verify setup

**That's it!** Now it runs automatically every Monday.

---

### B. Local Cron Job

If you have a server or Mac that's always on:

**Mac/Linux:**

```bash
# Edit crontab
crontab -e

# Add line (runs every Monday at 9 AM)
0 9 * * 1 cd /path/to/apac-intelligence-v2 && /usr/local/bin/node scripts/import-aging-accounts.mjs >> logs/aging-import.log 2>&1
```

**Windows Task Scheduler:**

1. Open Task Scheduler
2. Create Basic Task
3. Trigger: Weekly, Monday, 9:00 AM
4. Action: Start a program
   - Program: `node`
   - Arguments: `scripts/import-aging-accounts.mjs`
   - Start in: `C:\path\to\apac-intelligence-v2`

---

### C. OneDrive/SharePoint Folder Watch

If your Excel files are in OneDrive/SharePoint, use Power Automate:

1. Create Flow in Power Automate
2. Trigger: "When a file is created or modified" in SharePoint folder
3. Condition: File extension is `.xlsx`
4. Action: HTTP POST to your import API endpoint (see Optional section below)

---

## Troubleshooting

### Import Fails: "Pivot sheet not found"

**Cause:** Excel file doesn't have a "Pivot" sheet

**Solution:**

- Verify Excel file has sheet named "Pivot" (case-sensitive)
- If your sheet has a different name, update `scripts/import-aging-accounts.mjs`:
  ```javascript
  const pivotSheet = workbook.Sheets['YourSheetName'] // Line ~168
  ```

---

###Import Succeeds But No Data Appears

**Cause:** Week ending date mismatch or RLS policies

**Solution 1 - Check database directly:**

```sql
SELECT COUNT(*), week_ending_date
FROM aging_accounts
GROUP BY week_ending_date
ORDER BY week_ending_date DESC;
```

**Solution 2 - Check RLS policies:**

```sql
-- Temporarily disable RLS to test
ALTER TABLE aging_accounts DISABLE ROW LEVEL SECURITY;
-- Try querying again
-- Re-enable after testing
ALTER TABLE aging_accounts ENABLE ROW LEVEL SECURITY;
```

---

### "SUPABASE_SERVICE_ROLE_KEY not found"

**Cause:** Environment variables not set

**Solution:**

```bash
# Check .env.local exists
cat .env.local | grep SUPABASE

# If missing, add:
echo "NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co" >> .env.local
echo "SUPABASE_SERVICE_ROLE_KEY=your-service-role-key" >> .env.local
```

---

### GitHub Actions Fails

**Common causes:**

1. **Secrets not configured**
   - Go to Settings → Secrets → Actions
   - Verify both Supabase secrets exist

2. **No Excel file in data/ folder**
   - Commit at least one `.xlsx` file to `data/` folder

3. **Permissions issue**
   - Go to Settings → Actions → General
   - Ensure "Read and write permissions" is enabled

---

### Data Looks Wrong

**Debugging steps:**

1. **Check source Excel file:**

   ```bash
   node -e "
   const XLSX = require('xlsx');
   const wb = XLSX.readFile('data/APAC_Intl_10Nov2025.xlsx');
   console.log('Sheets:', wb.SheetNames);
   const sheet = wb.Sheets['Pivot'];
   const data = XLSX.utils.sheet_to_json(sheet, { header: 1 });
   console.log('First 5 rows:', data.slice(0, 5));
   "
   ```

2. **Check import log:**
   - Look at script output for CSE names and client counts
   - Verify numbers match your expectations

3. **Query database:**
   ```sql
   -- Check a specific CSE
   SELECT * FROM aging_accounts
   WHERE cse_name = 'BoonTeck Lim'
   AND week_ending_date = '2025-11-10'
   ORDER BY total_outstanding DESC
   LIMIT 10;
   ```

---

## Database Schema

### Tables Created

#### 1. `aging_accounts`

Main table storing all aging data.

| Column                   | Type      | Description                            |
| ------------------------ | --------- | -------------------------------------- |
| `id`                     | SERIAL    | Primary key                            |
| `cse_name`               | TEXT      | CSE name (normalized)                  |
| `client_name`            | TEXT      | Original client name from Excel        |
| `client_name_normalized` | TEXT      | Mapped/standardized client name        |
| `most_recent_comment`    | TEXT      | Latest comment from aging report       |
| `current_amount`         | DECIMAL   | Not yet overdue (0 days)               |
| `days_1_to_30`           | DECIMAL   | 1-30 days overdue                      |
| `days_31_to_60`          | DECIMAL   | 31-60 days overdue                     |
| `days_61_to_90`          | DECIMAL   | 61-90 days overdue                     |
| `days_91_to_120`         | DECIMAL   | 91-120 days overdue                    |
| `days_121_to_180`        | DECIMAL   | 121-180 days overdue                   |
| `days_181_to_270`        | DECIMAL   | 181-270 days overdue                   |
| `days_271_to_365`        | DECIMAL   | 271-365 days overdue                   |
| `days_over_365`          | DECIMAL   | Over 365 days overdue                  |
| `total_outstanding`      | DECIMAL   | Total AR for this client               |
| `total_overdue`          | DECIMAL   | Calculated: sum of all overdue buckets |
| `is_inactive`            | BOOLEAN   | True for inactive clients with AR      |
| `week_ending_date`       | DATE      | Week this data represents              |
| `import_date`            | TIMESTAMP | When imported                          |

#### 2. `aging_accounts_history`

Historical snapshots for trend analysis.

| Column                   | Type      | Description            |
| ------------------------ | --------- | ---------------------- |
| `cse_name`               | TEXT      | CSE name               |
| `client_name_normalized` | TEXT      | Client name            |
| `week_ending_date`       | DATE      | Week ending date       |
| `total_outstanding`      | DECIMAL   | Total AR               |
| `total_overdue`          | DECIMAL   | Total overdue          |
| `percent_under_60_days`  | DECIMAL   | % of overdue < 60 days |
| `percent_under_90_days`  | DECIMAL   | % of overdue < 90 days |
| `snapshot_date`          | TIMESTAMP | When snapshot created  |

#### 3. `aging_compliance_summary` (Materialized View)

Pre-calculated compliance metrics per CSE per week.

**Automatically refreshed** when data changes.

### Useful Queries

```sql
-- Get latest week's data for a CSE
SELECT * FROM get_latest_aging_data('BoonTeck Lim');

-- Check compliance for latest week
SELECT * FROM aging_compliance_summary
WHERE cse_name = 'BoonTeck Lim'
ORDER BY week_ending_date DESC
LIMIT 1;

-- Find clients with > 90 days overdue
SELECT cse_name, client_name_normalized, total_overdue,
       (days_91_to_120 + days_121_to_180 + days_181_to_270 +
        days_271_to_365 + days_over_365) as over_90_days
FROM aging_accounts
WHERE week_ending_date = (SELECT MAX(week_ending_date) FROM aging_accounts)
  AND (days_91_to_120 + days_121_to_180 + days_181_to_270 +
       days_271_to_365 + days_over_365) > 0
ORDER BY over_90_days DESC;

-- Historical trend for a CSE
SELECT week_ending_date,
       total_outstanding,
       percent_under_60_days,
       percent_under_90_days,
       meets_goals
FROM aging_compliance_summary
WHERE cse_name = 'BoonTeck Lim'
ORDER BY week_ending_date DESC
LIMIT 12;  -- Last 12 weeks
```

---

## Best Practices

### Weekly Import Workflow

**Recommended routine:**

1. **Monday morning:**
   - Save latest Excel file to `data/` folder
   - Rename to include date: `APAC_Intl_17Nov2025.xlsx`

2. **Commit to git:**

   ```bash
   git add data/APAC_Intl_17Nov2025.xlsx
   git commit -m "Weekly aging accounts - Nov 17, 2025"
   git push
   ```

3. **Verify import:**
   - Check GitHub Actions tab (green checkmark = success)
   - Or check database directly

4. **View dashboard:**
   - Open app and check aging compliance metrics
   - Review any alerts or aging issues

### File Naming Convention

Use consistent naming to make automation easier:

```
data/APAC_Intl_DDMmmYYYY.xlsx

Examples:
- data/APAC_Intl_10Nov2025.xlsx  ✅ Good
- data/APAC_Intl_17Nov2025.xlsx  ✅ Good
- data/Aging Report Nov 10.xlsx   ❌ Bad (spaces, ambiguous date)
- data/aging.xlsx                 ❌ Bad (no date)
```

The script auto-extracts the date from filename, so consistent naming ensures accurate week tracking.

---

## Next Steps

1. ✅ **Set up GitHub Actions** - Add secrets and test manual trigger
2. ✅ **Import current data** - Run first import with existing Excel file
3. ✅ **Update your app** - Modify `useAgingAccounts` hook to read from database instead of file (see [Migration Guide](#migration-guide) below)
4. ✅ **Test automation** - Add a test file and verify workflow runs
5. ✅ **Monitor** - Check weekly that imports are working

---

## Migration Guide

### Updating useAgingAccounts Hook

Currently, the hook reads from the Excel file via API. Update it to read from database:

**File:** `src/hooks/useAgingAccounts.ts`

```typescript
// OLD: Reads from Excel file parser
const response = await fetch(`/api/aging-accounts?cse=${cseName}`)

// NEW: Read from database
const { data, error } = await supabase
  .from('aging_accounts')
  .select('*')
  .eq('cse_name', cseName)
  .eq(
    'week_ending_date',
    (
      await supabase
        .from('aging_accounts')
        .select('week_ending_date')
        .order('week_ending_date', { ascending: false })
        .limit(1)
        .single()
    ).data.week_ending_date
  )
```

Or better yet, use the helper function:

```typescript
const { data, error } = await supabase.rpc('get_latest_aging_data', { p_cse_name: cseName })
```

---

## Support

**Issues or questions?**

1. Check [Troubleshooting](#troubleshooting) section
2. Review import script logs
3. Query database directly to verify data
4. Create an issue in GitHub with:
   - Error message
   - Import script output
   - Excel file structure (screenshot of Pivot sheet)

---

**Last Updated:** December 5, 2025
**Version:** 1.0.0
