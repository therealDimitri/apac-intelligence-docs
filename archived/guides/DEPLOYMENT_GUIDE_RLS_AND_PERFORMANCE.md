# Deployment Guide: RLS Security Fixes & Performance Monitoring

**Date**: December 2, 2025
**Status**: Ready for deployment
**Risk Level**: Medium (enables RLS, may affect access patterns)
**Estimated Time**: 10-15 minutes

## Overview

This guide covers the deployment of two critical migrations:

1. **Performance Monitoring Infrastructure** - Enables query performance tracking
2. **RLS Security Fixes** - Fixes 27 ERROR-level security issues from Supabase linter

## Pre-Deployment Checklist

- [ ] Backup database (Supabase automatic backups are enabled)
- [ ] Review migration SQL files
- [ ] Notify team of deployment window
- [ ] Have rollback SQL ready
- [ ] Monitor application logs during deployment

## Migration Files

### 1. Performance Monitoring Table

**File**: `docs/migrations/20251202_create_query_performance_logs_table.sql`
**Purpose**: Create infrastructure for query performance monitoring
**Impact**: No impact on existing functionality (new table only)
**Execution Time**: ~30 seconds

**What it creates**:

- `query_performance_logs` table with 7 optimized indexes
- 3 helper views (recent_slow_queries, hourly_performance_summary, table_performance_summary)
- RLS policies for secure access
- Automatic cleanup function (30-day retention)

### 2. RLS Security Fixes

**File**: `docs/migrations/20251202_fix_rls_security_issues.sql`
**Purpose**: Enable RLS on 17 tables and create security policies
**Impact**: May affect access patterns (test after deployment)
**Execution Time**: ~60 seconds

**What it fixes**:

- Enables RLS on 17 tables that were exposed without protection
- Creates ~50 CSE-based access control policies
- Ensures service role can bypass RLS for backend operations

**Tables affected**:

- meetings, test_meetings
- client_segmentation, segmentation_events, segmentation_compliance_scores
- segmentation_tiers, tier_event_requirements, segmentation_event_types, event_schedule_templates
- unified_meetings
- nps_expert_teams, nps_client_priority, nps_client_trends, nps_individual_trends
- action_comments, nps_topic_classifications
- chasen_documents

## Deployment Steps

### Step 1: Deploy Performance Monitoring (Safe - No Breaking Changes)

1. Go to Supabase Dashboard: https://supabase.com/dashboard/project/usoyxsunetvxdjdglkmn/sql/new
2. Open `docs/migrations/20251202_create_query_performance_logs_table.sql`
3. Copy entire contents to SQL editor
4. Click **Run** button
5. Verify success:

   ```sql
   -- Check table created
   SELECT tablename FROM pg_tables WHERE tablename = 'query_performance_logs';

   -- Check indexes (should return 7)
   SELECT COUNT(*) FROM pg_indexes
   WHERE tablename = 'query_performance_logs' AND indexname LIKE 'idx_%';

   -- Check views (should return 3)
   SELECT viewname FROM pg_views
   WHERE viewname IN ('recent_slow_queries', 'hourly_performance_summary', 'table_performance_summary');
   ```

**Expected output**:

- ✅ Table created
- ✅ 7 indexes created
- ✅ 3 views created
- ✅ RLS enabled
- ✅ 3 policies created

### Step 2: Deploy RLS Security Fixes (Test After Deployment!)

1. Still in Supabase SQL editor
2. Open `docs/migrations/20251202_fix_rls_security_issues.sql`
3. Copy entire contents to SQL editor
4. Click **Run** button
5. Verify RLS enabled on all tables:

   ```sql
   -- Check RLS status (all should show 'true')
   SELECT tablename, rowsecurity
   FROM pg_tables
   WHERE schemaname = 'public'
   AND tablename IN (
     'meetings', 'test_meetings', 'client_segmentation',
     'segmentation_events', 'segmentation_compliance_scores',
     'segmentation_tiers', 'tier_event_requirements', 'segmentation_event_types',
     'event_schedule_templates', 'unified_meetings',
     'nps_expert_teams', 'nps_client_priority', 'nps_client_trends',
     'nps_individual_trends', 'action_comments',
     'nps_topic_classifications', 'chasen_documents'
   )
   ORDER BY tablename;

   -- Check policies per table
   SELECT tablename, COUNT(*) as policy_count
   FROM pg_policies
   WHERE tablename IN ('client_segmentation', 'unified_meetings', 'chasen_documents')
   GROUP BY tablename;

   -- CRITICAL: Check for tables with RLS but no policies (should return 0)
   SELECT t.tablename
   FROM pg_tables t
   WHERE t.schemaname = 'public'
   AND t.rowsecurity = true
   AND NOT EXISTS (SELECT 1 FROM pg_policies p WHERE p.tablename = t.tablename);
   ```

**Expected output**:

- ✅ All 17 tables have `rowsecurity = true`
- ✅ Each table has at least 2 policies
- ✅ No tables with RLS enabled but no policies

### Step 3: Post-Deployment Testing

**Immediate Tests** (Do within 5 minutes of deployment):

1. **Test application loads**:
   - Open https://your-app-url.vercel.app (or localhost:3000)
   - Verify homepage loads without errors

2. **Test client access**:
   - Navigate to Clients page
   - Verify you can see your assigned clients
   - Verify you CANNOT see other CSEs' clients

3. **Test meetings**:
   - Navigate to Briefing Room
   - Verify meetings load for your clients

4. **Test segmentation**:
   - Navigate to Client Segmentation page
   - Verify segmentation data loads

5. **Test ChaSen AI**:
   - Navigate to ChaSen AI page
   - Try uploading a document (should only see your own documents)

6. **Check browser console**:
   - Open DevTools Console (F12)
   - Look for any RLS policy errors
   - Common errors to watch for:
     - "new row violates row-level security policy"
     - "permission denied for table"

7. **Check server logs** (if applicable):
   - Monitor application logs for RLS errors
   - Check Supabase logs for failed queries

**Performance Dashboard Test**:

1. Navigate to /performance
2. Verify dashboard loads
3. Check that metrics are being recorded
4. Verify charts render correctly

**Extended Tests** (Within 1 hour):

1. Test all CRUD operations (Create, Read, Update, Delete)
2. Test with multiple users from different CSE assignments
3. Verify service role operations still work (backend jobs)

## Monitoring Post-Deployment

**For the next 24 hours, monitor**:

1. **Error rates**:
   - Check Supabase logs for permission errors
   - Check application error tracking (Sentry, etc.)

2. **Performance**:
   - Visit /performance dashboard
   - Look for slow queries (>500ms)
   - Check cache hit rate

3. **User reports**:
   - Monitor support channels for access issues
   - Be ready to quickly rollback if needed

## Rollback Procedure

If issues occur after deployment, execute rollback:

### Rollback RLS Security Fixes

```sql
-- Disable RLS on all affected tables
ALTER TABLE meetings DISABLE ROW LEVEL SECURITY;
ALTER TABLE test_meetings DISABLE ROW LEVEL SECURITY;
ALTER TABLE client_segmentation DISABLE ROW LEVEL SECURITY;
ALTER TABLE segmentation_events DISABLE ROW LEVEL SECURITY;
ALTER TABLE segmentation_compliance_scores DISABLE ROW LEVEL SECURITY;
ALTER TABLE segmentation_tiers DISABLE ROW LEVEL SECURITY;
ALTER TABLE tier_event_requirements DISABLE ROW LEVEL SECURITY;
ALTER TABLE segmentation_event_types DISABLE ROW LEVEL SECURITY;
ALTER TABLE event_schedule_templates DISABLE ROW LEVEL SECURITY;
ALTER TABLE unified_meetings DISABLE ROW LEVEL SECURITY;
ALTER TABLE nps_expert_teams DISABLE ROW LEVEL SECURITY;
ALTER TABLE nps_client_priority DISABLE ROW LEVEL SECURITY;
ALTER TABLE nps_client_trends DISABLE ROW LEVEL SECURITY;
ALTER TABLE nps_individual_trends DISABLE ROW LEVEL SECURITY;
ALTER TABLE action_comments DISABLE ROW LEVEL SECURITY;
ALTER TABLE nps_topic_classifications DISABLE ROW LEVEL SECURITY;
ALTER TABLE chasen_documents DISABLE ROW LEVEL SECURITY;

-- Drop all policies (optional - can leave them for future re-enable)
-- See migration file comments for DROP POLICY statements
```

### Rollback Performance Monitoring (Optional)

```sql
-- Drop performance monitoring infrastructure
DROP TABLE IF EXISTS query_performance_logs CASCADE;
DROP VIEW IF EXISTS recent_slow_queries CASCADE;
DROP VIEW IF EXISTS hourly_performance_summary CASCADE;
DROP VIEW IF EXISTS table_performance_summary CASCADE;
DROP FUNCTION IF EXISTS cleanup_old_performance_logs() CASCADE;
```

## Known Issues & Limitations

### Security Issues NOT Fixed

These require manual review:

1. **6 SECURITY DEFINER views** - May execute with elevated privileges
   - nps_clients_view, client_arr_summary, meeting_type_distribution
   - actions_view, topics_view, error_analytics
   - Recommendation: Review each view and consider changing to SECURITY INVOKER

### Performance Issues NOT Fixed

To be addressed in future updates:

1. Duplicate indexes (4 instances)
2. Unused indexes (~60 instances)
3. Unindexed foreign keys (6 instances)
4. Multiple permissive policies (~47 instances)
5. Auth RLS initplan performance (~13 instances)

## Success Criteria

✅ **Deployment is successful if**:

- All migrations execute without errors
- Application loads and functions normally
- Users can access their assigned client data
- Performance dashboard shows metrics
- No permission errors in logs
- Cache hit rate remains stable

❌ **Rollback immediately if**:

- Users cannot access their assigned data
- Multiple permission denied errors in logs
- Critical features broken (meetings, actions, etc.)
- Application crashes or fails to load

## Post-Deployment Tasks

After successful deployment:

1. ✅ Update Supabase database linter status
2. ✅ Document any issues encountered
3. ✅ Create bug report if fixes needed
4. ✅ Plan SECURITY DEFINER view review
5. ✅ Schedule WARN-level linter issue fixes
6. ✅ Proceed with Phase 4 Task 21: Configure slow query alerts

## Support

If issues occur:

1. Check #engineering Slack channel
2. Review Supabase logs: https://supabase.com/dashboard/project/usoyxsunetvxdjdglkmn/logs/query
3. Check GitHub issues for similar problems
4. Contact database administrator if rollback needed

## Additional Resources

- Supabase RLS Documentation: https://supabase.com/docs/guides/auth/row-level-security
- RLS Policy Examples: https://supabase.com/docs/guides/auth/row-level-security#examples
- Performance Monitoring Guide: `docs/PERFORMANCE_MONITORING_GUIDE.md` (to be created)
- RLS Audit Report: `docs/RLS-AUDIT-REPORT.md`

---

**Deployment Prepared By**: Claude Code
**Date Prepared**: December 2, 2025
**Last Updated**: December 2, 2025
