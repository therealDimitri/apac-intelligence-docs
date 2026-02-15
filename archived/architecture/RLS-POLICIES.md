# Row Level Security (RLS) Policies Documentation

**Last Updated**: 2025-12-02
**Status**: Phase 3 Documentation Complete
**Security Audit**: See [Security Gaps](#security-gaps-and-recommendations) section

---

## Table of Contents

1. [Overview](#overview)
2. [RLS Status by Table](#rls-status-by-table)
3. [Policy Details](#policy-details)
4. [Security Gaps and Recommendations](#security-gaps-and-recommendations)
5. [Policy Templates](#policy-templates)
6. [Testing and Verification](#testing-and-verification)

---

## Overview

Row Level Security (RLS) is a PostgreSQL feature that restricts which rows users can access in database tables. In Supabase, RLS is essential for securing data as it enforces access control at the database level, independent of application logic.

### Key Concepts

- **Enabled RLS**: RLS must be explicitly enabled on each table (`ALTER TABLE ... ENABLE ROW LEVEL SECURITY`)
- **Policies**: Define WHO can do WHAT with WHICH rows
- **User Roles**: Supabase has built-in roles:
  - `anon`: Unauthenticated users (public access)
  - `authenticated`: Logged-in users
  - `service_role`: Backend services (bypass RLS)
- **Policy Types**:
  - `FOR SELECT`: Read access
  - `FOR INSERT`: Create access
  - `FOR UPDATE`: Modify access
  - `FOR DELETE`: Delete access
  - `FOR ALL`: All operations

### Current Implementation Status

- **Total Tables with RLS Enabled**: 9 tables
- **Tables with Policies Defined**: 6 tables (17 policies total)
- **Tables with RLS Enabled but No Policies**: 3 tables ⚠️ **SECURITY GAP**
- **Tables with Unknown RLS Status**: ~10 core tables 🔍 **NEEDS AUDIT**

---

## RLS Status by Table

### ✅ Tables with RLS Enabled + Policies Defined

| Table                           | RLS Status | Policies   | Security Level |
| ------------------------------- | ---------- | ---------- | -------------- |
| `client_arr`                    | ✅ Enabled | 3 policies | 🟢 Good        |
| `tier_event_requirements`       | ✅ Enabled | 2 policies | 🟢 Good        |
| `segmentation_event_types`      | ✅ Enabled | 2 policies | 🟡 Moderate    |
| `segmentation_event_compliance` | ✅ Enabled | 2 policies | 🟡 Moderate    |
| `chasen_conversations`          | ✅ Enabled | 4 policies | 🟢 Excellent   |
| `chasen_conversation_messages`  | ✅ Enabled | 4 policies | 🟢 Excellent   |

### ⚠️ Tables with RLS Enabled but NO Policies (SECURITY GAP)

| Table                            | RLS Status | Policies    | Risk Level      |
| -------------------------------- | ---------- | ----------- | --------------- |
| `client_segmentation`            | ✅ Enabled | ❌ **NONE** | 🔴 **CRITICAL** |
| `segmentation_events`            | ✅ Enabled | ❌ **NONE** | 🔴 **CRITICAL** |
| `segmentation_compliance_scores` | ✅ Enabled | ❌ **NONE** | 🔴 **CRITICAL** |

**⚠️ WARNING**: These tables have RLS enabled but no policies, meaning **ALL ACCESS IS DENIED by default** (even to authenticated users). This may cause application errors.

### 🔍 Tables with Unknown RLS Status (NEEDS AUDIT)

| Table                      | Status     | Source                      |
| -------------------------- | ---------- | --------------------------- |
| `nps_clients`              | 🔍 Unknown | Core client data            |
| `nps_responses`            | 🔍 Unknown | NPS survey responses        |
| `actions`                  | 🔍 Unknown | Client action items         |
| `unified_meetings`         | 🔍 Unknown | Meeting records             |
| `segmentation_tiers`       | 🔍 Unknown | Tier definitions            |
| `client_health_summary`    | 🔍 Unknown | Materialized view (Phase 2) |
| `event_compliance_summary` | 🔍 Unknown | Materialized view (Phase 2) |

**📋 ACTION REQUIRED**: Audit these tables in Phase 3 Task 19

---

## Policy Details

### 1. client_arr Table

**Purpose**: Annual Recurring Revenue tracking for APAC clients
**Migration**: `supabase/migrations/20251129_create_client_arr_table.sql`
**Security Level**: 🟢 Good (authenticated users only)

#### Policies (3)

```sql
-- Policy 1: Allow authenticated users to read
CREATE POLICY "Allow authenticated users to read client_arr"
  ON client_arr
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy 2: Allow authenticated users to insert
CREATE POLICY "Allow authenticated users to insert client_arr"
  ON client_arr
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Policy 3: Allow authenticated users to update
CREATE POLICY "Allow authenticated users to update client_arr"
  ON client_arr
  FOR UPDATE
  TO authenticated
  USING (true);
```

**Analysis**:

- ✅ Read access limited to authenticated users
- ✅ Write access limited to authenticated users
- ❌ No DELETE policy (intentional - prevents accidental deletion)
- ❌ No row-level restrictions (all authenticated users see all ARR data)

**Recommendations**:

- Consider adding CSE-level restrictions: `WHERE cse = current_user`
- Add DELETE policy with admin-only access if needed

---

### 2. tier_event_requirements Table

**Purpose**: Segment-specific event frequency requirements
**Migration**: `supabase/migrations/20251127_migrate_tier_requirements_schema.sql`
**Security Level**: 🟢 Good (read-only for authenticated, full access for service_role)

#### Policies (2)

```sql
-- Policy 1: Allow service_role full access
CREATE POLICY "Allow service_role full access to tier_event_requirements"
  ON tier_event_requirements
  FOR ALL
  TO service_role
  USING (true);

-- Policy 2: Allow authenticated read access
CREATE POLICY "Allow authenticated read access to tier_event_requirements"
  ON tier_event_requirements
  FOR SELECT
  TO authenticated
  USING (true);
```

**Analysis**:

- ✅ Read-only access for authenticated users (prevents accidental modification)
- ✅ Full access for service_role (backend operations)
- ✅ Configuration data protected from user modification

**Recommendations**:

- Perfect for reference data tables
- Consider similar pattern for other configuration tables

---

### 3. segmentation_event_types Table

**Purpose**: Defines 12 official Altera APAC event types
**Migration**: `scripts/create_event_types_tables.sql`
**Security Level**: 🟡 Moderate (allows anon read access)

#### Policies (2)

```sql
-- Policy 1: Allow all operations for authenticated users
CREATE POLICY "Allow all for authenticated users"
  ON segmentation_event_types
  FOR ALL
  TO authenticated
  USING (true);

-- Policy 2: Allow read-only for anonymous users
CREATE POLICY "Allow read for anon users"
  ON segmentation_event_types
  FOR SELECT
  TO anon
  USING (true);
```

**Analysis**:

- ⚠️ Anonymous read access may expose internal event structures
- ⚠️ All authenticated users can modify event types (risky)
- ✅ Allows public viewing of event catalog

**Recommendations**:

- Remove anon access if event types should be private
- Restrict INSERT/UPDATE/DELETE to admin users only:
  ```sql
  FOR INSERT TO authenticated USING (auth.jwt() ->> 'role' = 'admin')
  ```

---

### 4. segmentation_event_compliance Table

**Purpose**: Monthly event compliance tracking
**Migration**: `scripts/create_event_types_tables.sql`
**Security Level**: 🟡 Moderate (same concerns as event_types)

#### Policies (2)

```sql
-- Policy 1: Allow all operations for authenticated users
CREATE POLICY "Allow all for authenticated users"
  ON segmentation_event_compliance
  FOR ALL
  TO authenticated
  USING (true);

-- Policy 2: Allow read-only for anonymous users
CREATE POLICY "Allow read for anon users"
  ON segmentation_event_compliance
  FOR SELECT
  TO anon
  USING (true);
```

**Analysis**:

- ⚠️ Anonymous read access exposes client compliance data (PRIVACY CONCERN)
- ⚠️ All authenticated users can modify compliance records
- 🔴 Should restrict to CSE-owned clients only

**Recommendations**:

- **REMOVE anon access immediately** (compliance data should be private)
- Implement CSE-level access control:
  ```sql
  FOR SELECT TO authenticated
  USING (
    client_name IN (
      SELECT client_name FROM nps_clients WHERE cse = current_user
    )
  )
  ```

---

### 5. chasen_conversations Table

**Purpose**: AI assistant (Chasen) conversation history
**Migration**: `scripts/create_chasen_conversations_table.sql`
**Security Level**: 🟢 Excellent (user-owned data only)

#### Policies (4)

```sql
-- Policy 1: Users can view their own conversations
CREATE POLICY "Users can view their own conversations"
  ON chasen_conversations
  FOR SELECT
  USING (user_email = current_user);

-- Policy 2: Users can insert their own conversations
CREATE POLICY "Users can insert their own conversations"
  ON chasen_conversations
  FOR INSERT
  WITH CHECK (user_email = current_user);

-- Policy 3: Users can update their own conversations
CREATE POLICY "Users can update their own conversations"
  ON chasen_conversations
  FOR UPDATE
  USING (user_email = current_user);

-- Policy 4: Users can delete their own conversations
CREATE POLICY "Users can delete their own conversations"
  ON chasen_conversations
  FOR DELETE
  USING (user_email = current_user);
```

**Analysis**:

- ✅ Perfect implementation of user-owned data pattern
- ✅ Complete CRUD coverage
- ✅ Users cannot access other users' conversations
- ✅ No anonymous access (conversations are private)

**Recommendations**:

- **EXEMPLARY PATTERN** - use this as template for other user-specific tables

---

### 6. chasen_conversation_messages Table

**Purpose**: Individual messages within Chasen conversations
**Migration**: `scripts/create_chasen_conversations_table.sql`
**Security Level**: 🟢 Excellent (cascading user ownership)

#### Policies (4)

```sql
-- Policy 1: Users can view messages from their conversations
CREATE POLICY "Users can view messages from their conversations"
  ON chasen_conversation_messages
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM chasen_conversations
      WHERE id = conversation_id AND user_email = current_user
    )
  );

-- Policy 2: Users can insert messages to their conversations
CREATE POLICY "Users can insert messages to their conversations"
  ON chasen_conversation_messages
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM chasen_conversations
      WHERE id = conversation_id AND user_email = current_user
    )
  );

-- Policy 3: Users can update messages in their conversations
CREATE POLICY "Users can update messages in their conversations"
  ON chasen_conversation_messages
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM chasen_conversations
      WHERE id = conversation_id AND user_email = current_user
    )
  );

-- Policy 4: Users can delete messages from their conversations
CREATE POLICY "Users can delete messages from their conversations"
  ON chasen_conversation_messages
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM chasen_conversations
      WHERE id = conversation_id AND user_email = current_user
    )
  );
```

**Analysis**:

- ✅ Perfect cascading ownership model
- ✅ Messages inherit conversation ownership via EXISTS subquery
- ✅ Complete CRUD coverage
- ✅ Efficient policy implementation

**Recommendations**:

- **EXEMPLARY PATTERN** - use this for related/child tables

---

## Security Gaps and Recommendations

### 🔴 CRITICAL: Tables with RLS Enabled but No Policies

These tables currently **BLOCK ALL ACCESS** (even to authenticated users) because RLS is enabled without policies:

#### 1. client_segmentation

**Impact**: Historical segment tracking is inaccessible
**Risk Level**: 🔴 Critical

**Recommended Policy**:

```sql
-- Allow authenticated users to read segment history
CREATE POLICY "Allow authenticated read client_segmentation"
  ON client_segmentation
  FOR SELECT
  TO authenticated
  USING (true);

-- Allow service_role full access for migrations
CREATE POLICY "Allow service_role full access client_segmentation"
  ON client_segmentation
  FOR ALL
  TO service_role
  USING (true);
```

#### 2. segmentation_events

**Impact**: Event tracking is inaccessible (breaks compliance features)
**Risk Level**: 🔴 Critical

**Recommended Policy**:

```sql
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

-- CSE can manage events for their clients
CREATE POLICY "CSE can manage their clients' events"
  ON segmentation_events
  FOR ALL
  TO authenticated
  USING (
    client_name IN (
      SELECT client_name FROM nps_clients WHERE cse = current_user
    )
  );

-- Service role full access
CREATE POLICY "Service role full access events"
  ON segmentation_events
  FOR ALL
  TO service_role
  USING (true);
```

#### 3. segmentation_compliance_scores

**Impact**: Compliance scores are inaccessible (breaks reporting)
**Risk Level**: 🔴 Critical

**Recommended Policy**:

```sql
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
```

---

### 🔍 NEEDS AUDIT: Core Tables (Unknown RLS Status)

These tables have not been audited for RLS. They may be:

1. Completely unprotected (RLS disabled) - **HIGH RISK**
2. Protected via Supabase dashboard policies (not in code)
3. Relying on API-level security only

**Action Required**: Phase 3 Task 19 - Audit and document these tables

#### Priority 1: Client Data Tables

- **nps_clients**: Core client information
- **nps_responses**: Survey responses (PII)
- **actions**: Client action items

**Recommended Approach**: CSE-based access control

```sql
-- Template for CSE-owned client data
CREATE POLICY "CSE can view their clients"
  ON <table_name>
  FOR SELECT
  TO authenticated
  USING (cse = current_user OR cse IS NULL);
```

#### Priority 2: Meeting Data

- **unified_meetings**: Meeting records and notes

**Recommended Approach**: Participant-based access

```sql
CREATE POLICY "Users can view meetings they attended"
  ON unified_meetings
  FOR SELECT
  TO authenticated
  USING (
    organizer_email = current_user
    OR attendees::text ILIKE '%' || current_user || '%'
  );
```

#### Priority 3: Configuration Tables

- **segmentation_tiers**: Tier definitions

**Recommended Approach**: Read-only for authenticated, full access for service_role

```sql
CREATE POLICY "Authenticated read-only tiers"
  ON segmentation_tiers
  FOR SELECT
  TO authenticated
  USING (true);
```

#### Priority 4: Materialized Views

- **client_health_summary**: Phase 2 materialized view
- **event_compliance_summary**: Phase 2 materialized view

**Note**: Materialized views inherit RLS from source tables in some cases, but should have explicit policies for clarity.

---

## Policy Templates

### Template 1: User-Owned Data (Chasen Pattern)

Use for tables where each row belongs to a specific user.

```sql
-- Enable RLS
ALTER TABLE <table_name> ENABLE ROW LEVEL SECURITY;

-- SELECT: Users can view their own data
CREATE POLICY "Users can view their own <table_name>"
  ON <table_name>
  FOR SELECT
  TO authenticated
  USING (<user_column> = current_user);

-- INSERT: Users can create their own data
CREATE POLICY "Users can insert their own <table_name>"
  ON <table_name>
  FOR INSERT
  TO authenticated
  WITH CHECK (<user_column> = current_user);

-- UPDATE: Users can modify their own data
CREATE POLICY "Users can update their own <table_name>"
  ON <table_name>
  FOR UPDATE
  TO authenticated
  USING (<user_column> = current_user);

-- DELETE: Users can delete their own data
CREATE POLICY "Users can delete their own <table_name>"
  ON <table_name>
  FOR DELETE
  TO authenticated
  USING (<user_column> = current_user);
```

### Template 2: CSE-Owned Client Data

Use for tables containing client-specific data managed by CSEs.

```sql
-- Enable RLS
ALTER TABLE <table_name> ENABLE ROW LEVEL SECURITY;

-- SELECT: CSEs can view their clients' data
CREATE POLICY "CSE can view their clients' <table_name>"
  ON <table_name>
  FOR SELECT
  TO authenticated
  USING (
    client_name IN (
      SELECT client_name FROM nps_clients WHERE cse = current_user
    )
  );

-- INSERT/UPDATE/DELETE: CSEs can manage their clients' data
CREATE POLICY "CSE can manage their clients' <table_name>"
  ON <table_name>
  FOR ALL
  TO authenticated
  USING (
    client_name IN (
      SELECT client_name FROM nps_clients WHERE cse = current_user
    )
  );

-- Service role bypass
CREATE POLICY "Service role full access <table_name>"
  ON <table_name>
  FOR ALL
  TO service_role
  USING (true);
```

### Template 3: Read-Only Configuration Data

Use for reference/configuration tables that should not be modified by users.

```sql
-- Enable RLS
ALTER TABLE <table_name> ENABLE ROW LEVEL SECURITY;

-- SELECT: Authenticated users can read
CREATE POLICY "Authenticated read <table_name>"
  ON <table_name>
  FOR SELECT
  TO authenticated
  USING (true);

-- ALL: Service role full access
CREATE POLICY "Service role full access <table_name>"
  ON <table_name>
  FOR ALL
  TO service_role
  USING (true);
```

### Template 4: Admin-Only Management

Use for critical tables that only admins should modify.

```sql
-- Enable RLS
ALTER TABLE <table_name> ENABLE ROW LEVEL SECURITY;

-- SELECT: All authenticated users can read
CREATE POLICY "Authenticated read <table_name>"
  ON <table_name>
  FOR SELECT
  TO authenticated
  USING (true);

-- INSERT/UPDATE/DELETE: Admin only
CREATE POLICY "Admin can manage <table_name>"
  ON <table_name>
  FOR ALL
  TO authenticated
  USING (
    auth.jwt() ->> 'role' = 'admin'
    OR auth.jwt() ->> 'email' IN (
      'admin1@altera.com',
      'admin2@altera.com'
    )
  );

-- Service role bypass
CREATE POLICY "Service role full access <table_name>"
  ON <table_name>
  FOR ALL
  TO service_role
  USING (true);
```

---

## Testing and Verification

### 1. Check RLS Status for All Tables

```sql
SELECT
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;
```

**Expected Output**: `rowsecurity = true` for protected tables

### 2. List All Policies

```sql
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

**Expected Output**: List of all 17+ policies

### 3. Test Policy Enforcement

```sql
-- Switch to authenticated role
SET ROLE authenticated;

-- Test read access
SELECT * FROM client_arr LIMIT 1;
-- Should succeed if policy allows

-- Test write access
INSERT INTO client_arr (client_name, arr_usd) VALUES ('Test', 100000);
-- Should succeed/fail based on policy

-- Reset role
RESET ROLE;
```

### 4. Verify Policy Coverage

```sql
-- Find tables with RLS enabled but no policies
SELECT
  t.tablename,
  t.rowsecurity,
  COUNT(p.policyname) as policy_count
FROM pg_tables t
LEFT JOIN pg_policies p ON t.tablename = p.tablename AND t.schemaname = p.schemaname
WHERE t.schemaname = 'public'
  AND t.rowsecurity = true
GROUP BY t.tablename, t.rowsecurity
HAVING COUNT(p.policyname) = 0;
```

**Expected Output**: Should show 3 tables (segmentation_events, etc.)

---

## Implementation Checklist

### Immediate Actions (High Priority)

- [ ] Add policies to `client_segmentation` table
- [ ] Add policies to `segmentation_events` table
- [ ] Add policies to `segmentation_compliance_scores` table
- [ ] Remove anon access from `segmentation_event_compliance`
- [ ] Audit core tables (nps_clients, nps_responses, actions, unified_meetings)

### Security Enhancements (Medium Priority)

- [ ] Add CSE-level restrictions to `client_arr`
- [ ] Restrict event type modifications to admin users
- [ ] Add audit logging for policy violations
- [ ] Document current user authentication method

### Documentation (Low Priority)

- [ ] Create security runbook for RLS incidents
- [ ] Document role-based access control (RBAC) strategy
- [ ] Add RLS testing to CI/CD pipeline

---

## Related Documentation

- [Supabase RLS Documentation](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL RLS Policies](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- Phase 3 Task 19: RLS Audit Report (to be created)
- Security Incident Response Plan (to be created)

---

## Change Log

| Date       | Version | Changes                                        | Author      |
| ---------- | ------- | ---------------------------------------------- | ----------- |
| 2025-12-02 | 1.0     | Initial documentation of existing RLS policies | Claude Code |
| TBD        | 1.1     | Add audit findings for core tables             | TBD         |
| TBD        | 1.2     | Implement missing policies                     | TBD         |

---

## Notes

- **Authentication Method**: Assuming Supabase Auth with `current_user` returning user email
- **Testing**: All policies should be tested in development environment before production
- **Performance**: Complex RLS policies with subqueries may impact query performance
- **Audit Trail**: Consider enabling `pg_audit` extension for compliance tracking
