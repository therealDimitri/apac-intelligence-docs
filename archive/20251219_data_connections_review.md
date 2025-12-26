# Data Connections Audit Report

**Date:** 2025-12-19
**Auditor:** Claude Code
**Status:** Complete

## Executive Summary

A comprehensive review of all data connections in the APAC Intelligence v2 dashboard was conducted. The audit identified several discrepancies, primarily related to missing ChaSen tables and data that requires alias-based matching.

## Findings

### 1. ChaSen Knowledge Base ✅

| Metric         | Value                                                                   |
| -------------- | ----------------------------------------------------------------------- |
| Total Entries  | 15                                                                      |
| Active Entries | 15                                                                      |
| Categories     | business_rules, data_sources, definitions, formulas, general, processes |

**Status:** Healthy - All knowledge entries are active and properly categorised.

---

### 2. ChaSen Profiles ❌ MISSING TABLE

| Issue | Details                                                               |
| ----- | --------------------------------------------------------------------- |
| Table | `chasen_profiles`                                                     |
| Error | Could not find the table 'public.chasen_profiles' in the schema cache |

**Impact:** ChaSen cannot personalise responses based on user profiles.

**Recommendation:** Create the `chasen_profiles` table if user personalisation is required.

---

### 3. ChaSen Learning Tables ❌ MISSING TABLES

| Issue  | Details                                              |
| ------ | ---------------------------------------------------- |
| Tables | `chasen_learning_topics`, `chasen_learning_progress` |
| Error  | Could not find the tables in the schema cache        |

**Impact:** ChaSen learning/onboarding functionality is not available.

**Recommendation:** Create the learning tables if this feature is planned.

---

### 4. Client Data Consistency ✅

| Table                 | Count |
| --------------------- | ----- |
| client_health_summary | 18    |
| nps_clients           | 18    |

**Status:** Perfect match - All clients are present in both tables.

---

### 5. NPS Response Client Names ⚠️ REQUIRES ALIASES

| Response Name                            | Alias Status                |
| ---------------------------------------- | --------------------------- |
| Guam Regional Medical Centre             | ✅ Added today              |
| Ministry of Defence, Singapore           | ✅ Covered via alias lookup |
| St Luke's Medical Centre                 | ✅ Added today              |
| The Royal Victorian Eye and Ear Hospital | ✅ Has aliases              |
| Western Australia Department Of Health   | ✅ Has aliases              |

**Status:** All NPS response names are now covered by aliases after today's fixes.

---

### 6. Client Aliases ✅

| Metric                 | Value |
| ---------------------- | ----- |
| Active Aliases         | 37    |
| Unique Canonical Names | 17    |

**Status:** Alias coverage is comprehensive after today's additions.

---

### 7. Aging Accounts ⚠️ HANDLED BY AGGREGATION

The following normalised names don't directly match `nps_clients` but are handled by the Working Capital aggregation logic:

| Client     | Normalised Names (Aggregated)                                                                                                                                     |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| SingHealth | Changi General Hospital, KK Women's and Children's Hospital, National Cancer Centre, National Heart Centre, Sengkang General Hospital, Singapore General Hospital |
| GRMC       | GUAM Regional Medical City, Guam Regional Medical Centre                                                                                                          |
| SLMC       | St Luke's Medical Center Global City Inc                                                                                                                          |
| SA Health  | SA Health                                                                                                                                                         |
| RVEEH      | The Royal Victorian Eye and Ear Hospital                                                                                                                          |
| WA Health  | Western Australia Department Of Health                                                                                                                            |
| Epworth    | Epworth HealthCare                                                                                                                                                |
| GHA        | Gippsland Health Alliance                                                                                                                                         |
| NCS/MinDef | MinDef                                                                                                                                                            |

**Status:** These are handled by special aggregation rules in `client_health_summary` SQL.

---

### 8. Compliance Data ✅

| Metric                              | Value |
| ----------------------------------- | ----- |
| Clients in event_compliance_summary | 18    |

**Status:** Perfect match with `nps_clients`.

---

### 9. Unified Meetings ⚠️ EXPECTED BEHAVIOUR

| Metric              | Value |
| ------------------- | ----- |
| Unique client names | 69    |
| Non-client entries  | ~60   |

**Non-client entries include:**

- Internal meetings (e.g., "APAC Client Success Connect", "Internal")
- Projects (e.g., "2026 APAC Marcom Planning")
- Team meetings (e.g., "APAC CS Connect", "APAC LEAD")

**Status:** This is expected - the meetings table contains both client and internal meetings.

---

### 10. Actions ⚠️ EXPECTED BEHAVIOUR

| Metric             | Value                                      |
| ------------------ | ------------------------------------------ |
| Unique clients     | 20                                         |
| Non-client entries | 3 (Internal, Team Management, All Clients) |

**Status:** Expected - some actions are not client-specific.

---

### 11. Notifications ⚠️ EMPTY

| Metric               | Value |
| -------------------- | ----- |
| Recent notifications | 0     |

**Status:** Notifications table is empty. May need initialisation or the notification system hasn't been triggered.

---

## Summary Table

| Component          | Status      | Action Required                    |
| ------------------ | ----------- | ---------------------------------- |
| ChaSen Knowledge   | ✅ Healthy  | None                               |
| ChaSen Profiles    | ❌ Missing  | Create table if needed             |
| ChaSen Learning    | ❌ Missing  | Create tables if needed            |
| Client Consistency | ✅ Healthy  | None                               |
| NPS Aliases        | ✅ Fixed    | None (fixed today)                 |
| Aging Accounts     | ✅ Handled  | None (aggregation logic)           |
| Compliance         | ✅ Healthy  | None                               |
| Meetings           | ⚠️ Expected | None (internal meetings expected)  |
| Actions            | ⚠️ Expected | None (non-client actions expected) |
| Notifications      | ⚠️ Empty    | Investigate if needed              |

## Recommendations

### High Priority

1. **Decide on ChaSen Profiles/Learning** - If these features are needed, create the tables. If not, remove references from the codebase.

### Medium Priority

2. **Notifications Table** - Verify if notifications should be populated and if the trigger mechanism is working.

### Low Priority

3. **Document Alias Requirements** - When adding new clients or importing NPS data, ensure corresponding aliases are created.

## Data Flow Diagram

```
nps_clients (18 clients)
    │
    ├──► client_health_summary (materialized view)
    │       │
    │       ├── NPS data (via aliases)
    │       ├── Compliance data (via aliases)
    │       ├── Working Capital (via aggregation)
    │       └── Meetings/Actions (via aliases)
    │
    ├──► event_compliance_summary (18 clients)
    │
    └──► client_name_aliases (37 active)
            │
            ├── nps_responses (16 unique names → mapped)
            ├── aging_accounts (20 unique names → aggregated)
            └── unified_meetings (69 names, 18 clients)
```

## Audit Complete

All critical data connections have been verified. The NPS alias issues identified earlier today have been resolved. The main outstanding items are the missing ChaSen tables (profiles, learning) which may or may not be required depending on feature roadmap.
