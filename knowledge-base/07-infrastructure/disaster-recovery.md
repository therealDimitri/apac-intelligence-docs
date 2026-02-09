# Disaster Recovery Procedures

Recovery procedures for when data syncs break or services become unavailable.

## Detection Methods

| Method | What It Detects | How |
|--------|----------------|-----|
| **StalenessBar** (UI) | Stale data sources | Amber banner on dashboard when any source exceeds its threshold |
| **staleness-check cron** | Same, proactively | Runs every 2 hours, sends webhook alerts for stale sources |
| **sync-logger** | Failed syncs | Logs to `sync_history`; `completeSyncLog` auto-alerts on failure via webhook |
| **/api/health** | DB connectivity + overdue crons | Returns `degraded` status if any cron is overdue or any sync has failed |

---

## Sync Failure Scenarios & Recovery

### 1. BURC / Aged Accounts (`aged_accounts`, `burc_file_watcher`)

**What happens if it breaks**: Aged accounts data goes stale. Health scores and compliance percentages show outdated values. StalenessBar triggers after 2-4 hours.

**Common causes**:
- OneDrive sync failure (MDM/credential issues)
- BURC Excel file moved or renamed
- OneDrive Files On-Demand not downloading the file

**Recovery**:
1. Check OneDrive is syncing: `ls ~/Library/CloudStorage/OneDrive-Altera*/`
2. Verify BURC file path: check `src/lib/onedrive-paths.ts` resolver output
3. If OneDrive is broken, see [onedrive.md](onedrive.md) for MDM troubleshooting
4. Re-trigger sync:
   ```bash
   curl -X GET http://localhost:3001/api/cron/burc-file-watcher \
     -H "Authorization: Bearer $CRON_SECRET"
   ```
5. Verify: check `sync_history` table for new `burc_file_watcher` entry with status `success`

### 2. Health Snapshots (`health_snapshot`)

**What happens if it breaks**: Sparkline trend data stops updating. Historical health scores become stale. Dashboard still shows current calculated scores.

**Common causes**:
- `client_health_summary` view has no data (upstream dependency)
- Database connectivity issue

**Recovery**:
1. Check the health summary view has data:
   ```sql
   SELECT COUNT(*) FROM client_health_summary;
   ```
2. Re-trigger:
   ```bash
   curl -X GET http://localhost:3001/api/cron/health-snapshot \
     -H "Authorization: Bearer $CRON_SECRET"
   ```

### 3. Activity Register / Excel Sync (`excel_sync`)

**What happens if it breaks**: Segmentation event completions stop updating. Activity calendar shows stale data.

**Common causes**:
- Excel file not found on local disk
- File format changed (new columns, renamed sheets)
- Event type codes in Excel don't match `segmentation_event_types` table

**Recovery**:
1. Verify Excel file exists at the default path (check `getDefaultExcelPath()` in `activity-register-parser.ts`)
2. Check for unknown event codes in recent sync errors:
   ```sql
   SELECT error_message FROM sync_history
   WHERE source = 'excel_sync' ORDER BY started_at DESC LIMIT 5;
   ```
3. Re-trigger:
   ```bash
   curl -X POST http://localhost:3001/api/cron/excel-sync \
     -H "Authorization: Bearer $CRON_SECRET"
   ```

### 4. News Sync (`news_sync`, `news_fetch_rss`, `client_news_sync`)

**What happens if it breaks**: News feed stops updating. Client news associations go stale.

**Common causes**:
- RSS feed URLs changed or down
- API rate limits hit
- Network connectivity

**Recovery**:
1. Check RSS feed accessibility manually
2. Re-trigger in order:
   ```bash
   # Fetch new articles
   curl -X GET http://localhost:3001/api/cron/news-fetch \
     -H "Authorization: Bearer $CRON_SECRET"
   # Score articles
   curl -X GET http://localhost:3001/api/cron/news-score \
     -H "Authorization: Bearer $CRON_SECRET"
   # Associate with clients
   curl -X GET http://localhost:3001/api/cron/client-news-sync \
     -H "Authorization: Bearer $CRON_SECRET"
   ```

### 5. MS Graph Role Sync (`ms_graph_sync`)

**What happens if it breaks**: User roles stop syncing from Azure AD. New users won't get correct permissions.

**Common causes**:
- Azure AD credentials expired (`AZURE_AD_CLIENT_SECRET`)
- Tenant ID changed
- API permission revoked

**Recovery**:
1. Check Azure AD credentials in `.env.local`:
   - `AZURE_AD_TENANT_ID`
   - `AZURE_AD_CLIENT_ID`
   - `AZURE_AD_CLIENT_SECRET`
2. Test token acquisition manually
3. Re-trigger:
   ```bash
   curl -X GET http://localhost:3001/api/cron/ms-graph-sync \
     -H "Authorization: Bearer $CRON_SECRET"
   ```

### 6. Compliance Snapshot (`compliance_snapshot`)

**What happens if it breaks**: Compliance trend data stops updating. Daily reconciliation alerts stop.

**Common causes**:
- Invoice Tracker API unavailable
- `NEXT_PUBLIC_APP_URL` misconfigured (defaults to localhost:3000)

**Recovery**:
1. Check Invoice Tracker API is responding:
   ```bash
   curl http://localhost:3001/api/invoice-tracker/aging-by-cse
   ```
2. Re-trigger:
   ```bash
   curl -X POST http://localhost:3001/api/cron/compliance-snapshot \
     -H "Authorization: Bearer $CRON_SECRET"
   ```

---

## Manual Re-sync

Any cron can be triggered manually via curl. The general pattern:

```bash
# With cron secret
curl -X GET http://localhost:3001/api/cron/<route-name> \
  -H "Authorization: Bearer $CRON_SECRET"

# Without cron secret (local dev)
curl -X GET http://localhost:3001/api/cron/<route-name>
```

Check results in `sync_history`:
```sql
SELECT source, status, records_processed, error_message, started_at
FROM sync_history
ORDER BY started_at DESC
LIMIT 20;
```

---

## Database Recovery

### Supabase Point-in-Time Recovery
- Supabase Pro plan includes point-in-time recovery (PITR)
- Access via Supabase Dashboard → Project Settings → Database → Backups
- Can restore to any point in the last 7 days

### OneDrive Bundle Restore
For full repo + git history restoration (e.g. after machine re-image):

```bash
# From OneDrive backup
bash ~/Library/CloudStorage/OneDrive-*/Documents/GitHub-Backups/restore.sh

# Then copy env
cp ~/Library/CloudStorage/OneDrive-*/Documents/GitHub-Backups/.env.local \
   ~/GitHub/apac-intelligence-v2/
```

See the main MEMORY.md for detailed fresh clone workflow.

---

## Escalation

| Issue | Self-Resolve | Escalate to IT |
|-------|-------------|----------------|
| Sync cron failed | Re-trigger manually | - |
| Excel file missing | Check local disk path | - |
| OneDrive not syncing | Unlink + relink OneDrive | If persists: MDM re-enrolment needed |
| Azure AD token expired | Rotate client secret in Azure portal | If no portal access |
| Database unreachable | Check Supabase status page | If sustained outage |
| Netlify deploy failed | Check build logs, fix + push | - |
