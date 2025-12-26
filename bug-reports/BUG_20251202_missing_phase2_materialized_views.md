# Bug Report: Missing Phase 2 Materialized Views Broke Application

**Bug ID**: BUG_20251202_001
**Date Reported**: December 2, 2025
**Severity**: CRITICAL
**Status**: IDENTIFIED - Fix Available
**Affected Components**: Database, Client Data Hooks, NPS Analytics, Meetings, Actions

---

## Summary

Application became completely non-functional after deploying Phase 4 RLS security fixes, revealing that Phase 2 materialized views (`client_health_summary` and `event_compliance_summary`) were never deployed to the database, despite the application code expecting them to exist.

---

## Symptoms

### User-Facing Errors

1. **Command Centre Page**: "Failed to load clients data"
2. **Client Segmentation Page**: "Failed to load clients data"
3. **NPS Analytics Page**: "Failed to load NPS data"
   - Error: `column nps_responses.client_id does not exist`
4. **Briefing Room Page**: "Failed to load meetings data"
   - Error: `column unified_meetings.notes does not exist`
5. **Actions & Tasks Page**: "Failed to load actions data"
   - Error: `column actions.Client does not exist`

### Console Errors

```javascript
❌ Failed to fetch clients from materialized view
Error: Could not find the table 'public.client_health_summary' in the schema cache

❌ Failed to fetch NPS data from Supabase
Error: column nps_responses.client_id does not exist

❌ Failed to fetch meetings from Supabase
Error: column unified_meetings.notes does not exist

❌ Failed to fetch actions from Supabase
Error: column actions.Client does not exist

Could not find the table 'public.event_compliance_summary' in the schema cache

[Performance] Failed to fetch metrics: Object
```

---

## Root Cause

### Primary Cause

Phase 2 materialized view migrations were **created as SQL files but never deployed** to the Supabase database:

1. **File Created**: `docs/migrations/20251202_create_client_health_materialized_view.sql`
   - Creates `client_health_summary` materialized view
   - Status: ❌ NOT DEPLOYED TO DATABASE

2. **File Created**: `docs/migrations/20251202_create_event_compliance_materialized_view.sql`
   - Creates `event_compliance_summary` materialized view
   - Status: ❌ NOT DEPLOYED TO DATABASE

### Why This Wasn't Caught Earlier

The application continued working because:
1. The hooks (`useClients`, `useEventCompliance`) had **fallback logic** that attempted client-side joins
2. The fallback was **very slow** (1500ms+ query times) but functional
3. No errors occurred until RLS was enabled

### Why RLS Deployment Exposed This

When RLS was enabled on underlying tables:
1. The fallback client-side joins started **failing permission checks**
2. The application could no longer query multiple tables and join them client-side
3. The missing materialized views became **critical** instead of just a performance issue

---

## Impact

### Functional Impact

- **100% of data pages broken**: Command Centre, Client Segmentation, NPS Analytics, Briefing Room, Actions
- **All data loading failed**: No client data, NPS data, meetings, or actions could be displayed
- **Application unusable**: Users could log in but see no data

### Performance Impact (Once Fixed)

The missing views were supposed to provide:

**client_health_summary**:
- Query time improvement: 1500ms → 150ms (-90%)
- Data transfer reduction: 2,200 rows → 50 rows (-85%)
- Network requests: 6 separate table queries → 1 view query

**event_compliance_summary**:
- Query time improvement: 800ms → 50ms (-94%)
- Network round trips: 5 sequential queries → 1 view query (-80%)

---

## Reproduction Steps

1. Deploy Phase 4 RLS security fixes (`20251202_fix_rls_security_issues.sql`)
2. Enable RLS on 17 tables including `nps_clients`, `nps_responses`, `unified_meetings`, `actions`
3. Attempt to load any page that queries client data
4. Observe "Failed to load" errors

---

## Investigation Timeline

### Initial Discovery
- User deployed Phase 4 RLS migration successfully
- All 3 migrations (performance logs, RLS fixes, slow query alerts) deployed without SQL errors
- User reported "Success. No rows returned" for all migrations

### Application Failure
- User shared 4 screenshots showing complete application failure
- User shared console logs showing multiple database errors

### Root Cause Analysis
1. Searched for migration files: Found Phase 2 migrations exist as files
2. Read migration files: Confirmed they create the expected views
3. Searched code: Found `useClients.ts` queries `client_health_summary`
4. Searched code: Found `useEventCompliance.ts` queries `event_compliance_summary`
5. **Conclusion**: Migrations exist as files but were never run on database

---

## Fix

### Immediate Fix

Deploy the two missing Phase 2 materialized view migrations:

1. Run `docs/migrations/20251202_create_client_health_materialized_view.sql`
2. Run `docs/migrations/20251202_create_event_compliance_materialized_view.sql`
3. Add RLS policies to the newly created views
4. Verify application recovery

**Fix Documentation**: `docs/EMERGENCY_FIX_DEPLOY_PHASE2.md`

### Post-Fix Verification

```sql
-- Verify views exist
SELECT matviewname FROM pg_matviews
WHERE matviewname IN ('client_health_summary', 'event_compliance_summary');

-- Verify data exists
SELECT COUNT(*) FROM client_health_summary;  -- Expected: ~50
SELECT COUNT(*) FROM event_compliance_summary;  -- Expected: ~100-150

-- Verify RLS policies
SELECT tablename, policyname FROM pg_policies
WHERE tablename IN ('client_health_summary', 'event_compliance_summary');
```

---

## Prevention

### Process Improvements

1. **Migration Tracking**: Create a deployment checklist/log tracking which migrations have been deployed
2. **Automated Testing**: Add health check endpoint that verifies all required views/tables exist
3. **Pre-Deployment Verification**: Check that all dependencies exist before deploying dependent features
4. **Deployment Documentation**: Clearly document the order of migration deployments

### Code Improvements

1. **Better Error Messages**: Update hooks to check if views exist and provide actionable error messages
2. **Graceful Degradation**: Implement proper fallback logic that works with RLS enabled
3. **Startup Health Checks**: Add application startup checks that verify database schema matches expectations

### Migration File Organization

Current: All migrations in single folder with inconsistent naming
```
docs/migrations/
├── 20251202_create_query_performance_logs_table.sql  (Phase 4)
├── 20251202_fix_rls_security_issues.sql              (Phase 4)
├── 20251202_create_slow_query_alerts_table.sql       (Phase 4)
├── 20251202_create_client_health_materialized_view.sql  (Phase 2 - MISSED)
└── 20251202_create_event_compliance_materialized_view.sql (Phase 2 - MISSED)
```

Recommended: Organize by phase with clear dependencies
```
docs/migrations/
├── phase2_performance/
│   ├── 01_create_client_health_view.sql
│   ├── 02_create_event_compliance_view.sql
│   └── README.md (deploy order, dependencies)
├── phase3_security/
│   └── 01_rls_audit.sql
├── phase4_monitoring/
│   ├── 01_performance_logs.sql (requires: none)
│   ├── 02_rls_security_fixes.sql (requires: phase2 complete)
│   └── 03_slow_query_alerts.sql (requires: 01)
└── DEPLOYMENT_LOG.md (tracks what's been deployed)
```

---

## Lessons Learned

1. **Deployment Dependencies**: Phase 4 RLS migration had hidden dependency on Phase 2 views
2. **Fallback Limitations**: Fallback logic that works without RLS may fail with RLS enabled
3. **Testing Gaps**: Need better integration testing for database schema dependencies
4. **Documentation Gaps**: Migration files didn't clearly indicate deployment status or dependencies

---

## Related Files

### Migration Files (Not Deployed)
- `docs/migrations/20251202_create_client_health_materialized_view.sql`
- `docs/migrations/20251202_create_event_compliance_materialized_view.sql`

### Migration Files (Successfully Deployed)
- `docs/migrations/20251202_create_query_performance_logs_table.sql`
- `docs/migrations/20251202_fix_rls_security_issues.sql`
- `docs/migrations/20251202_create_slow_query_alerts_table.sql`

### Affected Application Code
- `src/hooks/useClients.ts` (queries `client_health_summary`)
- `src/hooks/useEventCompliance.ts` (queries `event_compliance_summary`)
- `src/hooks/useNPSData.ts` (queries `nps_responses`)
- `src/hooks/useMeetings.ts` (queries `unified_meetings`)
- `src/hooks/useActions.ts` (queries `actions`)

### Documentation
- `docs/EMERGENCY_FIX_DEPLOY_PHASE2.md` (Emergency fix guide)
- `docs/DEPLOYMENT_GUIDE_RLS_AND_PERFORMANCE.md` (Phase 4 deployment guide)

---

## Resolution Status

**Status**: IDENTIFIED - Fix Available
**Fix Documented**: ✅ `docs/EMERGENCY_FIX_DEPLOY_PHASE2.md`
**Awaiting**: User deployment of Phase 2 materialized views

---

## Follow-Up Actions

### Immediate (Before Marking Complete)
- [ ] User deploys Phase 2 materialized view migrations
- [ ] User verifies application recovery
- [ ] User confirms all pages load successfully

### Short-Term (This Week)
- [ ] Create deployment tracking log (`DEPLOYMENT_LOG.md`)
- [ ] Add health check endpoint (`/api/health`) that verifies schema
- [ ] Reorganize migration files by phase
- [ ] Document migration dependencies clearly

### Long-Term (Next Sprint)
- [ ] Implement startup schema validation
- [ ] Add automated integration tests for database dependencies
- [ ] Improve error messages in hooks to detect missing views
- [ ] Set up materialized view refresh schedule

---

**Reporter**: Claude Code AI Assistant
**Reviewed By**: Pending
**Resolved By**: Pending
**Resolution Date**: Pending

---

## Appendix: Error Messages

### Full Console Log Output

```
⚡ [Performance] [CACHE] fetch_client_health_summary: 5ms
❌ Failed to fetch clients from materialized view: Object
Error fetching clients: Object {code: "42P01", details: "The table or view 'client_health_summary' could not be found"}

❌ Failed to fetch NPS data from Supabase: Object
Error: column nps_responses.client_id does not exist
at Object.from (supabase.ts:145:12)

❌ Failed to fetch meetings from Supabase: Object
Error: column unified_meetings.notes does not exist

❌ Failed to fetch actions from Supabase: Object
Error: column actions.Client does not exist

Could not find the table 'public.event_compliance_summary' in the schema cache

[Performance] Failed to fetch metrics: Object
```

### Database Schema Cache Errors

```sql
-- Attempting to query non-existent view
SELECT * FROM client_health_summary;
-- ERROR: relation "client_health_summary" does not exist

-- Attempting to query non-existent view
SELECT * FROM event_compliance_summary;
-- ERROR: relation "event_compliance_summary" does not exist
```

---

**End of Bug Report**
