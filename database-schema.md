# Database Schema Documentation

**Generated**: 2026-01-08T13:12:44.804Z
**Purpose**: Source of truth for all database table schemas

---

## Overview

This document provides the authoritative schema definition for all tables in the APAC Intelligence database. **Always reference this document when writing queries or TypeScript interfaces.**

## Table: `actions`

**Row Count**: 159

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | integer | ✗ | - | *(inferred)* |
| `Action_ID` | text | ✗ | - | *(inferred)* |
| `Action_Description` | text | ✗ | - | *(inferred)* |
| `Owners` | text | ✗ | - | *(inferred)* |
| `Due_Date` | text | ✗ | - | *(inferred)* |
| `Status` | text | ✗ | - | *(inferred)* |
| `Priority` | text | ✗ | - | *(inferred)* |
| `Content_Topic` | unknown | ✗ | - | *(inferred)* |
| `Meeting_Date` | unknown | ✗ | - | *(inferred)* |
| `Topic_Number` | unknown | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |
| `Notes` | text | ✗ | - | *(inferred)* |
| `Shared_Action_Id` | unknown | ✗ | - | *(inferred)* |
| `Is_Shared` | boolean | ✗ | - | *(inferred)* |
| `Completed_At` | unknown | ✗ | - | *(inferred)* |
| `meeting_id` | unknown | ✗ | - | *(inferred)* |
| `outlook_task_id` | unknown | ✗ | - | *(inferred)* |
| `teams_message_id` | unknown | ✗ | - | *(inferred)* |
| `last_synced_at` | unknown | ✗ | - | *(inferred)* |
| `edit_history` | array | ✗ | - | *(inferred)* |
| `client` | text | ✗ | - | *(inferred)* |
| `Category` | text | ✗ | - | *(inferred)* |
| `department_code` | unknown | ✗ | - | *(inferred)* |
| `activity_type_code` | unknown | ✗ | - | *(inferred)* |
| `is_internal` | boolean | ✗ | - | *(inferred)* |
| `cross_functional` | boolean | ✗ | - | *(inferred)* |
| `linked_initiative_id` | unknown | ✗ | - | *(inferred)* |
| `client_id` | unknown | ✗ | - | *(inferred)* |
| `ai_context` | unknown | ✗ | - | *(inferred)* |
| `ai_context_key_points` | array | ✗ | - | *(inferred)* |
| `ai_context_urgency_indicators` | array | ✗ | - | *(inferred)* |
| `ai_context_related_topics` | array | ✗ | - | *(inferred)* |
| `ai_context_confidence` | unknown | ✗ | - | *(inferred)* |
| `ai_context_generated_at` | unknown | ✗ | - | *(inferred)* |
| `ai_context_meeting_title` | unknown | ✗ | - | *(inferred)* |
| `client_uuid` | unknown | ✗ | - | *(inferred)* |
| `source` | text | ✗ | - | *(inferred)* |
| `source_metadata` | jsonb | ✗ | - | *(inferred)* |
| `created_by` | unknown | ✗ | - | *(inferred)* |
| `source_alert_text_id` | unknown | ✗ | - | *(inferred)* |
| `source_alert_id` | unknown | ✗ | - | *(inferred)* |
| `tags` | array | ✗ | - | *(inferred)* |

---

## Table: `unified_meetings`

**Row Count**: 204

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | integer | ✗ | - | *(inferred)* |
| `meeting_id` | text | ✗ | - | *(inferred)* |
| `client_name` | text | ✗ | - | *(inferred)* |
| `cse_name` | text | ✗ | - | *(inferred)* |
| `meeting_date` | text | ✗ | - | *(inferred)* |
| `meeting_time` | text | ✗ | - | *(inferred)* |
| `duration` | integer | ✗ | - | *(inferred)* |
| `meeting_type` | text | ✗ | - | *(inferred)* |
| `meeting_notes` | text | ✗ | - | *(inferred)* |
| `transcript` | unknown | ✗ | - | *(inferred)* |
| `recording_url` | unknown | ✗ | - | *(inferred)* |
| `ai_analyzed` | boolean | ✗ | - | *(inferred)* |
| `ai_summary` | unknown | ✗ | - | *(inferred)* |
| `ai_confidence_score` | unknown | ✗ | - | *(inferred)* |
| `ai_tokens_used` | unknown | ✗ | - | *(inferred)* |
| `ai_cost` | unknown | ✗ | - | *(inferred)* |
| `sentiment_overall` | unknown | ✗ | - | *(inferred)* |
| `sentiment_score` | unknown | ✗ | - | *(inferred)* |
| `sentiment_client` | unknown | ✗ | - | *(inferred)* |
| `sentiment_cse` | unknown | ✗ | - | *(inferred)* |
| `effectiveness_overall` | unknown | ✗ | - | *(inferred)* |
| `effectiveness_preparation` | unknown | ✗ | - | *(inferred)* |
| `effectiveness_participation` | unknown | ✗ | - | *(inferred)* |
| `effectiveness_clarity` | unknown | ✗ | - | *(inferred)* |
| `effectiveness_outcomes` | unknown | ✗ | - | *(inferred)* |
| `effectiveness_follow_up` | unknown | ✗ | - | *(inferred)* |
| `effectiveness_time_management` | unknown | ✗ | - | *(inferred)* |
| `topics` | array | ✗ | - | *(inferred)* |
| `risks` | array | ✗ | - | *(inferred)* |
| `highlights` | unknown | ✗ | - | *(inferred)* |
| `next_steps` | array | ✗ | - | *(inferred)* |
| `outlook_event_id` | unknown | ✗ | - | *(inferred)* |
| `teams_meeting_id` | unknown | ✗ | - | *(inferred)* |
| `synced_to_outlook` | boolean | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |
| `analyzed_at` | unknown | ✗ | - | *(inferred)* |
| `transcript_file_url` | text | ✗ | - | *(inferred)* |
| `recording_file_url` | text | ✗ | - | *(inferred)* |
| `attendees` | text | ✗ | - | *(inferred)* |
| `meeting_dept` | text | ✗ | - | *(inferred)* |
| `status` | text | ✗ | - | *(inferred)* |
| `decisions` | array | ✗ | - | *(inferred)* |
| `resources` | array | ✗ | - | *(inferred)* |
| `organizer` | text | ✗ | - | *(inferred)* |
| `title` | text | ✗ | - | *(inferred)* |
| `deleted` | boolean | ✗ | - | *(inferred)* |
| `department_code` | unknown | ✗ | - | *(inferred)* |
| `activity_type_code` | unknown | ✗ | - | *(inferred)* |
| `is_internal` | boolean | ✗ | - | *(inferred)* |
| `cross_functional` | boolean | ✗ | - | *(inferred)* |
| `linked_initiative_id` | unknown | ✗ | - | *(inferred)* |
| `client_id` | unknown | ✗ | - | *(inferred)* |
| `client_uuid` | text | ✗ | - | *(inferred)* |

---

## Table: `nps_responses`

**Row Count**: 199

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | integer | ✗ | - | *(inferred)* |
| `client_name` | text | ✗ | - | *(inferred)* |
| `contact_name` | text | ✗ | - | *(inferred)* |
| `score` | integer | ✗ | - | *(inferred)* |
| `category` | text | ✗ | - | *(inferred)* |
| `feedback` | text | ✗ | - | *(inferred)* |
| `response_date` | unknown | ✗ | - | *(inferred)* |
| `period` | text | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `business_unit` | unknown | ✗ | - | *(inferred)* |
| `role` | unknown | ✗ | - | *(inferred)* |
| `cse_name` | unknown | ✗ | - | *(inferred)* |
| `contact_email` | unknown | ✗ | - | *(inferred)* |
| `region` | unknown | ✗ | - | *(inferred)* |
| `client_id` | integer | ✗ | - | *(inferred)* |
| `client_uuid` | text | ✗ | - | *(inferred)* |

---

## Table: `client_segmentation`

**Row Count**: 26

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `client_name` | text | ✗ | - | *(inferred)* |
| `client_id` | unknown | ✗ | - | *(inferred)* |
| `tier_id` | text | ✗ | - | *(inferred)* |
| `cse_name` | text | ✗ | - | *(inferred)* |
| `cse_id` | unknown | ✗ | - | *(inferred)* |
| `effective_from` | text | ✗ | - | *(inferred)* |
| `effective_to` | unknown | ✗ | - | *(inferred)* |
| `notes` | text | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |
| `created_by` | unknown | ✗ | - | *(inferred)* |
| `client_uuid` | text | ✗ | - | *(inferred)* |

---

## Table: `topics`

**Row Count**: 30

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | integer | ✗ | - | *(inferred)* |
| `Meeting_Date` | text | ✗ | - | *(inferred)* |
| `Topic_Number` | integer | ✗ | - | *(inferred)* |
| `Topic_Title` | text | ✗ | - | *(inferred)* |
| `Topic_Summary` | text | ✗ | - | *(inferred)* |
| `Background` | text | ✗ | - | *(inferred)* |
| `Key_Details` | text | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |

---

## Table: `aging_accounts`

**Row Count**: 11

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | integer | ✗ | - | *(inferred)* |
| `cse_name` | text | ✗ | - | *(inferred)* |
| `client_name` | text | ✗ | - | *(inferred)* |
| `client_name_normalized` | text | ✗ | - | *(inferred)* |
| `most_recent_comment` | text | ✗ | - | *(inferred)* |
| `current_amount` | integer | ✗ | - | *(inferred)* |
| `days_1_to_30` | integer | ✗ | - | *(inferred)* |
| `days_31_to_60` | integer | ✗ | - | *(inferred)* |
| `days_61_to_90` | integer | ✗ | - | *(inferred)* |
| `days_91_to_120` | integer | ✗ | - | *(inferred)* |
| `days_121_to_180` | integer | ✗ | - | *(inferred)* |
| `days_181_to_270` | integer | ✗ | - | *(inferred)* |
| `days_271_to_365` | integer | ✗ | - | *(inferred)* |
| `days_over_365` | integer | ✗ | - | *(inferred)* |
| `total_outstanding` | integer | ✗ | - | *(inferred)* |
| `total_overdue` | integer | ✗ | - | *(inferred)* |
| `is_inactive` | boolean | ✗ | - | *(inferred)* |
| `data_source` | text | ✗ | - | *(inferred)* |
| `import_date` | text | ✗ | - | *(inferred)* |
| `week_ending_date` | text | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |
| `client_id` | unknown | ✗ | - | *(inferred)* |
| `client_uuid` | text | ✗ | - | *(inferred)* |

---

## Table: `notifications`

**Row Count**: 15

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `user_id` | text | ✗ | - | *(inferred)* |
| `user_email` | unknown | ✗ | - | *(inferred)* |
| `type` | text | ✗ | - | *(inferred)* |
| `title` | text | ✗ | - | *(inferred)* |
| `message` | text | ✗ | - | *(inferred)* |
| `link` | text | ✗ | - | *(inferred)* |
| `item_id` | text | ✗ | - | *(inferred)* |
| `comment_id` | text | ✗ | - | *(inferred)* |
| `triggered_by` | text | ✗ | - | *(inferred)* |
| `triggered_by_avatar` | text | ✗ | - | *(inferred)* |
| `read` | boolean | ✗ | - | *(inferred)* |
| `read_at` | unknown | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |

---

## Table: `portfolio_initiatives`

**Row Count**: 6

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `name` | text | ✗ | - | *(inferred)* |
| `client_name` | text | ✗ | - | *(inferred)* |
| `cse_name` | text | ✗ | - | *(inferred)* |
| `year` | integer | ✗ | - | *(inferred)* |
| `status` | text | ✗ | - | *(inferred)* |
| `category` | text | ✗ | - | *(inferred)* |
| `start_date` | text | ✗ | - | *(inferred)* |
| `completion_date` | text | ✗ | - | *(inferred)* |
| `description` | text | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |
| `client_id` | text | ✗ | - | *(inferred)* |

---

## Table: `nps_topic_classifications`

**Row Count**: 199

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `response_id` | text | ✗ | - | *(inferred)* |
| `topic_name` | text | ✗ | - | *(inferred)* |
| `sentiment` | text | ✗ | - | *(inferred)* |
| `confidence_score` | numeric | ✗ | - | *(inferred)* |
| `insight` | text | ✗ | - | *(inferred)* |
| `model_version` | text | ✗ | - | *(inferred)* |
| `classified_at` | text | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |

---

## Table: `nps_period_config`

**Row Count**: 5

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `period_code` | text | ✗ | - | *(inferred)* |
| `period_name` | text | ✗ | - | *(inferred)* |
| `fiscal_year` | text | ✗ | - | *(inferred)* |
| `period_type` | text | ✗ | - | *(inferred)* |
| `surveys_sent` | integer | ✗ | - | *(inferred)* |
| `survey_start_date` | text | ✗ | - | *(inferred)* |
| `survey_end_date` | text | ✗ | - | *(inferred)* |
| `sort_order` | integer | ✗ | - | *(inferred)* |
| `is_active` | boolean | ✗ | - | *(inferred)* |
| `notes` | text | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |

---

## Table: `chasen_knowledge`

**Row Count**: 20

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `category` | text | ✗ | - | *(inferred)* |
| `knowledge_key` | text | ✗ | - | *(inferred)* |
| `title` | text | ✗ | - | *(inferred)* |
| `content` | text | ✗ | - | *(inferred)* |
| `metadata` | jsonb | ✗ | - | *(inferred)* |
| `priority` | integer | ✗ | - | *(inferred)* |
| `is_active` | boolean | ✗ | - | *(inferred)* |
| `version` | integer | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |
| `created_by` | unknown | ✗ | - | *(inferred)* |
| `updated_by` | unknown | ✗ | - | *(inferred)* |

---

## Table: `chasen_feedback`

**Row Count**: 22

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `conversation_id` | text | ✗ | - | *(inferred)* |
| `message_index` | integer | ✗ | - | *(inferred)* |
| `user_query` | text | ✗ | - | *(inferred)* |
| `chasen_response` | text | ✗ | - | *(inferred)* |
| `rating` | text | ✗ | - | *(inferred)* |
| `feedback_text` | unknown | ✗ | - | *(inferred)* |
| `knowledge_entries_used` | array | ✗ | - | *(inferred)* |
| `confidence_score` | unknown | ✗ | - | *(inferred)* |
| `user_email` | text | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `processed` | boolean | ✗ | - | *(inferred)* |
| `processed_at` | unknown | ✗ | - | *(inferred)* |
| `feedback_category` | unknown | ✗ | - | *(inferred)* |
| `feedback_subcategory` | unknown | ✗ | - | *(inferred)* |
| `correction_text` | unknown | ✗ | - | *(inferred)* |
| `detected_intent` | unknown | ✗ | - | *(inferred)* |
| `response_time_ms` | unknown | ✗ | - | *(inferred)* |
| `model_used` | unknown | ✗ | - | *(inferred)* |
| `rag_chunks_used` | array | ✗ | - | *(inferred)* |
| `session_id` | unknown | ✗ | - | *(inferred)* |

---

## Table: `chasen_knowledge_suggestions`

**Row Count**: 12

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `source_type` | text | ✗ | - | *(inferred)* |
| `source_id` | text | ✗ | - | *(inferred)* |
| `source_context` | jsonb | ✗ | - | *(inferred)* |
| `suggested_category` | text | ✗ | - | *(inferred)* |
| `suggested_key` | text | ✗ | - | *(inferred)* |
| `suggested_title` | text | ✗ | - | *(inferred)* |
| `suggested_content` | text | ✗ | - | *(inferred)* |
| `suggested_priority` | integer | ✗ | - | *(inferred)* |
| `confidence_score` | numeric | ✗ | - | *(inferred)* |
| `status` | text | ✗ | - | *(inferred)* |
| `reviewed_by` | text | ✗ | - | *(inferred)* |
| `reviewed_at` | text | ✗ | - | *(inferred)* |
| `review_notes` | unknown | ✗ | - | *(inferred)* |
| `merged_to_id` | text | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |

---

## Table: `chasen_learning_patterns`

**Row Count**: 0

**Note**: Empty table or RLS blocking access

---

## Table: `chasen_conversations`

**Row Count**: 127

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `user_email` | text | ✗ | - | *(inferred)* |
| `title` | text | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |
| `message_count` | integer | ✗ | - | *(inferred)* |
| `last_message_preview` | text | ✗ | - | *(inferred)* |
| `context` | text | ✗ | - | *(inferred)* |
| `client_name` | unknown | ✗ | - | *(inferred)* |
| `model_id` | unknown | ✗ | - | *(inferred)* |
| `client_id` | unknown | ✗ | - | *(inferred)* |
| `is_pinned` | boolean | ✗ | - | *(inferred)* |

---

## Table: `chasen_folders`

**Row Count**: 7

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `name` | text | ✗ | - | *(inferred)* |
| `parent_id` | unknown | ✗ | - | *(inferred)* |
| `client_name` | unknown | ✗ | - | *(inferred)* |
| `description` | text | ✗ | - | *(inferred)* |
| `color` | text | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |
| `client_id` | unknown | ✗ | - | *(inferred)* |

---

## Table: `client_health_history`

**Row Count**: 594

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `client_name` | text | ✗ | - | *(inferred)* |
| `snapshot_date` | text | ✗ | - | *(inferred)* |
| `health_score` | integer | ✗ | - | *(inferred)* |
| `status` | text | ✗ | - | *(inferred)* |
| `nps_points` | integer | ✗ | - | *(inferred)* |
| `compliance_points` | integer | ✗ | - | *(inferred)* |
| `working_capital_points` | integer | ✗ | - | *(inferred)* |
| `nps_score` | integer | ✗ | - | *(inferred)* |
| `compliance_percentage` | integer | ✗ | - | *(inferred)* |
| `working_capital_percentage` | integer | ✗ | - | *(inferred)* |
| `previous_status` | unknown | ✗ | - | *(inferred)* |
| `status_changed` | boolean | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `client_id` | text | ✗ | - | *(inferred)* |
| `health_score_version` | text | ✗ | - | *(inferred)* |
| `actions_points` | unknown | ✗ | - | *(inferred)* |
| `revenue_trend_points` | unknown | ✗ | - | *(inferred)* |
| `contract_status_points` | unknown | ✗ | - | *(inferred)* |
| `support_health_points` | unknown | ✗ | - | *(inferred)* |
| `expansion_points` | unknown | ✗ | - | *(inferred)* |
| `primary_concern_category` | unknown | ✗ | - | *(inferred)* |
| `revenue_growth_percentage` | unknown | ✗ | - | *(inferred)* |
| `renewal_risk_level` | unknown | ✗ | - | *(inferred)* |

---

## Table: `health_status_alerts`

**Row Count**: 1

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `client_name` | text | ✗ | - | *(inferred)* |
| `alert_date` | text | ✗ | - | *(inferred)* |
| `previous_status` | text | ✗ | - | *(inferred)* |
| `new_status` | text | ✗ | - | *(inferred)* |
| `previous_score` | integer | ✗ | - | *(inferred)* |
| `new_score` | integer | ✗ | - | *(inferred)* |
| `direction` | text | ✗ | - | *(inferred)* |
| `acknowledged` | boolean | ✗ | - | *(inferred)* |
| `acknowledged_by` | text | ✗ | - | *(inferred)* |
| `acknowledged_at` | text | ✗ | - | *(inferred)* |
| `cse_name` | text | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `client_id` | text | ✗ | - | *(inferred)* |

---

## Table: `account_plan_ai_insights`

**Purpose**: Stores AI-generated insights for account plans including risks, opportunities, and recommendations.

**Row Count**: 0 (new table)

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | uuid | ✗ | gen_random_uuid() | Primary key |
| `client_id` | uuid | ✓ | - | Optional FK to clients table |
| `client_name` | text | ✗ | - | Client name for display |
| `insight_type` | text | ✗ | - | Type: 'risk', 'opportunity', 'action', 'stakeholder', 'meddpicc' |
| `insight_category` | text | ✓ | - | Category: 'engagement', 'financial', 'sentiment', 'relationship' |
| `title` | text | ✗ | - | Short insight title |
| `description` | text | ✗ | - | Full insight description |
| `confidence_score` | decimal(3,2) | ✓ | - | AI confidence 0.00 to 1.00 |
| `priority` | text | ✓ | - | Priority: 'critical', 'high', 'medium', 'low' |
| `impact_score` | integer | ✓ | - | Impact rating 1-10 |
| `data_sources` | jsonb | ✓ | - | Array of source references used |
| `recommended_actions` | jsonb | ✓ | - | Array of suggested actions |
| `is_dismissed` | boolean | ✓ | false | Whether insight was dismissed |
| `dismissed_by` | text | ✓ | - | Who dismissed it |
| `dismissed_at` | timestamptz | ✓ | - | When dismissed |
| `created_at` | timestamptz | ✓ | NOW() | Creation timestamp |
| `expires_at` | timestamptz | ✓ | - | When insight expires |

### Indexes

- `idx_insights_client` - (client_id, insight_type)
- `idx_insights_client_name` - (client_name)
- `idx_insights_active` - (client_id) WHERE NOT is_dismissed AND expires_at > NOW()
- `idx_insights_type` - (insight_type)
- `idx_insights_priority` - (priority)
- `idx_insights_created` - (created_at DESC)

---

## Table: `next_best_actions`

**Purpose**: AI-recommended actions for CSEs/CAMs prioritised by impact and urgency.

**Row Count**: 0 (new table)

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | uuid | ✗ | gen_random_uuid() | Primary key |
| `client_id` | uuid | ✓ | - | Optional FK to clients table |
| `client_name` | text | ✗ | - | Client name for display |
| `cse_name` | text | ✓ | - | Assigned CSE |
| `cam_name` | text | ✓ | - | Assigned CAM |
| `action_type` | text | ✗ | - | Type: 'engagement', 'nps_followup', 'risk_mitigation', 'relationship', 'financial', 'expansion', 'action_completion' |
| `title` | text | ✗ | - | Action title |
| `description` | text | ✗ | - | Full action description |
| `priority_score` | decimal(5,2) | ✓ | - | Calculated priority (Impact x Urgency x Confidence) |
| `impact_category` | text | ✓ | - | Category: 'health', 'revenue', 'relationship', 'meddpicc' |
| `estimated_impact` | integer | ✓ | - | Estimated points improvement |
| `urgency_level` | text | ✓ | - | Urgency: 'immediate', 'this_week', 'this_month' |
| `trigger_reason` | text | ✓ | - | Why this action was recommended |
| `trigger_data` | jsonb | ✓ | - | Supporting trigger data |
| `status` | text | ✓ | 'pending' | Status: 'pending', 'accepted', 'completed', 'dismissed' |
| `accepted_at` | timestamptz | ✓ | - | When action was accepted |
| `completed_at` | timestamptz | ✓ | - | When action was completed |
| `dismissed_at` | timestamptz | ✓ | - | When action was dismissed |
| `dismissed_reason` | text | ✓ | - | Reason for dismissal |
| `created_at` | timestamptz | ✓ | NOW() | Creation timestamp |
| `expires_at` | timestamptz | ✓ | - | When action expires |

### Indexes

- `idx_nba_cse` - (cse_name, status)
- `idx_nba_cam` - (cam_name, status)
- `idx_nba_client` - (client_id, status)
- `idx_nba_client_name` - (client_name)
- `idx_nba_priority` - (priority_score DESC) WHERE status = 'pending'
- `idx_nba_action_type` - (action_type)
- `idx_nba_urgency` - (urgency_level, status)
- `idx_nba_created` - (created_at DESC)

---

## Table: `stakeholder_relationships`

**Purpose**: Stores relationship mapping data for visual org charts and influence mapping.

**Row Count**: 0 (new table)

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | uuid | ✗ | gen_random_uuid() | Primary key |
| `plan_id` | uuid | ✓ | - | References account_plans |
| `client_id` | uuid | ✓ | - | Optional FK to clients table |
| `client_name` | text | ✗ | - | Client name for display |
| `stakeholder_name` | text | ✗ | - | Full name of stakeholder |
| `stakeholder_email` | text | ✓ | - | Email address |
| `stakeholder_title` | text | ✓ | - | Job title |
| `stakeholder_role` | text | ✓ | - | Role: 'economic_buyer', 'champion', 'influencer', 'user', 'blocker', 'coach' |
| `meddpicc_role` | text | ✓ | - | MEDDPICC mapping: 'EB', 'Champion', 'Coach', 'User' |
| `department` | text | ✓ | - | Department name |
| `reports_to` | uuid | ✓ | - | Self-reference for org hierarchy |
| `influence_level` | integer | ✓ | - | Influence rating 1-10 |
| `engagement_score` | integer | ✓ | - | Calculated from meetings |
| `sentiment` | text | ✓ | - | Sentiment: 'positive', 'neutral', 'negative' |
| `last_interaction_date` | date | ✓ | - | Date of last interaction |
| `interaction_count` | integer | ✓ | 0 | Total interaction count |
| `relationship_strength` | text | ✓ | - | Strength: 'strong', 'moderate', 'weak', 'unknown' |
| `notes` | text | ✓ | - | Additional notes |
| `is_primary_contact` | boolean | ✓ | false | Is primary contact flag |
| `is_decision_maker` | boolean | ✓ | false | Is decision maker flag |
| `auto_detected` | boolean | ✓ | false | True if auto-detected from meetings |
| `created_at` | timestamptz | ✓ | NOW() | Creation timestamp |
| `updated_at` | timestamptz | ✓ | NOW() | Last update timestamp |

### Indexes

- `idx_stakeholders_client` - (client_id)
- `idx_stakeholders_client_name` - (client_name)
- `idx_stakeholders_plan` - (plan_id)
- `idx_stakeholders_role` - (stakeholder_role)
- `idx_stakeholders_meddpicc_role` - (meddpicc_role)
- `idx_stakeholders_reports_to` - (reports_to)
- `idx_stakeholders_sentiment` - (sentiment)
- `idx_stakeholders_email` - (stakeholder_email)

---

## Table: `stakeholder_influences`

**Purpose**: Stores influence relationships between stakeholders for org chart visualisation.

**Row Count**: 0 (new table)

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | uuid | ✗ | gen_random_uuid() | Primary key |
| `from_stakeholder_id` | uuid | ✓ | - | FK to stakeholder_relationships (ON DELETE CASCADE) |
| `to_stakeholder_id` | uuid | ✓ | - | FK to stakeholder_relationships (ON DELETE CASCADE) |
| `influence_type` | text | ✓ | - | Type: 'reports_to', 'influences', 'blocks', 'champions' |
| `influence_strength` | integer | ✓ | - | Strength rating 1-10 |
| `notes` | text | ✓ | - | Additional notes |
| `created_at` | timestamptz | ✓ | NOW() | Creation timestamp |

### Indexes

- `idx_influences_from` - (from_stakeholder_id)
- `idx_influences_to` - (to_stakeholder_id)
- `idx_influences_type` - (influence_type)

---

## Table: `predictive_health_scores`

**Purpose**: ML-predicted health and risk scores for proactive account management.

**Row Count**: 0 (new table)

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | uuid | ✗ | gen_random_uuid() | Primary key |
| `client_id` | uuid | ✓ | - | Optional FK to clients table |
| `client_name` | text | ✗ | - | Client name for display |
| `calculation_date` | date | ✗ | - | Date of calculation |
| `current_health_score` | integer | ✓ | - | Current health score |
| `predicted_health_30d` | integer | ✓ | - | Predicted score in 30 days |
| `predicted_health_90d` | integer | ✓ | - | Predicted score in 90 days |
| `churn_risk_score` | decimal(5,2) | ✓ | - | Churn probability 0-100 (>70 Critical, 50-70 Warning) |
| `expansion_probability` | decimal(5,2) | ✓ | - | Expansion likelihood 0-100 |
| `engagement_velocity` | decimal(5,2) | ✓ | - | Meetings per quarter trend |
| `risk_factors` | jsonb | ✓ | - | Array of contributing risk factors |
| `opportunity_signals` | jsonb | ✓ | - | Array of positive signals |
| `model_version` | text | ✓ | - | ML model version used |
| `confidence_score` | decimal(3,2) | ✓ | - | Model confidence 0.00 to 1.00 |
| `created_at` | timestamptz | ✓ | NOW() | Creation timestamp |

### Indexes

- `idx_predictive_client` - (client_id, calculation_date DESC)
- `idx_predictive_client_name` - (client_name)
- `idx_predictive_date` - (calculation_date DESC)
- `idx_predictive_churn_risk` - (churn_risk_score DESC)
- `idx_predictive_expansion` - (expansion_probability DESC)
- `idx_predictive_model` - (model_version)

---

## Table: `meddpicc_scores`

**Purpose**: Detailed MEDDPICC scoring with AI-assisted gap analysis and recommendations.

**Row Count**: 0 (new table)

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | uuid | ✗ | gen_random_uuid() | Primary key |
| `plan_id` | uuid | ✓ | - | References account_plans or territory_strategies |
| `plan_type` | text | ✓ | - | Type: 'account' or 'territory' |
| `client_id` | uuid | ✓ | - | Optional FK to clients table |
| `client_name` | text | ✓ | - | Client name for display |
| `opportunity_name` | text | ✓ | - | Opportunity being scored |
| `metrics_score` | integer | ✓ | - | Metrics score 0-100 |
| `metrics_evidence` | text | ✓ | - | Evidence for metrics score |
| `metrics_ai_detected` | jsonb | ✓ | - | AI-detected metrics info |
| `economic_buyer_score` | integer | ✓ | - | Economic Buyer score 0-100 |
| `economic_buyer_evidence` | text | ✓ | - | Evidence for EB score |
| `economic_buyer_ai_detected` | jsonb | ✓ | - | AI-detected EB info |
| `decision_criteria_score` | integer | ✓ | - | Decision Criteria score 0-100 |
| `decision_criteria_evidence` | text | ✓ | - | Evidence for DC score |
| `decision_criteria_ai_detected` | jsonb | ✓ | - | AI-detected DC info |
| `decision_process_score` | integer | ✓ | - | Decision Process score 0-100 |
| `decision_process_evidence` | text | ✓ | - | Evidence for DP score |
| `decision_process_ai_detected` | jsonb | ✓ | - | AI-detected DP info |
| `paper_process_score` | integer | ✓ | - | Paper Process score 0-100 |
| `paper_process_evidence` | text | ✓ | - | Evidence for PP score |
| `paper_process_ai_detected` | jsonb | ✓ | - | AI-detected PP info |
| `identify_pain_score` | integer | ✓ | - | Identify Pain score 0-100 |
| `identify_pain_evidence` | text | ✓ | - | Evidence for IP score |
| `identify_pain_ai_detected` | jsonb | ✓ | - | AI-detected IP info |
| `champion_score` | integer | ✓ | - | Champion score 0-100 |
| `champion_evidence` | text | ✓ | - | Evidence for Champion score |
| `champion_ai_detected` | jsonb | ✓ | - | AI-detected Champion info |
| `competition_score` | integer | ✓ | - | Competition score 0-100 |
| `competition_evidence` | text | ✓ | - | Evidence for Competition score |
| `competition_ai_detected` | jsonb | ✓ | - | AI-detected Competition info |
| `overall_score` | integer | ✓ | - | Weighted average score 0-100 |
| `gap_analysis` | jsonb | ✓ | - | AI-identified gaps per component |
| `recommended_actions` | jsonb | ✓ | - | AI-recommended actions to close gaps |
| `last_ai_analysis` | timestamptz | ✓ | - | Last AI analysis timestamp |
| `created_at` | timestamptz | ✓ | NOW() | Creation timestamp |
| `updated_at` | timestamptz | ✓ | NOW() | Last update timestamp |

### Indexes

- `idx_meddpicc_plan` - (plan_id, plan_type)
- `idx_meddpicc_client` - (client_id)
- `idx_meddpicc_client_name` - (client_name)
- `idx_meddpicc_overall` - (overall_score DESC)
- `idx_meddpicc_updated` - (updated_at DESC)

---

## Table: `engagement_timeline`

**Purpose**: Denormalised timeline view of all client touchpoints for engagement tracking.

**Row Count**: 0 (new table)

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | uuid | ✗ | gen_random_uuid() | Primary key |
| `client_id` | uuid | ✓ | - | Optional FK to clients table |
| `client_name` | text | ✗ | - | Client name for display |
| `event_type` | text | ✗ | - | Type: 'meeting', 'nps', 'action', 'health_change', 'note', 'email', 'call' |
| `event_date` | timestamptz | ✗ | - | Date/time of event |
| `event_title` | text | ✓ | - | Event title |
| `event_summary` | text | ✓ | - | Event summary |
| `sentiment` | text | ✓ | - | Sentiment: 'positive', 'neutral', 'negative' |
| `participants` | jsonb | ✓ | - | Array of participant names/emails |
| `key_topics` | jsonb | ✓ | - | Array of key topics discussed |
| `outcomes` | jsonb | ✓ | - | Array of outcomes/decisions |
| `source_id` | uuid | ✓ | - | Reference to source record |
| `source_table` | text | ✓ | - | Source table name (unified_meetings, nps_responses, etc.) |
| `created_at` | timestamptz | ✓ | NOW() | Creation timestamp |

### Indexes

- `idx_timeline_client` - (client_id, event_date DESC)
- `idx_timeline_client_name` - (client_name)
- `idx_timeline_type` - (client_id, event_type, event_date DESC)
- `idx_timeline_date` - (event_date DESC)
- `idx_timeline_source` - (source_table, source_id)
- `idx_timeline_sentiment` - (sentiment, event_date DESC)

---

