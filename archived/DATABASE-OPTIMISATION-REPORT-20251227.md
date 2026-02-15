# Database Optimisation Report

**Date:** 2025-12-27
**Database:** Supabase PostgreSQL (usoyxsunetvxdjdglkmn)
**Backup Location:** `backups/supabase-20251227-141416/`

---

## Executive Summary

The database contains **89 tables**, **422 indexes**, **41 foreign keys**, **19 views**, **3 materialized views**, **359 functions**, **55 triggers**, and **246 RLS policies**.

### Key Findings

| Category | Count | Status |
|----------|-------|--------|
| Empty tables (0 rows) | 24 | ⚠️ Review for removal |
| Tables with < 10 rows | 18 | Monitor |
| Tables with > 100 rows | 13 | Active |
| Duplicate/redundant table groups | 8 | ⚠️ Consolidate |
| Tables needing `client_uuid` | 23 | ⚠️ Migration needed |
| Tables with no RLS | 5 | ⚠️ Security review |
| Tables with excessive columns (50+) | 1 | ⚠️ Consider normalisation |

---

## 1. Empty Tables (24 tables)

These tables have 0 rows and may be candidates for removal or are unused features:

| Table | Purpose | Recommendation |
|-------|---------|----------------|
| `action_comments` | Action comments | Keep (feature ready) |
| `action_owner_completions` | Owner tracking | Keep (feature ready) |
| `aging_accounts_history` | **Duplicate** of `aged_accounts_history` | **DELETE** |
| `aging_alerts_log` | Alert logging | Keep (feature ready) |
| `audit_log` | User audit | Keep (critical) |
| `chasen_analytics_daily` | ChaSen analytics | Keep (analytics) |
| `chasen_intent_logs` | Intent tracking | Keep (ML feature) |
| `chasen_learned_qa` | Self-learning Q&A | Keep (ML feature) |
| `chasen_learning_patterns` | Learning patterns | Keep (ML feature) |
| `chasen_user_preferences` | User preferences | Keep (personalisation) |
| `client_impact_links` | Impact tracking | Review usage |
| `conversation_embeddings` | Vector embeddings | Keep (AI feature) |
| `cse_assignment_suggestions` | CSE suggestions | Keep (feature ready) |
| `email_logs` | Email tracking | Keep (feature ready) |
| `email_signatures` | Signatures | Keep (feature ready) |
| `email_template_analytics` | Template analytics | Keep (feature ready) |
| `error_logs` | Error logging | Keep (critical) |
| `event_schedule_templates` | Scheduling | Review usage |
| `initiatives` | Strategic initiatives | Review usage |
| `query_performance_logs` | Performance | Keep (monitoring) |
| `saved_views` | User views | Keep (feature ready) |
| `slow_query_alerts` | Alerts | Keep (monitoring) |
| `webhook_logs` | Webhook logging | Keep (feature ready) |
| `webhook_subscriptions` | Webhooks | Keep (feature ready) |

---

## 2. Duplicate/Redundant Tables

### 2.1 AGING Group (6 tables)

| Table | Rows | Recommendation |
|-------|------|----------------|
| `aged_accounts_history` | 427 | **KEEP** - Active history |
| `aging_accounts` | 20 | **KEEP** - Current state |
| `aging_accounts_history` | 0 | **DELETE** - Empty duplicate |
| `aging_alert_config` | 2 | Keep - Configuration |
| `aging_alerts_log` | 0 | Keep - Feature ready |
| `aging_compliance_history` | 6 | Keep - Compliance |

### 2.2 CLIENT Group (15 tables)

| Table | Rows | Recommendation |
|-------|------|----------------|
| `clients` | 32 | **KEEP** - Master table |
| `client_aliases_unified` | 77 | **KEEP** - New alias system |
| `client_name_aliases` | 49 | **DEPRECATE** - Legacy aliases |
| `nps_clients` | 18 | **REVIEW** - Mostly empty, FKs reference it |
| `client_arr` | 16 | Keep - ARR data |
| `client_event_exclusions` | 41 | Keep - Exclusions |
| `client_health_history` | 540 | Keep - Health tracking |
| `client_impact_links` | 0 | Review - Unused |
| `client_logos` | 19 | Keep - Branding |
| `client_meetings` | 41 | **REVIEW** - vs unified_meetings |
| `client_segmentation` | 26 | Keep - Segmentation |
| `client_unresolved_names` | 56 | Keep - Migration tracking |
| `cse_client_assignments` | 25 | Keep - Assignments |
| `nps_client_priority` | 13 | Keep - Priorities |
| `nps_client_trends` | 18 | Keep - Trends |

### 2.3 MEETING Group (4 tables)

| Table | Rows | Columns | Recommendation |
|-------|------|---------|----------------|
| `unified_meetings` | 135 | 54 | **KEEP** - Primary table |
| `client_meetings` | 41 | 19 | **REVIEW** - Consolidate into unified? |
| `meetings` | 7 | 12 | **REVIEW** - Purpose overlap? |
| `test_meetings` | 10 | 11 | **DELETE** - Test data |

### 2.4 NPS Group (11 tables)

Many NPS tables exist - consider consolidation:
- `nps_clients` (18 rows) - **Mostly empty, but has FK references**
- `nps_responses` (199 rows) - Primary response data
- `nps_topic_classifications` (198 rows) - Topic analysis
- `global_nps_benchmark` (404 rows) - Benchmarking

### 2.5 CHASEN Group (15 tables)

ChaSen has many feature tables - most are active and needed:
- Core: `chasen_conversations` (115), `chasen_conversation_messages` (1035)
- Learning: `chasen_feedback` (22), `chasen_implicit_signals` (196)
- Empty but needed: `chasen_learned_qa`, `chasen_learning_patterns`

---

## 3. Schema Inconsistencies

### 3.1 Tables with BOTH `client_id` AND `client_uuid`

These were migrated but have dual columns:

| Table | client_id Type | client_uuid Type |
|-------|---------------|------------------|
| `actions` | integer | uuid |
| `aging_accounts` | integer | uuid |
| `client_segmentation` | varchar | uuid |
| `nps_responses` | integer | uuid |
| `unified_meetings` | integer | uuid |

**Action:** After application code migration, drop legacy `client_id` columns.

### 3.2 Tables with INTEGER `client_id` (Legacy FK to `nps_clients`)

| Table | Recommendation |
|-------|----------------|
| `actions` | Migrate FK to `clients.id` |
| `aging_accounts` | Migrate FK to `clients.id` |
| `client_impact_links` | Migrate FK to `clients.id` |
| `nps_responses` | Migrate FK to `clients.id` |
| `segmentation_events` | Migrate FK to `clients.id` |
| `unified_meetings` | Migrate FK to `clients.id` |

### 3.3 Tables Needing `client_uuid` Column (23 tables)

These tables use `client_name` string matching but don't have `client_uuid`:

**High Priority (active tables):**
- `aged_accounts_history` (427 rows)
- `segmentation_events` (790 rows)
- `client_meetings` (41 rows)
- `cse_client_assignments` (25 rows)
- `client_arr` (16 rows)

**Medium Priority:**
- `chasen_conversations`
- `chasen_folders`
- `chasen_documents`
- `comments`
- `portfolio_initiatives`
- `health_status_alerts`

**Lower Priority (reference/config tables):**
- `nps_clients`
- `client_logos`
- `test_meetings`

---

## 4. Index Analysis

### 4.1 Tables with Most Indexes

| Table | Index Count | Notes |
|-------|-------------|-------|
| `actions` | 21 | May be over-indexed |
| `unified_meetings` | 18 | May be over-indexed |
| `error_logs` | 10 | Appropriate for logging |
| `aging_accounts` | 8 | Appropriate |
| `clients` | 8 | Appropriate |

### 4.2 Recommended Index Additions

Add indexes for common query patterns using `client_uuid`:

```sql
-- Add after application code migrates to client_uuid
CREATE INDEX IF NOT EXISTS idx_unified_meetings_client_uuid ON unified_meetings(client_uuid);
CREATE INDEX IF NOT EXISTS idx_actions_client_uuid ON actions(client_uuid);
CREATE INDEX IF NOT EXISTS idx_nps_responses_client_uuid ON nps_responses(client_uuid);
```

---

## 5. RLS Security Analysis

### 5.1 Tables with Data but No RLS

| Table | Rows | Risk Level |
|-------|------|------------|
| `document_embeddings` | 250 | Medium |
| `chasen_implicit_signals` | 196 | Low |
| `client_unresolved_names` | 56 | Low |
| `client_event_exclusions` | 41 | Low |
| `chasen_user_memories` | 5 | Medium |

**Recommendation:** Add RLS policies for `document_embeddings` and `chasen_user_memories`.

### 5.2 Tables with Excessive RLS Policies

| Table | Policy Count | Recommendation |
|-------|--------------|----------------|
| `actions` | 15 | Review and consolidate |
| `client_meetings` | 8 | Review |
| `unified_meetings` | 7 | Review |

---

## 6. Column Bloat

### 6.1 Tables with 50+ Columns

| Table | Columns | Rows | Recommendation |
|-------|---------|------|----------------|
| `unified_meetings` | 54 | 135 | Consider normalisation |

**Unified_meetings columns to potentially move to related tables:**
- Outlook sync fields → `meeting_outlook_sync` table
- AI-generated fields → `meeting_ai_analysis` table
- Attendee fields → `meeting_attendees` table

---

## 7. Optimisation Recommendations

### Priority 1: Immediate (This Week)

1. **Delete test/duplicate tables:**
   ```sql
   DROP TABLE IF EXISTS test_meetings;
   DROP TABLE IF EXISTS aging_accounts_history; -- Empty duplicate
   ```

2. **Add deprecation comments:**
   ```sql
   COMMENT ON TABLE client_name_aliases IS 'DEPRECATED: Use client_aliases_unified';
   COMMENT ON TABLE nps_clients IS 'DEPRECATED: Use clients table';
   ```

3. **Add missing RLS policies:**
   - `document_embeddings`
   - `chasen_user_memories`

### Priority 2: Short-term (Next 2 Weeks)

1. **Complete client_uuid migration:**
   - Add `client_uuid` to remaining 23 tables
   - Update triggers to auto-populate
   - Update application code

2. **Consolidate meetings tables:**
   - Merge `client_meetings` into `unified_meetings`
   - Update all references

3. **Review `nps_clients` usage:**
   - Migrate FK references to `clients` table
   - Keep for backward compatibility or migrate

### Priority 3: Medium-term (Next Month)

1. **Normalise `unified_meetings`:**
   - Extract Outlook sync fields
   - Extract AI analysis fields
   - Improve query performance

2. **Consolidate RLS policies:**
   - Simplify `actions` (15 → 5 policies)
   - Create policy templates

3. **Archive old data:**
   - Consider partitioning for history tables
   - Archive `skipped_outlook_events` (203 rows)

---

## 8. Backup Verification

Backup created at: `backups/supabase-20251227-141416/`

| File | Size | Contents |
|------|------|----------|
| `schema.json` | 213KB | Full table schemas |
| `indexes.json` | 101KB | All 422 indexes |
| `rls_policies.json` | 69KB | All 246 policies |
| `functions.json` | 41KB | All 359 functions |
| `views.json` | 14KB | All 19 views |
| `materialized_views.json` | 16KB | All 3 mat views |
| `triggers.json` | 12KB | All 55 triggers |
| `foreign_keys.json` | 9KB | All 41 FKs |
| `row_counts.json` | 2KB | Row counts |
| `tables.json` | 2KB | Table list |

---

## 9. Next Steps

1. Review this report with team
2. Approve deletion of test/duplicate tables
3. Schedule client_uuid migration for remaining tables
4. Plan unified_meetings normalisation
5. Implement RLS for sensitive tables

---

*Report generated by Claude Code on 2025-12-27*
