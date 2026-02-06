# Database Schema Documentation

**Generated**: 2026-02-06T06:35:05.284Z
**Purpose**: Source of truth for all database table schemas

---

## Overview

This document provides the authoritative schema definition for all tables in the APAC Intelligence database. **Always reference this document when writing queries or TypeScript interfaces.**

## Table: `actions`

**Row Count**: 95

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

---

## Table: `unified_meetings`

**Row Count**: 276

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

**Row Count**: 18

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

**Row Count**: 16

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
| `team_goal_id` | unknown | ✗ | - | *(inferred)* |
| `progress_method` | text | ✗ | - | *(inferred)* |
| `progress_percentage` | integer | ✗ | - | *(inferred)* |
| `target_value` | unknown | ✗ | - | *(inferred)* |
| `current_value` | unknown | ✗ | - | *(inferred)* |
| `is_achieved` | boolean | ✗ | - | *(inferred)* |
| `goal_status` | text | ✗ | - | *(inferred)* |
| `owner_department` | unknown | ✗ | - | *(inferred)* |
| `involved_departments` | unknown | ✗ | - | *(inferred)* |
| `priority` | unknown | ✗ | - | *(inferred)* |
| `actual_completion_date` | unknown | ✗ | - | *(inferred)* |
| `impacts_clients` | boolean | ✗ | - | *(inferred)* |
| `client_impact_description` | unknown | ✗ | - | *(inferred)* |

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
| `confidence_score` | integer | ✗ | - | *(inferred)* |
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

**Row Count**: 183

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

**Row Count**: 671

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

**Row Count**: 0

**Note**: Empty table or RLS blocking access

---

## Table: `team_goals`

**Row Count**: 0

**Note**: Empty table or RLS blocking access

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

**Row Count**: 0

**Note**: Empty table or RLS blocking access

---

## Table: `ms_graph_sync_log`

**Row Count**: 0

**Note**: Empty table or RLS blocking access

---

