# Database Gotchas

## 1. Column Name Casing (CRITICAL)

**`actions` table uses CAPITALIZED column names:**
- `Action_ID`, `Action_Description`, `Owners`, `Due_Date`, `Status`, `Priority`, `Notes`, `Category`, `Completed_At`, `Is_Shared`
- Lowercase only: `id`, `client`, `created_at`, `updated_at`, `client_id`, `client_uuid`

**`topics` table uses CAPITALIZED column names:**
- `Meeting_Date`, `Topic_Number`, `Topic_Title`, `Topic_Summary`, `Background`, `Key_Details`

**Why it matters**: Queries using wrong case fail silently in try/catch blocks. Always verify against `docs/database-schema.md`.

## 2. NPS Display Format (CRITICAL)

- **NPS score (display)**: -100 to +100 range (e.g., "NPS: +45", "NPS: -12")
- **Individual response score**: 0-10 (NOT called "NPS")
- **Calculation**: (promoters - detractors) / total x 100
- **Promoters**: 9-10; **Detractors**: 0-6
- **Common mistake**: Showing individual score as NPS or calculating manually from score lists

## 3. Support Metrics Column Traps (CRITICAL)

- **Backlog field**: `backlog` (NOT `open_cases`)
- **SLA compliance**: `resolution_sla_percent` (NOT `sla_compliance_percent`)
- **CSAT score**: `satisfaction_score` 0-5 scale (NOT `csat_score`)
- **Query source**: Use `support_sla_latest` VIEW, NOT `support_cases` table
- **Aging buckets**: `aging_0_7d`, `aging_8_30d`, `aging_31_60d`, `aging_61_90d`, `aging_90d_plus`

## 4. Financial Data Sources (CRITICAL)

**Always use `burc_annual_financials` for totals. NEVER sum detail tables.**

Detail tables have double-counting and category overlaps. `burc_annual_financials` is the authoritative snapshot.

## 5. Client Name Resolution

- `client_name_aliases` contains garbage prefixes: "CONFIRMED,", "Re,", "PLACEHOLDER,"
- Legitimate commas exist: "Dept of Health, Victoria", "Ministry of Defence, Singapore"
- **Best practice**: Use `resolve_client_name()` RPC for fuzzy matching
- **Fallback**: JOIN via `client_canonical_lookup` materialised view

## 6. News Article Client Mapping

- **Source of truth**: `news_article_clients` junction table
- **Misleading field**: `news_articles.matched_clients` (JSONB) is descriptive only
- **Always JOIN** `news_article_clients` for client-article relationships

## 7. Meeting Sessions Type Mismatch

- `meeting_sessions.meeting_id` references `unified_meetings.id` which is **INTEGER**, not UUID
- If using UUID in FK, queries silently return no rows
- Cast to INTEGER when joining

## 8. Goal Tables Empty or RLS-Blocked

`company_goals`, `team_goals`, `goal_check_ins`, `goal_dependencies`, `goal_approvals`, `goal_audit_log` all show 0 rows.
- **Cause**: Either RLS policies blocking access or data not yet seeded
- **Diagnosis**: `SELECT policyname, cmd, roles FROM pg_policies WHERE tablename = 'table_name'`

## 9. Segmentation Completion Logic

- Only count where `completed = true` AND `event_date <= now()`
- Future events cannot be marked complete
- If completion % > 100%, check for `completed = true` with future `event_date`
- **Dedup**: UNIQUE on `(client_name, event_type_id, event_date)`. New insertion paths MUST handle `23505` (unique violation) or use `.upsert({ ignoreDuplicates: true })`
- **Source column**: NOT NULL, CHECK constraint — valid values: `dashboard`, `excel`, `bulk_import`, `briefing_room`, `api`
- **`content_hash`**: Auto-computed by trigger — do NOT set manually (it will be overwritten)

## 10. AI Field Naming Conventions

- **Meeting AI fields**: `sentiment_*`, `effectiveness_*`, `ai_*`
- **Action AI fields**: `ai_context`, `ai_context_key_points`, `ai_context_urgency_indicators`
- Always verify prefix before writing queries

## 11. Supabase Query `.in()` Bug

`.in()` breaks with commas in values — filter them out. Guard array responses with `Array.isArray()`.

## 12. Hook Response Parsing

API routes wrap arrays in named properties:
```javascript
// API returns: { data: { tasks: [...], stats: {} } }
// Hook must use: data.data?.tasks
// NOT: data.data (causes .map is not a function)
```

## 13. No `exec_sql` RPC

Use `pg` client with `DATABASE_URL_DIRECT` for direct SQL execution. See migration-workflow skill.

## 14. AR Aging Column Names

- Columns: `days_91_to_120`, `days_121_to_180` (NOT `ar_aging_*`)
- Table: `aging_accounts` (NOT `ar_aging`)
- `total_outstanding`, `total_overdue`, `is_inactive`

## 15. Support Case State Values

- NOT lowercase: `Closed`, `Canceled`, `Resolved`, `In Progress`, `On Hold`, `New`
- Resolution time: `resolution_duration_seconds` (divide by 3600 for hours)
- Open filter: `state NOT IN (Closed, Canceled, Resolved)`
