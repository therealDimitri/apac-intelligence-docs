# RLS Security Audit Report - Core Tables

**Audit Date**: 2025-12-02
**Auditor**: Claude Code (Phase 3 Task 19)
**Scope**: Core application tables (events, meetings, clients, actions, NPS)
**Status**: 🔴 **CRITICAL SECURITY GAPS IDENTIFIED**

---

## Executive Summary

This audit reviewed Row Level Security (RLS) policies for core application tables that handle sensitive client data. The audit identified **critical security gaps** requiring immediate attention.

### Findings Summary

| Finding                      | Severity    | Tables Affected | Impact                      |
| ---------------------------- | ----------- | --------------- | --------------------------- |
| RLS enabled without policies | 🔴 Critical | 3 tables        | **ALL ACCESS BLOCKED**      |
| Unknown RLS status           | 🔴 Critical | 4 core tables   | Potentially **UNPROTECTED** |
| Overly permissive policies   | 🟡 Medium   | 2 tables        | Data exposure risk          |
| Anonymous access to PII      | 🟡 Medium   | 1 table         | Privacy concern             |

### Immediate Actions Required

1. **Add policies to 3 tables with RLS enabled** (blocks current access)
2. **Audit and enable RLS on 4 core tables** (unknown status)
3. **Remove anonymous access** from compliance data
4. **Implement CSE-level access control** for client data

---

## Audit Scope

### Tables Audited

#### Priority 1: Core Data Tables

- ✅ `nps_clients` - Client master data
- ✅ `nps_responses` - NPS survey responses (PII)
- ✅ `actions` - Client action items
- ✅ `unified_meetings` - Meeting records

#### Priority 2: Event & Compliance Tables

- ✅ `segmentation_events` - Event tracking
- ✅ `segmentation_event_compliance` - Compliance tracking
- ✅ `client_segmentation` - Historical segments

#### Priority 3: Configuration Tables

- ✅ `segmentation_tiers` - Tier definitions
- ✅ `segmentation_event_types` - Event type catalog

#### Out of Scope

- Materialized views (inherit from source tables)
- Chasen tables (already audited - exemplary)
- ARR table (already audited - acceptable)

---

## Detailed Findings

### 🔴 CRITICAL: RLS Enabled Without Policies

These tables have RLS enabled but **NO POLICIES DEFINED**, which means:

- ❌ **ALL access is DENIED** by default (even to authenticated users)
- ❌ Application features dependent on these tables **WILL FAIL**
- ❌ Even service_role cannot access without explicit policy

#### Finding 1: client_segmentation

**Table**: `client_segmentation`
**Current State**: RLS enabled, 0 policies
**Data Sensitivity**: Medium (historical segment tracking)
**Impact**: Segment change history unavailable

**Migration**: `supabase/migrations/20251127_add_event_tracking_schema.sql:257`

```sql
ALTER TABLE client_segmentation ENABLE ROW LEVEL SECURITY;
-- No policies defined ❌
```

**Risk Assessment**:

- Application Impact: 🔴 High (features may fail)
- Data Exposure Risk: 🟢 Low (no access possible)
- Compliance Risk: 🟡 Medium (audit trail unavailable)

**Remediation**:

```sql
-- Priority: HIGH
-- Timeline: Immediate (within 24 hours)

-- Policy 1: Authenticated read access
CREATE POLICY "Allow authenticated read client_segmentation"
  ON client_segmentation
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy 2: Service role full access (for migrations/backfills)
CREATE POLICY "Allow service_role full access client_segmentation"
  ON client_segmentation
  FOR ALL
  TO service_role
  USING (true);

-- Policy 3: CSE can manage their clients' segments (future enhancement)
CREATE POLICY "CSE can manage client segments"
  ON client_segmentation
  FOR ALL
  TO authenticated
  USING (
    client_name IN (
      SELECT client_name FROM nps_clients WHERE cse = current_user
    )
  );
```

---

#### Finding 2: segmentation_events

**Table**: `segmentation_events`
**Current State**: RLS enabled, 0 policies
**Data Sensitivity**: High (client event tracking)
**Impact**: 🔴 **CRITICAL** - Event tracking and compliance features completely broken

**Migration**: `supabase/migrations/20251127_add_event_tracking_schema.sql:258`

```sql
ALTER TABLE segmentation_events ENABLE ROW LEVEL SECURITY;
-- No policies defined ❌
```

**Risk Assessment**:

- Application Impact: 🔴 **CRITICAL** (core feature broken)
- Data Exposure Risk: 🟢 Low (no access possible)
- Compliance Risk: 🔴 **CRITICAL** (cannot track compliance)

**Affected Features**:

- Event compliance dashboard
- Client profile event history
- Compliance scoring calculations
- Event scheduling and tracking

**Remediation**:

```sql
-- Priority: CRITICAL
-- Timeline: IMMEDIATE (deploy ASAP)

-- Policy 1: CSE can view events for their clients
CREATE POLICY "CSE can view their clients' events"
  ON segmentation_events
  FOR SELECT
  TO authenticated
  USING (
    client_name IN (
      SELECT client_name FROM nps_clients WHERE cse = current_user
    )
  );

-- Policy 2: CSE can create events for their clients
CREATE POLICY "CSE can create events for their clients"
  ON segmentation_events
  FOR INSERT
  TO authenticated
  WITH CHECK (
    client_name IN (
      SELECT client_name FROM nps_clients WHERE cse = current_user
    )
  );

-- Policy 3: CSE can update/delete their clients' events
CREATE POLICY "CSE can manage their clients' events"
  ON segmentation_events
  FOR UPDATE
  TO authenticated
  USING (
    client_name IN (
      SELECT client_name FROM nps_clients WHERE cse = current_user
    )
  );

CREATE POLICY "CSE can delete their clients' events"
  ON segmentation_events
  FOR DELETE
  TO authenticated
  USING (
    client_name IN (
      SELECT client_name FROM nps_clients WHERE cse = current_user
    )
  );

-- Policy 4: Service role bypass (always include)
CREATE POLICY "Service role full access events"
  ON segmentation_events
  FOR ALL
  TO service_role
  USING (true);
```

---

#### Finding 3: segmentation_compliance_scores

**Table**: `segmentation_compliance_scores`
**Current State**: RLS enabled, 0 policies
**Data Sensitivity**: High (client compliance tracking)
**Impact**: 🔴 **CRITICAL** - Compliance reporting completely broken

**Migration**: `supabase/migrations/20251127_add_event_tracking_schema.sql:260`

```sql
ALTER TABLE segmentation_compliance_scores ENABLE ROW LEVEL SECURITY;
-- No policies defined ❌
```

**Risk Assessment**:

- Application Impact: 🔴 **CRITICAL** (compliance reporting broken)
- Data Exposure Risk: 🟢 Low (no access possible)
- Compliance Risk: 🔴 **CRITICAL** (cannot monitor compliance)

**Affected Features**:

- Overall compliance dashboard
- Client health scores
- Compliance trend analysis
- At-risk client identification

**Remediation**:

```sql
-- Priority: CRITICAL
-- Timeline: IMMEDIATE (deploy ASAP)

-- Policy 1: CSE can view compliance scores for their clients
CREATE POLICY "CSE can view their clients' compliance"
  ON segmentation_compliance_scores
  FOR SELECT
  TO authenticated
  USING (
    client_name IN (
      SELECT client_name FROM nps_clients WHERE cse = current_user
    )
  );

-- Policy 2: Service role full access (for calculations)
CREATE POLICY "Service role full access compliance_scores"
  ON segmentation_compliance_scores
  FOR ALL
  TO service_role
  USING (true);

-- Policy 3: Restrict write access to service role only
-- (Compliance scores should be system-calculated, not user-editable)
```

---

### 🔴 CRITICAL: Core Tables with Unknown RLS Status

These tables handle sensitive client data but have **unknown RLS status**. They may be completely unprotected.

#### Finding 4: nps_clients

**Table**: `nps_clients`
**Current State**: Unknown (not found in migrations)
**Data Sensitivity**: 🔴 Very High (client master data, ARR, CSE assignments)
**Impact**: Potential unauthorized access to all client data

**Data Contained**:

- Client names
- Segment classifications
- CSE assignments
- ARR values (financial data)
- Health scores
- Contact information

**Risk Assessment**:

- Application Impact: 🟢 Low (likely working if RLS disabled)
- Data Exposure Risk: 🔴 **CRITICAL** (if RLS disabled)
- Compliance Risk: 🔴 **CRITICAL** (financial + PII exposure)

**Verification Query**:

```sql
-- Run in Supabase SQL Editor to check RLS status
SELECT
  tablename,
  rowsecurity as rls_enabled,
  (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'nps_clients') as policy_count
FROM pg_tables
WHERE tablename = 'nps_clients'
  AND schemaname = 'public';
```

**Expected Result**:

- `rls_enabled = true` ✅
- `policy_count >= 2` ✅

**Recommended Policies**:

```sql
-- If RLS not enabled, ENABLE IMMEDIATELY:
ALTER TABLE nps_clients ENABLE ROW LEVEL SECURITY;

-- Policy 1: CSE can view their own clients
CREATE POLICY "CSE can view their clients"
  ON nps_clients
  FOR SELECT
  TO authenticated
  USING (cse = current_user OR cse IS NULL);

-- Policy 2: CSE can update their clients
CREATE POLICY "CSE can update their clients"
  ON nps_clients
  FOR UPDATE
  TO authenticated
  USING (cse = current_user);

-- Policy 3: Service role full access
CREATE POLICY "Service role full access nps_clients"
  ON nps_clients
  FOR ALL
  TO service_role
  USING (true);

-- Policy 4: Admin can manage all clients
CREATE POLICY "Admin can manage all clients"
  ON nps_clients
  FOR ALL
  TO authenticated
  USING (
    auth.jwt() ->> 'email' IN (
      'admin1@altera.com',
      'admin2@altera.com'
    )
  );
```

---

#### Finding 5: nps_responses

**Table**: `nps_responses`
**Current State**: Unknown (not found in migrations)
**Data Sensitivity**: 🔴 Very High (contains PII - survey responses, names, comments)
**Impact**: Potential exposure of customer feedback and PII

**Data Contained**:

- NPS scores (numerical ratings)
- Customer names (contact_name)
- Feedback comments (may contain PII)
- Email addresses
- Response dates

**Risk Assessment**:

- Application Impact: 🟢 Low (likely working)
- Data Exposure Risk: 🔴 **CRITICAL** (PII + feedback)
- Compliance Risk: 🔴 **CRITICAL** (GDPR/privacy violation if exposed)

**Verification Query**:

```sql
SELECT
  tablename,
  rowsecurity as rls_enabled,
  (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'nps_responses') as policy_count
FROM pg_tables
WHERE tablename = 'nps_responses'
  AND schemaname = 'public';
```

**Recommended Policies**:

```sql
-- If RLS not enabled, ENABLE IMMEDIATELY:
ALTER TABLE nps_responses ENABLE ROW LEVEL SECURITY;

-- Policy 1: CSE can view responses from their clients
CREATE POLICY "CSE can view their clients' NPS responses"
  ON nps_responses
  FOR SELECT
  TO authenticated
  USING (
    client_name IN (
      SELECT client_name FROM nps_clients WHERE cse = current_user
    )
  );

-- Policy 2: Service role full access (for imports/exports)
CREATE POLICY "Service role full access nps_responses"
  ON nps_responses
  FOR ALL
  TO service_role
  USING (true);

-- Policy 3: No write access for regular users (responses are imported)
-- This prevents tampering with survey data
```

---

#### Finding 6: actions

**Table**: `actions`
**Current State**: Unknown (not found in migrations)
**Data Sensitivity**: High (client action items, may contain sensitive notes)
**Impact**: Potential unauthorized modification of action items

**Data Contained**:

- Action descriptions
- Client names
- Owner assignments
- Due dates
- Status
- Notes (may contain sensitive information)

**Risk Assessment**:

- Application Impact: 🟢 Low (likely working)
- Data Exposure Risk: 🟡 Medium (business-sensitive, not PII)
- Compliance Risk: 🟡 Medium (action tracking critical for CSE workflow)

**Verification Query**:

```sql
SELECT
  tablename,
  rowsecurity as rls_enabled,
  (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'actions') as policy_count
FROM pg_tables
WHERE tablename = 'actions'
  AND schemaname = 'public';
```

**Recommended Policies**:

```sql
-- If RLS not enabled, ENABLE IMMEDIATELY:
ALTER TABLE actions ENABLE ROW LEVEL SECURITY;

-- Policy 1: Users can view actions assigned to them or their clients
CREATE POLICY "Users can view relevant actions"
  ON actions
  FOR SELECT
  TO authenticated
  USING (
    "Owner" = current_user
    OR "Client" IN (
      SELECT client_name FROM nps_clients WHERE cse = current_user
    )
  );

-- Policy 2: Users can create actions for their clients
CREATE POLICY "Users can create actions for their clients"
  ON actions
  FOR INSERT
  TO authenticated
  WITH CHECK (
    "Client" IN (
      SELECT client_name FROM nps_clients WHERE cse = current_user
    )
  );

-- Policy 3: Users can update actions they own or for their clients
CREATE POLICY "Users can update relevant actions"
  ON actions
  FOR UPDATE
  TO authenticated
  USING (
    "Owner" = current_user
    OR "Client" IN (
      SELECT client_name FROM nps_clients WHERE cse = current_user
    )
  );

-- Policy 4: Users can delete their own actions only
CREATE POLICY "Users can delete their own actions"
  ON actions
  FOR DELETE
  TO authenticated
  USING ("Owner" = current_user);

-- Policy 5: Service role full access
CREATE POLICY "Service role full access actions"
  ON actions
  FOR ALL
  TO service_role
  USING (true);
```

---

#### Finding 7: unified_meetings

**Table**: `unified_meetings`
**Current State**: Unknown (not found in migrations)
**Data Sensitivity**: High (meeting notes, attendees, may contain sensitive discussions)
**Impact**: Potential unauthorized access to meeting records

**Data Contained**:

- Meeting notes and agendas
- Attendee lists
- Meeting links (Zoom/Teams URLs)
- Client names
- Meeting types (QBR, EBR, etc.)

**Risk Assessment**:

- Application Impact: 🟢 Low (likely working)
- Data Exposure Risk: 🟡 Medium (business-sensitive, some PII)
- Compliance Risk: 🟡 Medium (meeting records important for audit)

**Verification Query**:

```sql
SELECT
  tablename,
  rowsecurity as rls_enabled,
  (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'unified_meetings') as policy_count
FROM pg_tables
WHERE tablename = 'unified_meetings'
  AND schemaname = 'public';
```

**Recommended Policies**:

```sql
-- If RLS not enabled, ENABLE IMMEDIATELY:
ALTER TABLE unified_meetings ENABLE ROW LEVEL SECURITY;

-- Policy 1: Users can view meetings they organized or attended
CREATE POLICY "Users can view meetings they participated in"
  ON unified_meetings
  FOR SELECT
  TO authenticated
  USING (
    organizer_email = current_user
    OR attendees::text ILIKE '%' || current_user || '%'
    OR client_name IN (
      SELECT client_name FROM nps_clients WHERE cse = current_user
    )
  );

-- Policy 2: Users can create meetings for their clients
CREATE POLICY "Users can create meetings for their clients"
  ON unified_meetings
  FOR INSERT
  TO authenticated
  WITH CHECK (
    client_name IN (
      SELECT client_name FROM nps_clients WHERE cse = current_user
    )
  );

-- Policy 3: Users can update meetings they organized
CREATE POLICY "Users can update their own meetings"
  ON unified_meetings
  FOR UPDATE
  TO authenticated
  USING (organizer_email = current_user);

-- Policy 4: Users can delete their own meetings only
CREATE POLICY "Users can delete their own meetings"
  ON unified_meetings
  FOR DELETE
  TO authenticated
  USING (organizer_email = current_user);

-- Policy 5: Service role full access
CREATE POLICY "Service role full access unified_meetings"
  ON unified_meetings
  FOR ALL
  TO service_role
  USING (true);
```

---

### 🟡 MEDIUM: Overly Permissive Policies

#### Finding 8: segmentation_event_types

**Table**: `segmentation_event_types`
**Current State**: RLS enabled, 2 policies
**Issue**: All authenticated users can modify event type definitions

**Current Policy**:

```sql
CREATE POLICY "Allow all for authenticated users"
  ON segmentation_event_types
  FOR ALL
  TO authenticated
  USING (true);
```

**Risk**: Users could accidentally or maliciously modify event type configurations, affecting compliance calculations across the entire system.

**Recommendation**: Restrict write access to admin users only:

```sql
-- Drop overly permissive policy
DROP POLICY "Allow all for authenticated users" ON segmentation_event_types;

-- Replace with read-only policy
CREATE POLICY "Authenticated can read event types"
  ON segmentation_event_types
  FOR SELECT
  TO authenticated
  USING (true);

-- Add admin-only write policy
CREATE POLICY "Admin can manage event types"
  ON segmentation_event_types
  FOR ALL
  TO authenticated
  USING (
    auth.jwt() ->> 'role' = 'admin'
    OR auth.jwt() ->> 'email' IN (
      'admin1@altera.com',
      'admin2@altera.com'
    )
  );
```

---

### 🟡 MEDIUM: Anonymous Access to Sensitive Data

#### Finding 9: segmentation_event_compliance

**Table**: `segmentation_event_compliance`
**Current State**: RLS enabled, 2 policies (including anonymous read)
**Issue**: Anonymous users can view client compliance data

**Current Policy**:

```sql
CREATE POLICY "Allow read for anon users"
  ON segmentation_event_compliance
  FOR SELECT
  TO anon
  USING (true);
```

**Risk**: Client compliance data exposed to unauthenticated users. This is a **privacy concern** as it reveals:

- Which clients are non-compliant
- Client names
- Event completion rates

**Recommendation**: Remove anonymous access immediately:

```sql
-- Drop anonymous access policy
DROP POLICY "Allow read for anon users" ON segmentation_event_compliance;

-- Compliance data should only be visible to authenticated CSEs
-- Already covered by "Allow all for authenticated users" policy
```

---

## Remediation Plan

### Phase 1: Critical Fixes (Deploy Within 24 Hours)

**Priority**: 🔴 CRITICAL
**Estimated Time**: 2-4 hours
**Impact**: Restores broken features

1. Add policies to `segmentation_events` ✅
2. Add policies to `segmentation_compliance_scores` ✅
3. Add policies to `client_segmentation` ✅

**Deployment Steps**:

1. Create migration file: `20251202_fix_missing_rls_policies.sql`
2. Test in development environment
3. Deploy to production via Supabase SQL Editor
4. Verify policies created: `SELECT * FROM pg_policies WHERE tablename IN (...)`
5. Test application functionality

---

### Phase 2: Core Table Audit (Deploy Within 48 Hours)

**Priority**: 🔴 CRITICAL
**Estimated Time**: 4-6 hours
**Impact**: Secures core data tables

1. Verify RLS status of `nps_clients` 🔍
2. Verify RLS status of `nps_responses` 🔍
3. Verify RLS status of `actions` 🔍
4. Verify RLS status of `unified_meetings` 🔍
5. Add policies as needed based on verification

**Verification Script**:

```sql
-- Run this in Supabase SQL Editor
SELECT
  t.tablename,
  t.rowsecurity as rls_enabled,
  COUNT(p.policyname) as policy_count,
  STRING_AGG(p.policyname, ', ') as policies
FROM pg_tables t
LEFT JOIN pg_policies p ON t.tablename = p.tablename AND t.schemaname = p.schemaname
WHERE t.schemaname = 'public'
  AND t.tablename IN (
    'nps_clients',
    'nps_responses',
    'actions',
    'unified_meetings'
  )
GROUP BY t.tablename, t.rowsecurity
ORDER BY t.tablename;
```

---

### Phase 3: Security Hardening (Deploy Within 1 Week)

**Priority**: 🟡 MEDIUM
**Estimated Time**: 2-3 hours
**Impact**: Reduces data exposure risk

1. Remove anonymous access from `segmentation_event_compliance` ⚠️
2. Restrict `segmentation_event_types` write access to admins 🟡
3. Add CSE-level restrictions to `client_arr` 🟡
4. Add audit logging for policy violations 📊

---

### Phase 4: Monitoring & Compliance (Ongoing)

**Priority**: 🟢 LOW
**Estimated Time**: Ongoing
**Impact**: Long-term security posture

1. Set up RLS policy monitoring dashboard
2. Configure alerts for policy violations
3. Regular security audits (quarterly)
4. Document all policy changes in change log

---

## Testing Checklist

### Pre-Deployment Testing

- [ ] Create test users with different roles (CSE, admin, service_role)
- [ ] Test SELECT access for each table
- [ ] Test INSERT/UPDATE/DELETE access for each table
- [ ] Verify policies don't break existing features
- [ ] Test cross-CSE data access (should be blocked)
- [ ] Test service_role bypass (should always work)

### Post-Deployment Verification

- [ ] Run policy count query: `SELECT COUNT(*) FROM pg_policies WHERE schemaname = 'public'`
- [ ] Test application login and dashboard load
- [ ] Verify compliance features work
- [ ] Verify event tracking works
- [ ] Check error logs for RLS violations
- [ ] Confirm no "permission denied" errors

### Rollback Plan

```sql
-- If policies cause issues, disable RLS temporarily:
ALTER TABLE <table_name> DISABLE ROW LEVEL SECURITY;

-- Fix policies, then re-enable:
ALTER TABLE <table_name> ENABLE ROW LEVEL SECURITY;

-- Or drop specific problematic policy:
DROP POLICY "<policy_name>" ON <table_name>;
```

---

## Recommended Migration File

Create: `docs/migrations/20251202_fix_missing_rls_policies.sql`

See full migration template in **Appendix A** below.

---

## Appendix A: Complete Migration File

```sql
-- Migration: Fix Missing RLS Policies
-- Date: 2025-12-02
-- Purpose: Add missing policies to tables with RLS enabled
-- Impact: Restores access to segmentation_events, client_segmentation, segmentation_compliance_scores

-- =====================================================================
-- CRITICAL FIX 1: segmentation_events
-- =====================================================================

-- CSE can view events for their clients
CREATE POLICY "CSE can view their clients' events"
  ON segmentation_events
  FOR SELECT
  TO authenticated
  USING (
    client_name IN (
      SELECT client_name FROM nps_clients WHERE cse = current_user
    )
  );

-- CSE can create events for their clients
CREATE POLICY "CSE can create events for their clients"
  ON segmentation_events
  FOR INSERT
  TO authenticated
  WITH CHECK (
    client_name IN (
      SELECT client_name FROM nps_clients WHERE cse = current_user
    )
  );

-- CSE can update their clients' events
CREATE POLICY "CSE can manage their clients' events"
  ON segmentation_events
  FOR UPDATE
  TO authenticated
  USING (
    client_name IN (
      SELECT client_name FROM nps_clients WHERE cse = current_user
    )
  );

-- Service role bypass
CREATE POLICY "Service role full access events"
  ON segmentation_events
  FOR ALL
  TO service_role
  USING (true);

-- =====================================================================
-- CRITICAL FIX 2: segmentation_compliance_scores
-- =====================================================================

-- CSE can view compliance scores for their clients
CREATE POLICY "CSE can view their clients' compliance"
  ON segmentation_compliance_scores
  FOR SELECT
  TO authenticated
  USING (
    client_name IN (
      SELECT client_name FROM nps_clients WHERE cse = current_user
    )
  );

-- Service role full access
CREATE POLICY "Service role full access compliance_scores"
  ON segmentation_compliance_scores
  FOR ALL
  TO service_role
  USING (true);

-- =====================================================================
-- CRITICAL FIX 3: client_segmentation
-- =====================================================================

-- Authenticated users can read segment history
CREATE POLICY "Allow authenticated read client_segmentation"
  ON client_segmentation
  FOR SELECT
  TO authenticated
  USING (true);

-- Service role full access
CREATE POLICY "Allow service_role full access client_segmentation"
  ON client_segmentation
  FOR ALL
  TO service_role
  USING (true);

-- =====================================================================
-- VERIFICATION
-- =====================================================================

-- Verify policies created:
-- SELECT tablename, COUNT(*)
-- FROM pg_policies
-- WHERE tablename IN ('segmentation_events', 'segmentation_compliance_scores', 'client_segmentation')
-- GROUP BY tablename;
-- Expected: segmentation_events=4, segmentation_compliance_scores=2, client_segmentation=2
```

---

## Sign-Off

**Auditor**: Claude Code (Automated Security Audit)
**Date**: 2025-12-02
**Next Review**: 2025-03-02 (quarterly)

**Approval Required**:

- [ ] Security Team Lead
- [ ] Engineering Manager
- [ ] Database Administrator

**Deployment Checklist**:

- [ ] Migration file created and tested
- [ ] Rollback plan documented
- [ ] Stakeholders notified
- [ ] Deployment scheduled
- [ ] Post-deployment verification complete
