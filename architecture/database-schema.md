# Database Schema Documentation

**Generated**: 2025-12-24T07:11:40.750Z
**Purpose**: Source of truth for all database table schemas

---

## Overview

This document provides the authoritative schema definition for all tables in the APAC Intelligence database. **Always reference this document when writing queries or TypeScript interfaces.**

## Table: `actions`

**Row Count**: 91

### Columns

| Column Name            | Data Type | Nullable | Default | Notes        |
| ---------------------- | --------- | -------- | ------- | ------------ |
| `id`                   | integer   | ✗        | -       | _(inferred)_ |
| `Action_ID`            | text      | ✗        | -       | _(inferred)_ |
| `Action_Description`   | text      | ✗        | -       | _(inferred)_ |
| `Owners`               | text      | ✗        | -       | _(inferred)_ |
| `Due_Date`             | text      | ✗        | -       | _(inferred)_ |
| `Status`               | text      | ✗        | -       | _(inferred)_ |
| `Priority`             | text      | ✗        | -       | _(inferred)_ |
| `Content_Topic`        | unknown   | ✗        | -       | _(inferred)_ |
| `Meeting_Date`         | unknown   | ✗        | -       | _(inferred)_ |
| `Topic_Number`         | unknown   | ✗        | -       | _(inferred)_ |
| `created_at`           | text      | ✗        | -       | _(inferred)_ |
| `updated_at`           | text      | ✗        | -       | _(inferred)_ |
| `Notes`                | unknown   | ✗        | -       | _(inferred)_ |
| `Shared_Action_Id`     | unknown   | ✗        | -       | _(inferred)_ |
| `Is_Shared`            | boolean   | ✗        | -       | _(inferred)_ |
| `Completed_At`         | unknown   | ✗        | -       | _(inferred)_ |
| `meeting_id`           | unknown   | ✗        | -       | _(inferred)_ |
| `outlook_task_id`      | unknown   | ✗        | -       | _(inferred)_ |
| `teams_message_id`     | unknown   | ✗        | -       | _(inferred)_ |
| `last_synced_at`       | unknown   | ✗        | -       | _(inferred)_ |
| `edit_history`         | array     | ✗        | -       | _(inferred)_ |
| `client`               | text      | ✗        | -       | _(inferred)_ |
| `Category`             | text      | ✗        | -       | _(inferred)_ |
| `department_code`      | text      | ✗        | -       | _(inferred)_ |
| `activity_type_code`   | unknown   | ✗        | -       | _(inferred)_ |
| `is_internal`          | boolean   | ✗        | -       | _(inferred)_ |
| `cross_functional`     | boolean   | ✗        | -       | _(inferred)_ |
| `linked_initiative_id` | unknown   | ✗        | -       | _(inferred)_ |
| `client_id`            | unknown   | ✗        | -       | _(inferred)_ |

---

## Table: `unified_meetings`

**Row Count**: 138

### Columns

| Column Name                     | Data Type | Nullable | Default | Notes        |
| ------------------------------- | --------- | -------- | ------- | ------------ |
| `id`                            | integer   | ✗        | -       | _(inferred)_ |
| `meeting_id`                    | text      | ✗        | -       | _(inferred)_ |
| `client_name`                   | text      | ✗        | -       | _(inferred)_ |
| `cse_name`                      | text      | ✗        | -       | _(inferred)_ |
| `meeting_date`                  | text      | ✗        | -       | _(inferred)_ |
| `meeting_time`                  | text      | ✗        | -       | _(inferred)_ |
| `duration`                      | integer   | ✗        | -       | _(inferred)_ |
| `meeting_type`                  | text      | ✗        | -       | _(inferred)_ |
| `meeting_notes`                 | text      | ✗        | -       | _(inferred)_ |
| `transcript`                    | unknown   | ✗        | -       | _(inferred)_ |
| `recording_url`                 | unknown   | ✗        | -       | _(inferred)_ |
| `ai_analyzed`                   | boolean   | ✗        | -       | _(inferred)_ |
| `ai_summary`                    | unknown   | ✗        | -       | _(inferred)_ |
| `ai_confidence_score`           | unknown   | ✗        | -       | _(inferred)_ |
| `ai_tokens_used`                | unknown   | ✗        | -       | _(inferred)_ |
| `ai_cost`                       | unknown   | ✗        | -       | _(inferred)_ |
| `sentiment_overall`             | unknown   | ✗        | -       | _(inferred)_ |
| `sentiment_score`               | unknown   | ✗        | -       | _(inferred)_ |
| `sentiment_client`              | unknown   | ✗        | -       | _(inferred)_ |
| `sentiment_cse`                 | unknown   | ✗        | -       | _(inferred)_ |
| `effectiveness_overall`         | unknown   | ✗        | -       | _(inferred)_ |
| `effectiveness_preparation`     | unknown   | ✗        | -       | _(inferred)_ |
| `effectiveness_participation`   | unknown   | ✗        | -       | _(inferred)_ |
| `effectiveness_clarity`         | unknown   | ✗        | -       | _(inferred)_ |
| `effectiveness_outcomes`        | unknown   | ✗        | -       | _(inferred)_ |
| `effectiveness_follow_up`       | unknown   | ✗        | -       | _(inferred)_ |
| `effectiveness_time_management` | unknown   | ✗        | -       | _(inferred)_ |
| `topics`                        | array     | ✗        | -       | _(inferred)_ |
| `risks`                         | array     | ✗        | -       | _(inferred)_ |
| `highlights`                    | unknown   | ✗        | -       | _(inferred)_ |
| `next_steps`                    | array     | ✗        | -       | _(inferred)_ |
| `outlook_event_id`              | unknown   | ✗        | -       | _(inferred)_ |
| `teams_meeting_id`              | unknown   | ✗        | -       | _(inferred)_ |
| `synced_to_outlook`             | boolean   | ✗        | -       | _(inferred)_ |
| `created_at`                    | text      | ✗        | -       | _(inferred)_ |
| `updated_at`                    | text      | ✗        | -       | _(inferred)_ |
| `analyzed_at`                   | unknown   | ✗        | -       | _(inferred)_ |
| `transcript_file_url`           | text      | ✗        | -       | _(inferred)_ |
| `recording_file_url`            | text      | ✗        | -       | _(inferred)_ |
| `attendees`                     | text      | ✗        | -       | _(inferred)_ |
| `meeting_dept`                  | text      | ✗        | -       | _(inferred)_ |
| `status`                        | text      | ✗        | -       | _(inferred)_ |
| `decisions`                     | array     | ✗        | -       | _(inferred)_ |
| `resources`                     | array     | ✗        | -       | _(inferred)_ |
| `organizer`                     | text      | ✗        | -       | _(inferred)_ |
| `title`                         | text      | ✗        | -       | _(inferred)_ |
| `deleted`                       | boolean   | ✗        | -       | _(inferred)_ |
| `department_code`               | unknown   | ✗        | -       | _(inferred)_ |
| `activity_type_code`            | unknown   | ✗        | -       | _(inferred)_ |
| `is_internal`                   | boolean   | ✗        | -       | _(inferred)_ |
| `cross_functional`              | boolean   | ✗        | -       | _(inferred)_ |
| `linked_initiative_id`          | unknown   | ✗        | -       | _(inferred)_ |
| `client_id`                     | unknown   | ✗        | -       | _(inferred)_ |

---

## Table: `nps_responses`

**Row Count**: 199

### Columns

| Column Name     | Data Type | Nullable | Default | Notes        |
| --------------- | --------- | -------- | ------- | ------------ |
| `id`            | integer   | ✗        | -       | _(inferred)_ |
| `client_name`   | text      | ✗        | -       | _(inferred)_ |
| `contact_name`  | text      | ✗        | -       | _(inferred)_ |
| `score`         | integer   | ✗        | -       | _(inferred)_ |
| `category`      | text      | ✗        | -       | _(inferred)_ |
| `feedback`      | text      | ✗        | -       | _(inferred)_ |
| `response_date` | unknown   | ✗        | -       | _(inferred)_ |
| `period`        | text      | ✗        | -       | _(inferred)_ |
| `created_at`    | text      | ✗        | -       | _(inferred)_ |
| `business_unit` | unknown   | ✗        | -       | _(inferred)_ |
| `role`          | unknown   | ✗        | -       | _(inferred)_ |
| `cse_name`      | unknown   | ✗        | -       | _(inferred)_ |
| `contact_email` | unknown   | ✗        | -       | _(inferred)_ |
| `region`        | unknown   | ✗        | -       | _(inferred)_ |
| `client_id`     | integer   | ✗        | -       | _(inferred)_ |

---

## Table: `client_segmentation`

**Row Count**: 26

### Columns

| Column Name      | Data Type | Nullable | Default | Notes        |
| ---------------- | --------- | -------- | ------- | ------------ |
| `id`             | text      | ✗        | -       | _(inferred)_ |
| `client_name`    | text      | ✗        | -       | _(inferred)_ |
| `client_id`      | unknown   | ✗        | -       | _(inferred)_ |
| `tier_id`        | text      | ✗        | -       | _(inferred)_ |
| `cse_name`       | text      | ✗        | -       | _(inferred)_ |
| `cse_id`         | unknown   | ✗        | -       | _(inferred)_ |
| `effective_from` | text      | ✗        | -       | _(inferred)_ |
| `effective_to`   | unknown   | ✗        | -       | _(inferred)_ |
| `notes`          | text      | ✗        | -       | _(inferred)_ |
| `created_at`     | text      | ✗        | -       | _(inferred)_ |
| `updated_at`     | text      | ✗        | -       | _(inferred)_ |
| `created_by`     | unknown   | ✗        | -       | _(inferred)_ |

---

## Table: `topics`

**Row Count**: 30

### Columns

| Column Name     | Data Type | Nullable | Default | Notes        |
| --------------- | --------- | -------- | ------- | ------------ |
| `id`            | integer   | ✗        | -       | _(inferred)_ |
| `Meeting_Date`  | text      | ✗        | -       | _(inferred)_ |
| `Topic_Number`  | integer   | ✗        | -       | _(inferred)_ |
| `Topic_Title`   | text      | ✗        | -       | _(inferred)_ |
| `Topic_Summary` | text      | ✗        | -       | _(inferred)_ |
| `Background`    | text      | ✗        | -       | _(inferred)_ |
| `Key_Details`   | text      | ✗        | -       | _(inferred)_ |
| `created_at`    | text      | ✗        | -       | _(inferred)_ |

---

## Table: `aging_accounts`

**Row Count**: 20

### Columns

| Column Name              | Data Type | Nullable | Default | Notes        |
| ------------------------ | --------- | -------- | ------- | ------------ |
| `id`                     | integer   | ✗        | -       | _(inferred)_ |
| `cse_name`               | text      | ✗        | -       | _(inferred)_ |
| `client_name`            | text      | ✗        | -       | _(inferred)_ |
| `client_name_normalized` | text      | ✗        | -       | _(inferred)_ |
| `most_recent_comment`    | text      | ✗        | -       | _(inferred)_ |
| `current_amount`         | integer   | ✗        | -       | _(inferred)_ |
| `days_1_to_30`           | integer   | ✗        | -       | _(inferred)_ |
| `days_31_to_60`          | integer   | ✗        | -       | _(inferred)_ |
| `days_61_to_90`          | integer   | ✗        | -       | _(inferred)_ |
| `days_91_to_120`         | integer   | ✗        | -       | _(inferred)_ |
| `days_121_to_180`        | integer   | ✗        | -       | _(inferred)_ |
| `days_181_to_270`        | integer   | ✗        | -       | _(inferred)_ |
| `days_271_to_365`        | numeric   | ✗        | -       | _(inferred)_ |
| `days_over_365`          | numeric   | ✗        | -       | _(inferred)_ |
| `total_outstanding`      | numeric   | ✗        | -       | _(inferred)_ |
| `total_overdue`          | numeric   | ✗        | -       | _(inferred)_ |
| `is_inactive`            | boolean   | ✗        | -       | _(inferred)_ |
| `data_source`            | text      | ✗        | -       | _(inferred)_ |
| `import_date`            | text      | ✗        | -       | _(inferred)_ |
| `week_ending_date`       | text      | ✗        | -       | _(inferred)_ |
| `created_at`             | text      | ✗        | -       | _(inferred)_ |
| `updated_at`             | text      | ✗        | -       | _(inferred)_ |
| `client_id`              | unknown   | ✗        | -       | _(inferred)_ |

---

## Table: `notifications`

**Row Count**: 15

### Columns

| Column Name           | Data Type | Nullable | Default | Notes        |
| --------------------- | --------- | -------- | ------- | ------------ |
| `id`                  | text      | ✗        | -       | _(inferred)_ |
| `user_id`             | text      | ✗        | -       | _(inferred)_ |
| `user_email`          | unknown   | ✗        | -       | _(inferred)_ |
| `type`                | text      | ✗        | -       | _(inferred)_ |
| `title`               | text      | ✗        | -       | _(inferred)_ |
| `message`             | text      | ✗        | -       | _(inferred)_ |
| `link`                | text      | ✗        | -       | _(inferred)_ |
| `item_id`             | text      | ✗        | -       | _(inferred)_ |
| `comment_id`          | text      | ✗        | -       | _(inferred)_ |
| `triggered_by`        | text      | ✗        | -       | _(inferred)_ |
| `triggered_by_avatar` | text      | ✗        | -       | _(inferred)_ |
| `read`                | boolean   | ✗        | -       | _(inferred)_ |
| `read_at`             | unknown   | ✗        | -       | _(inferred)_ |
| `created_at`          | text      | ✗        | -       | _(inferred)_ |
| `updated_at`          | text      | ✗        | -       | _(inferred)_ |

---

## Table: `portfolio_initiatives`

**Row Count**: 6

### Columns

| Column Name       | Data Type | Nullable | Default | Notes        |
| ----------------- | --------- | -------- | ------- | ------------ |
| `id`              | text      | ✗        | -       | _(inferred)_ |
| `name`            | text      | ✗        | -       | _(inferred)_ |
| `client_name`     | text      | ✗        | -       | _(inferred)_ |
| `cse_name`        | text      | ✗        | -       | _(inferred)_ |
| `year`            | integer   | ✗        | -       | _(inferred)_ |
| `status`          | text      | ✗        | -       | _(inferred)_ |
| `category`        | text      | ✗        | -       | _(inferred)_ |
| `start_date`      | text      | ✗        | -       | _(inferred)_ |
| `completion_date` | text      | ✗        | -       | _(inferred)_ |
| `description`     | text      | ✗        | -       | _(inferred)_ |
| `created_at`      | text      | ✗        | -       | _(inferred)_ |
| `updated_at`      | text      | ✗        | -       | _(inferred)_ |

---

## Table: `nps_topic_classifications`

**Row Count**: 100

### Columns

| Column Name        | Data Type | Nullable | Default | Notes        |
| ------------------ | --------- | -------- | ------- | ------------ |
| `id`               | text      | ✗        | -       | _(inferred)_ |
| `response_id`      | text      | ✗        | -       | _(inferred)_ |
| `topic_name`       | text      | ✗        | -       | _(inferred)_ |
| `sentiment`        | text      | ✗        | -       | _(inferred)_ |
| `confidence_score` | numeric   | ✗        | -       | _(inferred)_ |
| `insight`          | text      | ✗        | -       | _(inferred)_ |
| `model_version`    | text      | ✗        | -       | _(inferred)_ |
| `classified_at`    | text      | ✗        | -       | _(inferred)_ |
| `created_at`       | text      | ✗        | -       | _(inferred)_ |
| `updated_at`       | text      | ✗        | -       | _(inferred)_ |

---

## Table: `nps_period_config`

**Row Count**: 5

### Columns

| Column Name         | Data Type | Nullable | Default | Notes        |
| ------------------- | --------- | -------- | ------- | ------------ |
| `id`                | text      | ✗        | -       | _(inferred)_ |
| `period_code`       | text      | ✗        | -       | _(inferred)_ |
| `period_name`       | text      | ✗        | -       | _(inferred)_ |
| `fiscal_year`       | text      | ✗        | -       | _(inferred)_ |
| `period_type`       | text      | ✗        | -       | _(inferred)_ |
| `surveys_sent`      | integer   | ✗        | -       | _(inferred)_ |
| `survey_start_date` | text      | ✗        | -       | _(inferred)_ |
| `survey_end_date`   | text      | ✗        | -       | _(inferred)_ |
| `sort_order`        | integer   | ✗        | -       | _(inferred)_ |
| `is_active`         | boolean   | ✗        | -       | _(inferred)_ |
| `notes`             | text      | ✗        | -       | _(inferred)_ |
| `created_at`        | text      | ✗        | -       | _(inferred)_ |
| `updated_at`        | text      | ✗        | -       | _(inferred)_ |

---

## Table: `chasen_knowledge`

**Row Count**: 16

### Columns

| Column Name     | Data Type | Nullable | Default | Notes        |
| --------------- | --------- | -------- | ------- | ------------ |
| `id`            | text      | ✗        | -       | _(inferred)_ |
| `category`      | text      | ✗        | -       | _(inferred)_ |
| `knowledge_key` | text      | ✗        | -       | _(inferred)_ |
| `title`         | text      | ✗        | -       | _(inferred)_ |
| `content`       | text      | ✗        | -       | _(inferred)_ |
| `metadata`      | jsonb     | ✗        | -       | _(inferred)_ |
| `priority`      | integer   | ✗        | -       | _(inferred)_ |
| `is_active`     | boolean   | ✗        | -       | _(inferred)_ |
| `version`       | integer   | ✗        | -       | _(inferred)_ |
| `created_at`    | text      | ✗        | -       | _(inferred)_ |
| `updated_at`    | text      | ✗        | -       | _(inferred)_ |
| `created_by`    | unknown   | ✗        | -       | _(inferred)_ |
| `updated_by`    | unknown   | ✗        | -       | _(inferred)_ |

---

## Table: `chasen_feedback`

**Row Count**: 18

### Columns

| Column Name              | Data Type | Nullable | Default | Notes        |
| ------------------------ | --------- | -------- | ------- | ------------ |
| `id`                     | text      | ✗        | -       | _(inferred)_ |
| `conversation_id`        | text      | ✗        | -       | _(inferred)_ |
| `message_index`          | integer   | ✗        | -       | _(inferred)_ |
| `user_query`             | text      | ✗        | -       | _(inferred)_ |
| `chasen_response`        | text      | ✗        | -       | _(inferred)_ |
| `rating`                 | text      | ✗        | -       | _(inferred)_ |
| `feedback_text`          | unknown   | ✗        | -       | _(inferred)_ |
| `knowledge_entries_used` | array     | ✗        | -       | _(inferred)_ |
| `confidence_score`       | unknown   | ✗        | -       | _(inferred)_ |
| `user_email`             | text      | ✗        | -       | _(inferred)_ |
| `created_at`             | text      | ✗        | -       | _(inferred)_ |
| `processed`              | boolean   | ✗        | -       | _(inferred)_ |
| `processed_at`           | unknown   | ✗        | -       | _(inferred)_ |
| `feedback_category`      | unknown   | ✗        | -       | _(inferred)_ |
| `feedback_subcategory`   | unknown   | ✗        | -       | _(inferred)_ |
| `correction_text`        | unknown   | ✗        | -       | _(inferred)_ |
| `detected_intent`        | unknown   | ✗        | -       | _(inferred)_ |
| `response_time_ms`       | unknown   | ✗        | -       | _(inferred)_ |
| `model_used`             | unknown   | ✗        | -       | _(inferred)_ |
| `rag_chunks_used`        | array     | ✗        | -       | _(inferred)_ |
| `session_id`             | unknown   | ✗        | -       | _(inferred)_ |

---

## Table: `chasen_knowledge_suggestions`

**Row Count**: 10

### Columns

| Column Name          | Data Type | Nullable | Default | Notes        |
| -------------------- | --------- | -------- | ------- | ------------ |
| `id`                 | text      | ✗        | -       | _(inferred)_ |
| `source_type`        | text      | ✗        | -       | _(inferred)_ |
| `source_id`          | text      | ✗        | -       | _(inferred)_ |
| `source_context`     | jsonb     | ✗        | -       | _(inferred)_ |
| `suggested_category` | text      | ✗        | -       | _(inferred)_ |
| `suggested_key`      | text      | ✗        | -       | _(inferred)_ |
| `suggested_title`    | text      | ✗        | -       | _(inferred)_ |
| `suggested_content`  | text      | ✗        | -       | _(inferred)_ |
| `suggested_priority` | integer   | ✗        | -       | _(inferred)_ |
| `confidence_score`   | numeric   | ✗        | -       | _(inferred)_ |
| `status`             | text      | ✗        | -       | _(inferred)_ |
| `reviewed_by`        | text      | ✗        | -       | _(inferred)_ |
| `reviewed_at`        | text      | ✗        | -       | _(inferred)_ |
| `review_notes`       | unknown   | ✗        | -       | _(inferred)_ |
| `merged_to_id`       | text      | ✗        | -       | _(inferred)_ |
| `created_at`         | text      | ✗        | -       | _(inferred)_ |
| `updated_at`         | text      | ✗        | -       | _(inferred)_ |

---

## Table: `chasen_learning_patterns`

**Row Count**: 0

**Note**: Empty table or RLS blocking access

---

## Table: `chasen_conversations`

**Row Count**: 37

### Columns

| Column Name            | Data Type | Nullable | Default | Notes        |
| ---------------------- | --------- | -------- | ------- | ------------ |
| `id`                   | text      | ✗        | -       | _(inferred)_ |
| `user_email`           | text      | ✗        | -       | _(inferred)_ |
| `title`                | text      | ✗        | -       | _(inferred)_ |
| `created_at`           | text      | ✗        | -       | _(inferred)_ |
| `updated_at`           | text      | ✗        | -       | _(inferred)_ |
| `message_count`        | integer   | ✗        | -       | _(inferred)_ |
| `last_message_preview` | text      | ✗        | -       | _(inferred)_ |
| `context`              | text      | ✗        | -       | _(inferred)_ |
| `client_name`          | unknown   | ✗        | -       | _(inferred)_ |
| `model_id`             | unknown   | ✗        | -       | _(inferred)_ |

---

## Table: `chasen_folders`

**Row Count**: 7

### Columns

| Column Name   | Data Type | Nullable | Default | Notes        |
| ------------- | --------- | -------- | ------- | ------------ |
| `id`          | text      | ✗        | -       | _(inferred)_ |
| `name`        | text      | ✗        | -       | _(inferred)_ |
| `parent_id`   | unknown   | ✗        | -       | _(inferred)_ |
| `client_name` | text      | ✗        | -       | _(inferred)_ |
| `description` | text      | ✗        | -       | _(inferred)_ |
| `color`       | text      | ✗        | -       | _(inferred)_ |
| `created_at`  | text      | ✗        | -       | _(inferred)_ |
| `updated_at`  | text      | ✗        | -       | _(inferred)_ |

---

## Table: `client_health_history`

**Row Count**: 540

### Columns

| Column Name                  | Data Type | Nullable | Default | Notes        |
| ---------------------------- | --------- | -------- | ------- | ------------ |
| `id`                         | text      | ✗        | -       | _(inferred)_ |
| `client_name`                | text      | ✗        | -       | _(inferred)_ |
| `snapshot_date`              | text      | ✗        | -       | _(inferred)_ |
| `health_score`               | integer   | ✗        | -       | _(inferred)_ |
| `status`                     | text      | ✗        | -       | _(inferred)_ |
| `nps_points`                 | integer   | ✗        | -       | _(inferred)_ |
| `compliance_points`          | integer   | ✗        | -       | _(inferred)_ |
| `working_capital_points`     | integer   | ✗        | -       | _(inferred)_ |
| `nps_score`                  | integer   | ✗        | -       | _(inferred)_ |
| `compliance_percentage`      | integer   | ✗        | -       | _(inferred)_ |
| `working_capital_percentage` | integer   | ✗        | -       | _(inferred)_ |
| `previous_status`            | unknown   | ✗        | -       | _(inferred)_ |
| `status_changed`             | boolean   | ✗        | -       | _(inferred)_ |
| `created_at`                 | text      | ✗        | -       | _(inferred)_ |

---

## Table: `health_status_alerts`

**Row Count**: 1

### Columns

| Column Name       | Data Type | Nullable | Default | Notes        |
| ----------------- | --------- | -------- | ------- | ------------ |
| `id`              | text      | ✗        | -       | _(inferred)_ |
| `client_name`     | text      | ✗        | -       | _(inferred)_ |
| `alert_date`      | text      | ✗        | -       | _(inferred)_ |
| `previous_status` | text      | ✗        | -       | _(inferred)_ |
| `new_status`      | text      | ✗        | -       | _(inferred)_ |
| `previous_score`  | integer   | ✗        | -       | _(inferred)_ |
| `new_score`       | integer   | ✗        | -       | _(inferred)_ |
| `direction`       | text      | ✗        | -       | _(inferred)_ |
| `acknowledged`    | boolean   | ✗        | -       | _(inferred)_ |
| `acknowledged_by` | text      | ✗        | -       | _(inferred)_ |
| `acknowledged_at` | text      | ✗        | -       | _(inferred)_ |
| `cse_name`        | text      | ✗        | -       | _(inferred)_ |
| `created_at`      | text      | ✗        | -       | _(inferred)_ |

---
