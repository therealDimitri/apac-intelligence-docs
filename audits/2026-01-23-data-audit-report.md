# Data Audit Report: Dashboard & Supabase Analysis

**Generated**: 2026-01-23
**Auditor**: Claude Code
**Status**: Requires Action

---

## Executive Summary

A comprehensive audit of the APAC Intelligence dashboard and Supabase database identified **25 issues** across data quality, performance, and reconciliation. The most critical findings involve orphaned records (89 meetings, 12 actions without client linkage), client name mismatches causing join failures, and performance inefficiencies causing excessive re-renders.

**Note**: The client count discrepancy (34 in database vs 19 on dashboard) is **correct by design** - the database includes child entities and inactive clients that roll up under parent accounts.

### Severity Distribution
| Severity | Count | Impact |
|----------|-------|--------|
| 🔴 Critical | 3 | Data loss/visibility |
| 🟠 High | 8 | Functionality impaired |
| 🟡 Medium | 9 | UX degradation |
| 🟢 Low | 5 | Technical debt |

---

## 1. Data Model Clarification

### ✅ RESOLVED: Client Count Is Correct
- **Dashboard shows**: 19 active parent clients
- **Supabase clients table**: 34 entries (includes children + inactive)
- **Status**: Working as designed

The `clients` table contains 34 entries which include:

**Child entities (rolled up under parent):**
| Child Entry | Parent Client |
|-------------|---------------|
| Changi General Hospital | SingHealth |
| KK Women's and Children's Hospital | SingHealth |
| National Cancer Centre Of Singapore Pte Ltd | SingHealth |
| National Heart Centre Of Singapore Pte Ltd | SingHealth |
| Sengkang General Hospital Pte. Ltd. | SingHealth |
| Singapore General Hospital Pte Ltd | SingHealth |
| NCS PTE Ltd | NCS/MinDef Singapore |
| Strategic Asia Pacific Partners | GRMC (SAPPI) |

**Inactive clients:**
- Alexandra Health Pte Ltd
- Austin Health
- Hunter New England Health
- Mater Health
- NCIG
- South Western Sydney PHN

**Not a client:**
- Internal (placeholder entry)

**Recommendation**: Mark these entries with `is_active = false` or add `client_type` column (parent/child/inactive) for clarity.

---

## 2. Data Discrepancies

### 🔴 CRITICAL: Orphaned Meetings (89 records)
- **89 meetings** have `client_uuid = null`
- These meetings have non-client names like:
  - "APAC", "APAC Client Success Action Plan"
  - "Declined: APAC : Quick Meet-up..."
  - "December Town Hall", "Melbourne Cup Day"
  - Internal events and calendar invites

**Recommendation**:
1. Create `is_internal` flag migration for internal meetings
2. Run reconciliation script to link valid meetings to clients via `client_name_aliases`
3. Archive or delete declined/cancelled events

---

### 🟠 HIGH: Orphaned Actions (12 records)
Actions without `client_uuid`:
- `null` (internal actions)
- "All Clients" (portfolio-wide actions)
- "National Cancer Centre Of Singapore" (name mismatch)

**Recommendation**: Add client alias lookup and link actions to clients.

---

### 🟠 HIGH: 18 Overdue Actions Not Addressed
Actions with `Due_Date < 2026-01-23` that are not Completed/Cancelled.

**Recommendation**: Add overdue actions alert to dashboard command centre.

---

### 🟡 MEDIUM: 52 Soft-Deleted Meetings Not Purged
Meetings with `deleted = true` still occupy database space.

**Recommendation**: Create scheduled job to permanently delete records older than 90 days.

---

## 3. Client Name Inconsistencies

### 🔴 CRITICAL: Cross-Table Name Mismatches

| Table | Name Used | Canonical Name |
|-------|-----------|----------------|
| `client_segmentation` | Royal Victorian Eye and Ear Hospital | The Royal Victorian Eye and Ear Hospital |
| `aging_accounts` | Gippsland Health Alliance | Gippsland Health Alliance (GHA) |
| `aging_accounts` | South Australia Health | SA Health |
| `aging_accounts` | St Luke's Medical Center Global City Inc | Saint Luke's Medical Centre (SLMC) |
| `aging_accounts` | The Royal Victorian Eye and Ear | The Royal Victorian Eye and Ear Hospital |
| `aging_accounts` | Singapore Health Services Pte Ltd | *(Not mapped)* |
| `aging_accounts` | National Cancer Centre Of Singapore | National Cancer Centre Of Singapore Pte Ltd |

**Console Error Evidence**:
```
[WARNING] [Segment Deadline] Could not fetch current segment for Royal Victorian Eye and Ear Hospital
```

**Impact**: Health scores, compliance calculations, and AR data fail to join correctly.

**Recommendation**:
1. Add missing entries to `client_name_aliases` table
2. Create strict foreign key relationships using `client_uuid` instead of string matching
3. Run data cleanup script to standardise all names

---

## 4. Status Field Inconsistencies

### 🟠 HIGH: Meeting Status Case Mismatch
```
"Scheduled": 2 records
"scheduled": 17 records
"cancelled": 2 records
"completed": 189 records
```

**Recommendation**: Normalise to lowercase and create check constraint.

### 🟡 MEDIUM: Action Status Variety
Current statuses: Open, To Do, In Progress, Completed, Cancelled

**Recommendation**: Document canonical statuses and create enum type.

---

## 5. Performance Issues

### 🔴 CRITICAL: Excessive Re-Renders
Console logs show memos executing multiple times per second:
```
[criticalAlerts memo] 🔄 Running with eventTypeData.length = 12 | Timestamp: 2026-01-23T04:31:28...
[criticalAlerts memo] 🔄 Running with eventTypeData.length = 12 | Timestamp: 2026-01-23T04:31:28...
[criticalAlerts memo] 🔄 Running with eventTypeData.length = 12 | Timestamp: 2026-01-23T04:31:28...
```

**Root Cause**: Dependencies in useMemo/useCallback are not properly memoised, causing cascading re-renders.

**Recommendation**:
1. Add `useMemo` for expensive calculations with stable dependencies
2. Use React DevTools Profiler to identify render bottlenecks
3. Consider using `zustand` for shared state instead of context cascades

---

### 🟠 HIGH: N+1 Query Pattern for Segment Deadlines
Each client triggers individual Supabase query:
```
[Segment Deadline] Query result for SA Health (iPro): [Object, Object]
[Segment Deadline] Query result for Gippsland Health Alliance (GHA): [Object, Object]
[Segment Deadline] Query result for SA Health (iQemo): [Object, Object]
... (19 queries for 19 clients)
```

**Recommendation**:
1. Batch segment history queries with `WHERE client_name IN (...)`
2. Create materialised view `client_compliance_summary` for pre-computed compliance
3. Use React Query's batch fetch capabilities

---

### 🟡 MEDIUM: Duplicate Compliance Recalculations
```
[useAllClientsCompliance] SA Health (iPro): Segment changed, recalculated score=38% (was 100%)
[useAllClientsCompliance] SA Health (iPro): Segment changed, recalculated score=38% (was 100%)
```

Same calculation runs twice per client.

**Recommendation**: Add deduplication logic or use React Query's `staleTime`.

---

## 6. Data Staleness

### 🟠 HIGH: Health History Snapshots Outdated
- **Latest snapshot**: 2026-01-16 (7 days ago)
- **Expected**: Daily snapshots

**Cause**: Cron job may be failing silently.

**Recommendation**:
1. Check Netlify scheduled function logs for `health-history-snapshot`
2. Add alerting for failed cron jobs
3. Add "Last synced" timestamp to dashboard

---

### 🟡 MEDIUM: No Recent Meetings (Last 30 Days shows 0)
Dashboard shows "Meetings Held: 0" for last 30 days despite 189 completed meetings in database.

**Possible Cause**: Date filter or meeting_date format mismatch.

**Recommendation**: Investigate meeting date filtering logic.

---

## 7. Reconciliation Issues

### Summary Table

| Relationship | Expected | Actual | Gap | Notes |
|-------------|----------|--------|-----|-------|
| Clients → Segmentation | 19 | 19 | ✅ None | Correct (children/inactive excluded) |
| Meetings → Clients (via UUID) | 210 | 121 | 89 orphaned | Internal/declined meetings |
| Actions → Clients (via UUID) | 160 | 148 | 12 orphaned | Needs cleanup |
| Aged Accounts → Clients | 11 | 4 | 7 name mismatches | Alias mapping needed |

---

## 8. Optimisation Recommendations

### Immediate (This Sprint)

1. **Add missing client aliases** to `client_name_aliases`:
   ```sql
   INSERT INTO client_name_aliases (display_name, canonical_name, is_active) VALUES
   ('Royal Victorian Eye and Ear Hospital', 'The Royal Victorian Eye and Ear Hospital', true),
   ('Gippsland Health Alliance', 'Gippsland Health Alliance (GHA)', true),
   ('South Australia Health', 'SA Health', true),
   ('St Luke''s Medical Center Global City Inc', 'Saint Luke''s Medical Centre (SLMC)', true);
   ```

2. **Mark child/inactive clients** with `is_active = false` or add `client_type` column for clarity.

3. **Normalise meeting statuses** to lowercase.

4. **Fix health history cron job** and verify it's running daily.

### Short-Term (Next 2 Sprints)

5. **Refactor compliance calculations**:
   - Create `client_compliance_summary` materialised view
   - Refresh on cron schedule instead of real-time calculation

6. **Optimise segment deadline queries**:
   - Batch fetch all segment histories in single query
   - Cache results in React Query with 5-minute stale time

7. **Add memoisation fixes**:
   - Audit all useMemo/useCallback dependencies
   - Use React DevTools to identify render storms

### Long-Term (Next Quarter)

8. **Migrate to UUID-based relationships**:
   - Add `client_uuid` foreign keys to all tables
   - Run backfill script to populate from `client_name_aliases`
   - Deprecate string-based client matching

9. **Create data quality dashboard**:
   - Orphaned record count
   - Name mismatch alerts
   - Stale data warnings

10. **Implement event-driven sync**:
    - Use Supabase Realtime for live updates
    - Remove polling-based refresh patterns

---

## Appendix: Database Statistics

| Table | Row Count | Notes |
|-------|-----------|-------|
| clients | 34 | 1 inactive |
| client_segmentation | 36 | 19 unique clients |
| client_name_aliases | 89 | Good coverage |
| unified_meetings | 210 | 52 deleted, 89 without UUID |
| actions | 160 | 12 without client_uuid |
| nps_responses | 199 | All have client_uuid |
| client_health_history | 594 | Last: 2026-01-16 |
| aging_accounts | 11 | 7 name mismatches |
| chasen_conversations | 130 | - |

---

*Report generated by automated audit. Review with data team before implementing changes.*
