# Database Schema Documentation

**Generated**: 2026-02-15T04:28:18.173Z
**Purpose**: Source of truth for all database table schemas

---

## Overview

This document provides the authoritative schema definition for all tables in the APAC Intelligence database. **Always reference this document when writing queries or TypeScript interfaces.**

## Table: `actions`

**Row Count**: 105

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
| `department_code` | text | ✗ | - | *(inferred)* |
| `activity_type_code` | text | ✗ | - | *(inferred)* |
| `is_internal` | boolean | ✗ | - | *(inferred)* |
| `cross_functional` | boolean | ✗ | - | *(inferred)* |
| `client_id` | integer | ✗ | - | *(inferred)* |
| `ai_context` | unknown | ✗ | - | *(inferred)* |
| `ai_context_key_points` | array | ✗ | - | *(inferred)* |
| `ai_context_urgency_indicators` | array | ✗ | - | *(inferred)* |
| `ai_context_related_topics` | array | ✗ | - | *(inferred)* |
| `ai_context_confidence` | unknown | ✗ | - | *(inferred)* |
| `ai_context_generated_at` | unknown | ✗ | - | *(inferred)* |
| `ai_context_meeting_title` | unknown | ✗ | - | *(inferred)* |
| `client_uuid` | text | ✗ | - | *(inferred)* |
| `source` | text | ✗ | - | *(inferred)* |
| `source_metadata` | jsonb | ✗ | - | *(inferred)* |
| `created_by` | unknown | ✗ | - | *(inferred)* |
| `source_alert_text_id` | unknown | ✗ | - | *(inferred)* |
| `source_alert_id` | unknown | ✗ | - | *(inferred)* |
| `tags` | array | ✗ | - | *(inferred)* |
| `linked_initiative_id` | unknown | ✗ | - | *(inferred)* |
| `recurrence_rule` | unknown | ✗ | - | *(inferred)* |
| `recurrence_end_date` | unknown | ✗ | - | *(inferred)* |
| `recurrence_count` | unknown | ✗ | - | *(inferred)* |
| `is_recurring` | boolean | ✗ | - | *(inferred)* |
| `recurring_parent_id` | unknown | ✗ | - | *(inferred)* |
| `recurrence_index` | unknown | ✗ | - | *(inferred)* |

---

## Table: `unified_meetings`

**Row Count**: 309

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
| `topics` | unknown | ✗ | - | *(inferred)* |
| `risks` | unknown | ✗ | - | *(inferred)* |
| `highlights` | unknown | ✗ | - | *(inferred)* |
| `next_steps` | unknown | ✗ | - | *(inferred)* |
| `outlook_event_id` | text | ✗ | - | *(inferred)* |
| `teams_meeting_id` | unknown | ✗ | - | *(inferred)* |
| `synced_to_outlook` | boolean | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |
| `analyzed_at` | unknown | ✗ | - | *(inferred)* |
| `transcript_file_url` | unknown | ✗ | - | *(inferred)* |
| `recording_file_url` | unknown | ✗ | - | *(inferred)* |
| `attendees` | text | ✗ | - | *(inferred)* |
| `meeting_dept` | text | ✗ | - | *(inferred)* |
| `status` | text | ✗ | - | *(inferred)* |
| `decisions` | array | ✗ | - | *(inferred)* |
| `resources` | array | ✗ | - | *(inferred)* |
| `organizer` | text | ✗ | - | *(inferred)* |
| `title` | text | ✗ | - | *(inferred)* |
| `deleted` | boolean | ✗ | - | *(inferred)* |
| `department_code` | text | ✗ | - | *(inferred)* |
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

**Row Count**: 54

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
| `effective_to` | text | ✗ | - | *(inferred)* |
| `notes` | unknown | ✗ | - | *(inferred)* |
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

**Row Count**: 15

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
| `client_uuid` | unknown | ✗ | - | *(inferred)* |

---

## Table: `notifications`

**Row Count**: 17

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

**Row Count**: 12

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `name` | text | ✗ | - | *(inferred)* |
| `client_name` | text | ✗ | - | *(inferred)* |
| `cse_name` | unknown | ✗ | - | *(inferred)* |
| `year` | integer | ✗ | - | *(inferred)* |
| `status` | text | ✗ | - | *(inferred)* |
| `category` | text | ✗ | - | *(inferred)* |
| `start_date` | unknown | ✗ | - | *(inferred)* |
| `completion_date` | unknown | ✗ | - | *(inferred)* |
| `description` | text | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |
| `client_id` | text | ✗ | - | *(inferred)* |
| `team_goal_id` | text | ✗ | - | *(inferred)* |
| `progress_method` | text | ✗ | - | *(inferred)* |
| `progress_percentage` | integer | ✗ | - | *(inferred)* |
| `target_value` | unknown | ✗ | - | *(inferred)* |
| `current_value` | unknown | ✗ | - | *(inferred)* |
| `is_achieved` | boolean | ✗ | - | *(inferred)* |
| `goal_status` | unknown | ✗ | - | *(inferred)* |
| `owner_department` | unknown | ✗ | - | *(inferred)* |
| `involved_departments` | unknown | ✗ | - | *(inferred)* |
| `priority` | unknown | ✗ | - | *(inferred)* |
| `actual_completion_date` | unknown | ✗ | - | *(inferred)* |
| `impacts_clients` | boolean | ✗ | - | *(inferred)* |
| `client_impact_description` | unknown | ✗ | - | *(inferred)* |
| `last_check_in_date` | unknown | ✗ | - | *(inferred)* |
| `weight` | integer | ✗ | - | *(inferred)* |
| `check_in_cadence` | text | ✗ | - | *(inferred)* |

---

## Table: `nps_topic_classifications`

**Row Count**: 204

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

**Row Count**: 124

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

**Row Count**: 24

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

**Row Count**: 14

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

**Row Count**: 197

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `user_email` | text | ✗ | - | *(inferred)* |
| `title` | text | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |
| `message_count` | integer | ✗ | - | *(inferred)* |
| `last_message_preview` | unknown | ✗ | - | *(inferred)* |
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

**Row Count**: 743

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

## Table: `company_goals`

**Row Count**: 9

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `title` | text | ✗ | - | *(inferred)* |
| `description` | text | ✗ | - | *(inferred)* |
| `owner_id` | unknown | ✗ | - | *(inferred)* |
| `progress_method` | text | ✗ | - | *(inferred)* |
| `progress_percentage` | integer | ✗ | - | *(inferred)* |
| `target_value` | unknown | ✗ | - | *(inferred)* |
| `current_value` | unknown | ✗ | - | *(inferred)* |
| `is_achieved` | boolean | ✗ | - | *(inferred)* |
| `start_date` | text | ✗ | - | *(inferred)* |
| `target_date` | text | ✗ | - | *(inferred)* |
| `status` | text | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |
| `last_check_in_date` | unknown | ✗ | - | *(inferred)* |
| `pillar_id` | text | ✗ | - | *(inferred)* |
| `weight` | integer | ✗ | - | *(inferred)* |
| `check_in_cadence` | text | ✗ | - | *(inferred)* |

---

## Table: `team_goals`

**Row Count**: 9

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `company_goal_id` | text | ✗ | - | *(inferred)* |
| `title` | text | ✗ | - | *(inferred)* |
| `description` | text | ✗ | - | *(inferred)* |
| `owner_id` | unknown | ✗ | - | *(inferred)* |
| `team_id` | text | ✗ | - | *(inferred)* |
| `progress_method` | text | ✗ | - | *(inferred)* |
| `progress_percentage` | integer | ✗ | - | *(inferred)* |
| `target_value` | unknown | ✗ | - | *(inferred)* |
| `current_value` | unknown | ✗ | - | *(inferred)* |
| `is_achieved` | boolean | ✗ | - | *(inferred)* |
| `start_date` | text | ✗ | - | *(inferred)* |
| `target_date` | text | ✗ | - | *(inferred)* |
| `status` | text | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |
| `last_check_in_date` | unknown | ✗ | - | *(inferred)* |
| `weight` | integer | ✗ | - | *(inferred)* |
| `check_in_cadence` | text | ✗ | - | *(inferred)* |

---

## Table: `goal_templates`

**Row Count**: 5

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `name` | text | ✗ | - | *(inferred)* |
| `tier` | text | ✗ | - | *(inferred)* |
| `title_template` | text | ✗ | - | *(inferred)* |
| `description_template` | text | ✗ | - | *(inferred)* |
| `suggested_metrics` | jsonb | ✗ | - | *(inferred)* |
| `industry` | unknown | ✗ | - | *(inferred)* |
| `use_count` | integer | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |

---

## Table: `goal_check_ins`

**Row Count**: 0

**Note**: Empty table or RLS blocking access

---

## Table: `goal_dependencies`

**Row Count**: 0

**Note**: Empty table or RLS blocking access

---

## Table: `goal_approvals`

**Row Count**: 0

**Note**: Empty table or RLS blocking access

---

## Table: `goal_audit_log`

**Row Count**: 0

**Note**: Empty table or RLS blocking access

---

## Table: `goal_status_updates`

**Row Count**: 0

**Note**: Empty table or RLS blocking access

---

## Table: `custom_roles`

**Row Count**: 5

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `name` | text | ✗ | - | *(inferred)* |
| `description` | text | ✗ | - | *(inferred)* |
| `permissions` | jsonb | ✗ | - | *(inferred)* |
| `is_system_role` | boolean | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |

---

## Table: `user_role_assignments`

**Row Count**: 0

**Note**: Empty table or RLS blocking access

---

## Table: `role_mapping_rules`

**Row Count**: 7

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `source_type` | text | ✗ | - | *(inferred)* |
| `source_value` | text | ✗ | - | *(inferred)* |
| `target_role_id` | text | ✗ | - | *(inferred)* |
| `priority` | integer | ✗ | - | *(inferred)* |
| `is_active` | boolean | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |

---

## Table: `ms_graph_sync_log`

**Row Count**: 0

**Note**: Empty table or RLS blocking access

---

## Table: `news_sources`

**Row Count**: 66

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | integer | ✗ | - | *(inferred)* |
| `name` | text | ✗ | - | *(inferred)* |
| `source_type` | text | ✗ | - | *(inferred)* |
| `url` | text | ✗ | - | *(inferred)* |
| `region` | array | ✗ | - | *(inferred)* |
| `category` | text | ✗ | - | *(inferred)* |
| `authority_score` | integer | ✗ | - | *(inferred)* |
| `fetch_frequency` | text | ✗ | - | *(inferred)* |
| `last_fetched_at` | unknown | ✗ | - | *(inferred)* |
| `is_active` | boolean | ✗ | - | *(inferred)* |
| `config` | jsonb | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |
| `client_id` | unknown | ✗ | - | *(inferred)* |

---

## Table: `news_articles`

**Row Count**: 799

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | integer | ✗ | - | *(inferred)* |
| `source_id` | unknown | ✗ | - | *(inferred)* |
| `title` | text | ✗ | - | *(inferred)* |
| `content` | unknown | ✗ | - | *(inferred)* |
| `summary` | unknown | ✗ | - | *(inferred)* |
| `source_url` | text | ✗ | - | *(inferred)* |
| `published_date` | unknown | ✗ | - | *(inferred)* |
| `fetched_at` | text | ✗ | - | *(inferred)* |
| `relevance_score` | integer | ✗ | - | *(inferred)* |
| `client_match_score` | integer | ✗ | - | *(inferred)* |
| `topic_relevance_score` | integer | ✗ | - | *(inferred)* |
| `action_potential_score` | integer | ✗ | - | *(inferred)* |
| `source_authority_score` | integer | ✗ | - | *(inferred)* |
| `recency_score` | unknown | ✗ | - | *(inferred)* |
| `category` | text | ✗ | - | *(inferred)* |
| `trigger_type` | unknown | ✗ | - | *(inferred)* |
| `matched_clients` | array | ✗ | - | *(inferred)* |
| `matched_stakeholders` | array | ✗ | - | *(inferred)* |
| `relevant_products` | array | ✗ | - | *(inferred)* |
| `ai_summary` | text | ✗ | - | *(inferred)* |
| `recommended_action` | unknown | ✗ | - | *(inferred)* |
| `key_quote` | unknown | ✗ | - | *(inferred)* |
| `regions` | array | ✗ | - | *(inferred)* |
| `topics` | array | ✗ | - | *(inferred)* |
| `is_verified` | boolean | ✗ | - | *(inferred)* |
| `is_active` | boolean | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |
| `tier1_passed` | boolean | ✗ | - | *(inferred)* |
| `tier1_reject_reason` | unknown | ✗ | - | *(inferred)* |
| `tier2_passed` | boolean | ✗ | - | *(inferred)* |
| `article_type` | unknown | ✗ | - | *(inferred)* |

---

## Table: `tender_opportunities`

**Row Count**: 452

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | integer | ✗ | - | *(inferred)* |
| `article_id` | unknown | ✗ | - | *(inferred)* |
| `tender_reference` | text | ✗ | - | *(inferred)* |
| `issuing_body` | text | ✗ | - | *(inferred)* |
| `title` | text | ✗ | - | *(inferred)* |
| `description` | unknown | ✗ | - | *(inferred)* |
| `region` | text | ✗ | - | *(inferred)* |
| `close_date` | text | ✗ | - | *(inferred)* |
| `estimated_value` | unknown | ✗ | - | *(inferred)* |
| `relevant_products` | unknown | ✗ | - | *(inferred)* |
| `status` | text | ✗ | - | *(inferred)* |
| `assigned_to` | unknown | ✗ | - | *(inferred)* |
| `notes` | unknown | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |
| `source_url` | text | ✗ | - | *(inferred)* |

---

## Table: `support_case_details`

**Row Count**: 1924

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `metrics_id` | text | ✗ | - | *(inferred)* |
| `client_name` | text | ✗ | - | *(inferred)* |
| `case_number` | text | ✗ | - | *(inferred)* |
| `short_description` | unknown | ✗ | - | *(inferred)* |
| `priority` | text | ✗ | - | *(inferred)* |
| `state` | unknown | ✗ | - | *(inferred)* |
| `opened_at` | unknown | ✗ | - | *(inferred)* |
| `resolved_at` | unknown | ✗ | - | *(inferred)* |
| `assigned_to` | unknown | ✗ | - | *(inferred)* |
| `contact_name` | unknown | ✗ | - | *(inferred)* |
| `product` | unknown | ✗ | - | *(inferred)* |
| `environment` | unknown | ✗ | - | *(inferred)* |
| `has_breached` | boolean | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `resolution_duration_seconds` | unknown | ✗ | - | *(inferred)* |
| `closed_at` | unknown | ✗ | - | *(inferred)* |
| `updated_at` | unknown | ✗ | - | *(inferred)* |
| `urgency` | unknown | ✗ | - | *(inferred)* |
| `impact` | unknown | ✗ | - | *(inferred)* |
| `close_code` | unknown | ✗ | - | *(inferred)* |
| `closed_subcode` | unknown | ✗ | - | *(inferred)* |
| `cause` | unknown | ✗ | - | *(inferred)* |
| `category` | unknown | ✗ | - | *(inferred)* |
| `country` | unknown | ✗ | - | *(inferred)* |
| `region` | unknown | ✗ | - | *(inferred)* |
| `kpi_met` | unknown | ✗ | - | *(inferred)* |
| `contact_type` | unknown | ✗ | - | *(inferred)* |
| `case_type` | unknown | ✗ | - | *(inferred)* |
| `incident_number` | unknown | ✗ | - | *(inferred)* |
| `source_file` | unknown | ✗ | - | *(inferred)* |
| `imported_by` | unknown | ✗ | - | *(inferred)* |

---

## Table: `support_sla_metrics`

**Row Count**: 11

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `client_name` | text | ✗ | - | *(inferred)* |
| `client_uuid` | unknown | ✗ | - | *(inferred)* |
| `period_start` | text | ✗ | - | *(inferred)* |
| `period_end` | text | ✗ | - | *(inferred)* |
| `period_type` | text | ✗ | - | *(inferred)* |
| `total_incoming` | integer | ✗ | - | *(inferred)* |
| `total_closed` | integer | ✗ | - | *(inferred)* |
| `backlog` | integer | ✗ | - | *(inferred)* |
| `critical_open` | integer | ✗ | - | *(inferred)* |
| `high_open` | integer | ✗ | - | *(inferred)* |
| `moderate_open` | integer | ✗ | - | *(inferred)* |
| `low_open` | integer | ✗ | - | *(inferred)* |
| `aging_0_7d` | integer | ✗ | - | *(inferred)* |
| `aging_8_30d` | integer | ✗ | - | *(inferred)* |
| `aging_31_60d` | integer | ✗ | - | *(inferred)* |
| `aging_61_90d` | integer | ✗ | - | *(inferred)* |
| `aging_90d_plus` | integer | ✗ | - | *(inferred)* |
| `response_sla_percent` | integer | ✗ | - | *(inferred)* |
| `resolution_sla_percent` | numeric | ✗ | - | *(inferred)* |
| `breach_count` | integer | ✗ | - | *(inferred)* |
| `availability_percent` | unknown | ✗ | - | *(inferred)* |
| `outage_count` | integer | ✗ | - | *(inferred)* |
| `outage_minutes` | integer | ✗ | - | *(inferred)* |
| `surveys_sent` | integer | ✗ | - | *(inferred)* |
| `surveys_completed` | integer | ✗ | - | *(inferred)* |
| `satisfaction_score` | numeric | ✗ | - | *(inferred)* |
| `source_file` | text | ✗ | - | *(inferred)* |
| `imported_at` | text | ✗ | - | *(inferred)* |
| `imported_by` | text | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |
| `client_segment` | unknown | ✗ | - | *(inferred)* |

---

## Table: `sync_history`

**Row Count**: 322

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `source` | text | ✗ | - | *(inferred)* |
| `started_at` | text | ✗ | - | *(inferred)* |
| `completed_at` | text | ✗ | - | *(inferred)* |
| `status` | text | ✗ | - | *(inferred)* |
| `records_processed` | integer | ✗ | - | *(inferred)* |
| `records_created` | integer | ✗ | - | *(inferred)* |
| `records_updated` | integer | ✗ | - | *(inferred)* |
| `records_failed` | integer | ✗ | - | *(inferred)* |
| `error_message` | text | ✗ | - | *(inferred)* |
| `triggered_by` | text | ✗ | - | *(inferred)* |
| `triggered_by_user` | text | ✗ | - | *(inferred)* |
| `metadata` | jsonb | ✗ | - | *(inferred)* |
| `duration_ms` | unknown | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |

---

## Table: `segmentation_events`

**Row Count**: 779

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `client_name` | text | ✗ | - | *(inferred)* |
| `client_segmentation_id` | unknown | ✗ | - | *(inferred)* |
| `event_type_id` | text | ✗ | - | *(inferred)* |
| `event_date` | text | ✗ | - | *(inferred)* |
| `event_month` | integer | ✗ | - | *(inferred)* |
| `event_year` | integer | ✗ | - | *(inferred)* |
| `completed` | boolean | ✗ | - | *(inferred)* |
| `completed_date` | text | ✗ | - | *(inferred)* |
| `completed_by` | unknown | ✗ | - | *(inferred)* |
| `notes` | text | ✗ | - | *(inferred)* |
| `meeting_link` | unknown | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |
| `created_by` | unknown | ✗ | - | *(inferred)* |
| `expected_count` | integer | ✗ | - | *(inferred)* |
| `period` | unknown | ✗ | - | *(inferred)* |
| `edit_history` | array | ✗ | - | *(inferred)* |
| `client_id` | unknown | ✗ | - | *(inferred)* |
| `linked_meeting_id` | unknown | ✗ | - | *(inferred)* |
| `scheduled_date` | unknown | ✗ | - | *(inferred)* |
| `source` | text | ✗ | - | *(inferred)* |
| `content_hash` | text | ✗ | - | *(inferred)* |

---

## Table: `segmentation_event_types`

**Row Count**: 12

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `event_name` | text | ✗ | - | *(inferred)* |
| `event_code` | text | ✗ | - | *(inferred)* |
| `frequency_type` | text | ✗ | - | *(inferred)* |
| `responsible_team` | text | ✗ | - | *(inferred)* |
| `description` | unknown | ✗ | - | *(inferred)* |
| `is_active` | boolean | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |

---

## Table: `client_name_aliases`

**Row Count**: 91

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | integer | ✗ | - | *(inferred)* |
| `display_name` | text | ✗ | - | *(inferred)* |
| `canonical_name` | text | ✗ | - | *(inferred)* |
| `description` | unknown | ✗ | - | *(inferred)* |
| `is_active` | boolean | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |

---

## Table: `burc_monthly_metrics`

**Row Count**: 2780

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `fiscal_year` | integer | ✗ | - | *(inferred)* |
| `month_num` | integer | ✗ | - | *(inferred)* |
| `month_name` | text | ✗ | - | *(inferred)* |
| `metric_name` | text | ✗ | - | *(inferred)* |
| `metric_category` | text | ✗ | - | *(inferred)* |
| `value` | numeric | ✗ | - | *(inferred)* |
| `source_file` | text | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |

---

## Table: `burc_executive_summary`

**Row Count**: 1

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `snapshot_date` | text | ✗ | - | *(inferred)* |
| `nrr_percent` | numeric | ✗ | - | *(inferred)* |
| `grr_percent` | numeric | ✗ | - | *(inferred)* |
| `annual_churn` | integer | ✗ | - | *(inferred)* |
| `expansion_revenue` | numeric | ✗ | - | *(inferred)* |
| `revenue_growth_percent` | numeric | ✗ | - | *(inferred)* |
| `ebita_margin_percent` | numeric | ✗ | - | *(inferred)* |
| `rule_of_40_score` | numeric | ✗ | - | *(inferred)* |
| `rule_of_40_status` | text | ✗ | - | *(inferred)* |
| `total_arr` | numeric | ✗ | - | *(inferred)* |
| `active_contracts` | integer | ✗ | - | *(inferred)* |
| `total_contract_value` | numeric | ✗ | - | *(inferred)* |
| `total_pipeline` | integer | ✗ | - | *(inferred)* |
| `total_net_booking` | numeric | ✗ | - | *(inferred)* |
| `weighted_pipeline` | numeric | ✗ | - | *(inferred)* |
| `weighted_net_booking` | numeric | ✗ | - | *(inferred)* |
| `total_at_risk` | integer | ✗ | - | *(inferred)* |
| `attrition_risk_count` | integer | ✗ | - | *(inferred)* |
| `nrr_health` | text | ✗ | - | *(inferred)* |
| `grr_health` | text | ✗ | - | *(inferred)* |
| `target_arr` | numeric | ✗ | - | *(inferred)* |
| `target_gross_revenue` | numeric | ✗ | - | *(inferred)* |
| `target_ebita` | numeric | ✗ | - | *(inferred)* |
| `arr_variance_percent` | numeric | ✗ | - | *(inferred)* |
| `arr_risk_status` | text | ✗ | - | *(inferred)* |
| `gross_revenue` | numeric | ✗ | - | *(inferred)* |
| `net_revenue` | numeric | ✗ | - | *(inferred)* |
| `target_net_revenue` | numeric | ✗ | - | *(inferred)* |

---

## Table: `burc_annual_financials`

**Row Count**: 8

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `fiscal_year` | integer | ✗ | - | *(inferred)* |
| `gross_revenue` | numeric | ✗ | - | *(inferred)* |
| `ebita` | numeric | ✗ | - | *(inferred)* |
| `ebita_margin_percent` | numeric | ✗ | - | *(inferred)* |
| `revenue_growth_percent` | numeric | ✗ | - | *(inferred)* |
| `rule_of_40_score` | numeric | ✗ | - | *(inferred)* |
| `rule_of_40_status` | text | ✗ | - | *(inferred)* |
| `source_file` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |
| `starting_arr` | numeric | ✗ | - | *(inferred)* |
| `ending_arr` | integer | ✗ | - | *(inferred)* |
| `churn` | integer | ✗ | - | *(inferred)* |
| `contraction` | integer | ✗ | - | *(inferred)* |
| `expansion` | numeric | ✗ | - | *(inferred)* |
| `nrr_percent` | numeric | ✗ | - | *(inferred)* |
| `grr_percent` | numeric | ✗ | - | *(inferred)* |
| `nrr_health` | text | ✗ | - | *(inferred)* |
| `grr_health` | text | ✗ | - | *(inferred)* |
| `target_arr` | numeric | ✗ | - | *(inferred)* |
| `target_gross_revenue` | numeric | ✗ | - | *(inferred)* |
| `target_ebita` | numeric | ✗ | - | *(inferred)* |
| `arr_variance_percent` | numeric | ✗ | - | *(inferred)* |
| `arr_risk_status` | text | ✗ | - | *(inferred)* |
| `total_opex` | numeric | ✗ | - | *(inferred)* |
| `net_revenue` | numeric | ✗ | - | *(inferred)* |
| `target_net_revenue` | numeric | ✗ | - | *(inferred)* |

---

## Table: `burc_revenue_detail`

**Row Count**: 429

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `fiscal_year` | integer | ✗ | - | *(inferred)* |
| `revenue_type` | text | ✗ | - | *(inferred)* |
| `client_name` | text | ✗ | - | *(inferred)* |
| `deal_name` | unknown | ✗ | - | *(inferred)* |
| `product` | unknown | ✗ | - | *(inferred)* |
| `q1_value` | integer | ✗ | - | *(inferred)* |
| `q2_value` | integer | ✗ | - | *(inferred)* |
| `q3_value` | integer | ✗ | - | *(inferred)* |
| `q4_value` | integer | ✗ | - | *(inferred)* |
| `fy_total` | numeric | ✗ | - | *(inferred)* |
| `category` | unknown | ✗ | - | *(inferred)* |
| `source_sheet` | text | ✗ | - | *(inferred)* |
| `source_file` | text | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |

---

## Table: `burc_ebita_monthly`

**Row Count**: 12

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `year` | integer | ✗ | - | *(inferred)* |
| `month` | text | ✗ | - | *(inferred)* |
| `month_num` | integer | ✗ | - | *(inferred)* |
| `target_ebita` | numeric | ✗ | - | *(inferred)* |
| `actual_ebita` | numeric | ✗ | - | *(inferred)* |
| `variance` | numeric | ✗ | - | *(inferred)* |
| `ebita_percent` | numeric | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |

---

## Table: `burc_opex_monthly`

**Row Count**: 12

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `year` | integer | ✗ | - | *(inferred)* |
| `month` | text | ✗ | - | *(inferred)* |
| `month_num` | integer | ✗ | - | *(inferred)* |
| `cs_opex` | numeric | ✗ | - | *(inferred)* |
| `rd_opex` | numeric | ✗ | - | *(inferred)* |
| `ps_opex` | numeric | ✗ | - | *(inferred)* |
| `sales_opex` | numeric | ✗ | - | *(inferred)* |
| `ga_opex` | numeric | ✗ | - | *(inferred)* |
| `total_opex` | numeric | ✗ | - | *(inferred)* |
| `calculated_at` | text | ✗ | - | *(inferred)* |

---

## Table: `burc_cogs_monthly`

**Row Count**: 12

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `year` | integer | ✗ | - | *(inferred)* |
| `month` | text | ✗ | - | *(inferred)* |
| `month_num` | integer | ✗ | - | *(inferred)* |
| `license_cogs` | integer | ✗ | - | *(inferred)* |
| `ps_cogs` | numeric | ✗ | - | *(inferred)* |
| `maintenance_cogs` | numeric | ✗ | - | *(inferred)* |
| `hardware_cogs` | integer | ✗ | - | *(inferred)* |
| `total_cogs` | numeric | ✗ | - | *(inferred)* |
| `calculated_at` | text | ✗ | - | *(inferred)* |

---

## Table: `burc_net_revenue_monthly`

**Row Count**: 12

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `year` | integer | ✗ | - | *(inferred)* |
| `month` | text | ✗ | - | *(inferred)* |
| `month_num` | integer | ✗ | - | *(inferred)* |
| `license_net` | integer | ✗ | - | *(inferred)* |
| `ps_net` | numeric | ✗ | - | *(inferred)* |
| `maintenance_net` | numeric | ✗ | - | *(inferred)* |
| `hardware_net` | integer | ✗ | - | *(inferred)* |
| `total_net_revenue` | numeric | ✗ | - | *(inferred)* |
| `calculated_at` | text | ✗ | - | *(inferred)* |

---

## Table: `burc_gross_revenue_monthly`

**Row Count**: 12

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `year` | integer | ✗ | - | *(inferred)* |
| `month` | text | ✗ | - | *(inferred)* |
| `month_num` | integer | ✗ | - | *(inferred)* |
| `license_revenue` | integer | ✗ | - | *(inferred)* |
| `ps_revenue` | integer | ✗ | - | *(inferred)* |
| `maintenance_revenue` | numeric | ✗ | - | *(inferred)* |
| `hardware_revenue` | integer | ✗ | - | *(inferred)* |
| `total_gross_revenue` | numeric | ✗ | - | *(inferred)* |
| `calculated_at` | text | ✗ | - | *(inferred)* |

---

## Table: `account_plans`

**Row Count**: 2

### Columns

| Column Name | Data Type | Nullable | Default | Notes |
|-------------|-----------|----------|---------|-------|
| `id` | text | ✗ | - | *(inferred)* |
| `cam_id` | unknown | ✗ | - | *(inferred)* |
| `cam_name` | text | ✗ | - | *(inferred)* |
| `cse_partner` | text | ✗ | - | *(inferred)* |
| `client_id` | text | ✗ | - | *(inferred)* |
| `client_name` | text | ✗ | - | *(inferred)* |
| `fiscal_year` | integer | ✗ | - | *(inferred)* |
| `quarter` | unknown | ✗ | - | *(inferred)* |
| `status` | text | ✗ | - | *(inferred)* |
| `submitted_at` | text | ✗ | - | *(inferred)* |
| `approved_at` | unknown | ✗ | - | *(inferred)* |
| `approved_by` | unknown | ✗ | - | *(inferred)* |
| `snapshot_data` | jsonb | ✗ | - | *(inferred)* |
| `stakeholders_data` | jsonb | ✗ | - | *(inferred)* |
| `engagement_data` | jsonb | ✗ | - | *(inferred)* |
| `support_data` | jsonb | ✗ | - | *(inferred)* |
| `opportunities_data` | jsonb | ✗ | - | *(inferred)* |
| `risk_data` | jsonb | ✗ | - | *(inferred)* |
| `action_plan_data` | jsonb | ✗ | - | *(inferred)* |
| `value_data` | jsonb | ✗ | - | *(inferred)* |
| `completion_percentage` | integer | ✗ | - | *(inferred)* |
| `steps_completed` | jsonb | ✗ | - | *(inferred)* |
| `revision_notes` | unknown | ✗ | - | *(inferred)* |
| `revision_requested_at` | unknown | ✗ | - | *(inferred)* |
| `revision_requested_by` | unknown | ✗ | - | *(inferred)* |
| `created_at` | text | ✗ | - | *(inferred)* |
| `updated_at` | text | ✗ | - | *(inferred)* |
| `last_edited_by` | unknown | ✗ | - | *(inferred)* |
| `version` | integer | ✗ | - | *(inferred)* |

---

