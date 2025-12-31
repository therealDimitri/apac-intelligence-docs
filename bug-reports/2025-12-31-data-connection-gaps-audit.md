# Bug Report: Data Connection Gaps Audit

**Date:** 31 December 2025
**Severity:** High (Data Visibility Issues)
**Status:** In Progress

## Executive Summary

Comprehensive audit revealed significant gaps between available Supabase tables and dashboard integration. 82+ tables exist but are undocumented, ChaSen AI operates in isolation from the main dashboard, and several tables with data are never displayed.

---

## Issue 1: Undocumented Database Tables

**Problem:** 82+ tables are used in the codebase but not documented in `docs/database-schema.md`

**Impact:** Developers unaware of available data sources, schema validation incomplete

**Tables Missing from Documentation:**

### BURC Financial Tables (25+)
| Table | Purpose |
|-------|---------|
| burc_cash_metrics | Cash flow metrics |
| burc_client_maintenance | Client maintenance data |
| burc_cloud_costs | Cloud infrastructure costs |
| burc_cost_centre | Cost centre allocations |
| burc_csi_opex | CSI operating expenses |
| burc_csi_ratios | CSI ratio calculations |
| burc_customer_health | Customer health scores |
| burc_ebita_monthly | Monthly EBITA figures |
| burc_headcount | Headcount tracking |
| burc_implementation_backlog | Implementation backlog |
| burc_licence_bookings | Licence booking data |
| burc_maintenance_churn | Maintenance churn rates |
| burc_product_arr | Product ARR breakdown |
| burc_proposal_activity | Proposal activity |
| burc_ps_pipeline | PS pipeline data |
| burc_ps_utilisation | PS utilisation rates |
| burc_quarterly | Quarterly summaries |
| burc_rd_allocation | R&D allocation |
| burc_renewal_pipeline | Renewal pipeline |
| burc_revenue_streams | Revenue stream breakdown |
| burc_sales_pipeline | Sales pipeline |
| burc_support_metrics | Support metrics |
| burc_sync_log | Sync audit log |
| burc_waterfall | Waterfall analysis |

### ChaSen AI Tables (15+)
| Table | Purpose | Row Count |
|-------|---------|-----------|
| chasen_conversations | Conversation history | 115 |
| chasen_documents | Document storage | Active |
| chasen_learned_qa | Q&A patterns | Active |
| chasen_data_sources | Data source config | Active |
| chasen_knowledge | Knowledge base | 20 |
| chasen_knowledge_suggestions | Suggested entries | 12 |
| chasen_feedback | User feedback | 22 |
| chasen_folders | Folder structure | 7 |
| chasen_user_memories | User memory store | Active |
| chasen_user_preferences | User preferences | Active |
| chasen_learning_patterns | Learning patterns | 0 (empty) |
| chasen_success_patterns | Success patterns | Active |
| chasen_recommendation_interactions | Interactions | Active |
| chasen_conversation_messages | Messages | Active |
| chasen_implicit_signals | Implicit signals | Active |
| chasen_intent_logs | Intent logs | Active |
| chasen_analytics_daily | Daily analytics | Active |
| chasen_generation_log | Generation log | Active |

### Infrastructure Tables (20+)
| Table | Purpose |
|-------|---------|
| aging_compliance_summary | Compliance summary view |
| aged_accounts_history | AR history |
| aged_accounts_with_client_info | AR with client details |
| aging_alert_config | Alert configuration |
| aging_alerts_log | Alert history |
| client_arr | Client ARR data |
| client_compliance_predictions | Compliance predictions |
| client_event_compliance | Event compliance |
| client_health_summary | Health summary view |
| client_name_aliases | Name alias mapping |
| cse_assignment_suggestions | CSE suggestions |
| cse_client_assignments | CSE assignments |
| cse_profiles | CSE profile data |
| departments | Department list |
| email_logs | Email log |
| email_analytics_summary | Email analytics |
| email_events | Email events |
| email_sends | Email send records |
| email_signatures | Email signatures |
| email_templates | Email templates |
| event_compliance_by_type | Compliance by type |
| event_compliance_summary | Compliance summary |
| financial_actions | Financial actions |
| financial_alerts | Financial alerts |
| global_nps_benchmark | NPS benchmarks |
| llm_models | LLM model config |
| priority_matrix_assignments | Matrix assignments |
| saved_views | User saved views |
| segmentation_compliance_scores | Segment compliance |
| segmentation_event_compliance | Event compliance |
| segmentation_event_types | Event types |
| skipped_outlook_events | Skipped events |
| tier_requirements | Tier requirements |
| user_logins | Login tracking |
| webhook_logs | Webhook logs |
| webhook_subscriptions | Webhook config |
| brand_kits | Brand assets |

---

## Issue 2: ChaSen AI Not Integrated with Main Dashboard

**Problem:** ChaSen AI operates as an isolated system, not surfacing insights to the main ActionableIntelligenceDashboard

**Current State:**
- ChaSen has 115 conversations, 20 knowledge entries, 22 feedback items
- 40+ ChaSen API routes exist
- 15+ ChaSen components exist
- Main dashboard shows NO ChaSen data

**Impact:** AI-generated insights not visible to users on main dashboard

**Solution:** Add ChaSen insights widget to ActionableIntelligenceDashboard showing:
- Recent AI recommendations
- Knowledge base highlights
- Conversation sentiment trends
- Proactive alerts from ChaSen

---

## Issue 3: Tables with Data Not Displayed

**Problem:** Several tables contain data that's never shown to users

| Table | Rows | Issue |
|-------|------|-------|
| topics | 30 | Meeting topics never displayed |
| portfolio_initiatives | 6 | Initiatives never shown |
| health_status_alerts | 1 | Alerts not integrated |

**Solution:** Create widgets/views for each data source

---

## Issue 4: Empty Tables (Data Not Populating)

**Problem:** `chasen_learning_patterns` table has 0 rows

**Root Cause:** Likely RLS policy blocking inserts, or feature not enabled

**Solution:** Debug RLS policies and enable pattern learning

---

## Issue 5: BURC Data Not Visible

**Problem:** 25+ BURC financial tables exist with rich data, but no dashboard widgets display this information

**Current State:**
- API routes exist (`/api/analytics/burc/*`)
- CSI ratios page uses some data
- Main dashboard doesn't show financial summary

**Solution:** Add BURC financial summary widget to dashboard

---

## Implementation Plan

### Phase 1: Documentation (Priority 1)
- [ ] Update database-schema.md with all 82+ tables
- [ ] Add table relationships and RLS policies

### Phase 2: ChaSen Integration (Priority 2)
- [ ] Create ChaSenInsightsWidget component
- [ ] Add to ActionableIntelligenceDashboard
- [ ] Display recent recommendations and patterns

### Phase 3: Surface Hidden Data (Priority 3)
- [ ] Add topics trending to meetings section
- [ ] Create portfolio initiatives widget
- [ ] Connect health_status_alerts properly

### Phase 4: Fix Data Issues (Priority 4)
- [ ] Debug chasen_learning_patterns RLS
- [ ] Ensure patterns are being captured

### Phase 5: Financial Integration (Priority 5)
- [ ] Create BURC summary widget
- [ ] Add to dashboard or create dedicated view

---

## Files to Modify

| File | Changes |
|------|---------|
| docs/database-schema.md | Add 82+ missing tables |
| src/components/ActionableIntelligenceDashboard.tsx | Add ChaSen widget |
| src/components/chasen/ChaSenInsightsWidget.tsx | New component |
| src/app/(dashboard)/page.tsx | Integrate new widgets |
| src/hooks/useChaSenInsights.ts | New hook for dashboard data |

---

## Success Criteria

1. All 82+ tables documented in schema docs
2. ChaSen insights visible on main dashboard
3. Topics trending displayed in meetings section
4. Portfolio initiatives widget active
5. Health alerts properly connected
6. chasen_learning_patterns populating
7. BURC financial summary visible
