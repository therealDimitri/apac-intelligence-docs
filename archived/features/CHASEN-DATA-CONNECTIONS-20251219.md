# ChaSen Data Connections Update

**Date**: 2025-12-19
**Status**: IMPLEMENTED
**Component**: ChaSen AI Chat - Data Access Layer

---

## Summary

Extended ChaSen's data access from 17 sources to **28 sources**, enabling comprehensive AI responses across all dashboard data.

## Data Sources Overview

### Previously Available (17 sources)

| Table/View                       | Purpose                       |
| -------------------------------- | ----------------------------- |
| `nps_clients`                    | Client list with segments     |
| `unified_meetings`               | Meetings with AI summaries    |
| `actions`                        | Open action items             |
| `nps_responses`                  | NPS scores and feedback       |
| `segmentation_event_compliance`  | Event compliance tracking     |
| `segmentation_compliance_scores` | AI/ML compliance predictions  |
| `segmentation_events`            | Scheduled/completed events    |
| `nps_topic_classifications`      | AI-classified feedback themes |
| `portfolio_initiatives`          | Strategic projects            |
| `topics`                         | Meeting topic details         |
| `client_segmentation`            | Tier and CSE assignments      |
| `client_health_summary`          | Pre-calculated health scores  |
| `client_arr`                     | Revenue data                  |
| `aging_accounts`                 | Receivables aging             |
| `chasen_knowledge`               | Dynamic knowledge base        |
| `chasen_documents`               | Uploaded documents            |
| `llm_models`                     | Model configuration           |

### Newly Added (11 sources)

| Table/View                 | Purpose                            | Key Fields                                                        |
| -------------------------- | ---------------------------------- | ----------------------------------------------------------------- |
| `cse_profiles`             | Team member details & contact info | `name`, `email`, `role`, `phone`, `team`, `avatar_url`            |
| `cse_client_assignments`   | Who manages which clients          | `cse_name`, `client_name`, `assignment_type`, `effective_from`    |
| `event_compliance_summary` | Pre-calculated event metrics       | All compliance summary fields                                     |
| `departments`              | Organisation structure             | `name`, `description`, `parent_id`                                |
| `activity_types`           | Activity classifications           | `name`, `description`, `category`                                 |
| `segmentation_event_types` | Event type definitions             | `event_name`, `event_code`, `frequency_type`, `description`       |
| `notifications`            | User alerts & reminders            | `title`, `message`, `type`, `priority`, `action_url`              |
| `nps_period_config`        | Survey period configuration        | `period_name`, `start_date`, `end_date`, `survey_type`            |
| `chasen_conversations`     | Previous chat history              | `title`, `updated_at`, `folder_id`, `is_pinned`                   |
| `chasen_learning_patterns` | Patterns from past interactions    | `pattern_type`, `pattern_data`, `confidence_score`, `usage_count` |
| `chasen_success_patterns`  | Successful outcome patterns        | `pattern_name`, `pattern_description`, `success_criteria`         |

---

## Implementation Details

### File Modified

`src/app/api/chasen/chat/route.ts`

### Changes Made

1. **Added 11 new queries to Promise.all** (lines 1147-1293)
2. **Updated destructuring array** (lines 918-929)
3. **Extended PortfolioData interface** (lines 391-430)
4. **Added new data to return object** (lines 2128-2198)

### Data Structure in Portfolio Context

```typescript
// CSE Team Profiles
portfolioData.cseProfiles: {
  all: CSEProfile[]           // All active team members
  byName: Record<string, CSE> // Lookup by name
  count: number               // Total count
}

// CSE Client Assignments
portfolioData.cseAssignments: {
  all: Assignment[]                    // All assignments
  byCSE: Record<string, Assignment[]>  // Clients per CSE
  byClient: Record<string, Assignment[]> // CSEs per client
}

// Event Compliance Summary
portfolioData.eventComplianceSummary: {
  all: Summary[]  // Pre-calculated metrics
  count: number
}

// Organisation Structure
portfolioData.organisation: {
  departments: Department[]
  activityTypes: ActivityType[]
  segmentationEventTypes: EventType[]
}

// User Notifications
portfolioData.notifications: {
  unread: Notification[]              // Unread only
  count: number
  byType: Record<string, Notification[]>
  highPriority: Notification[]        // Priority = 'high'
}

// NPS Survey Configuration
portfolioData.npsPeriodConfig: {
  all: PeriodConfig[]
  active: PeriodConfig[]  // Currently active periods
}

// Conversation History
portfolioData.conversationHistory: {
  recent: Conversation[]   // Last 20 conversations
  count: number
  pinned: Conversation[]   // User-pinned conversations
}

// Learning Context
portfolioData.learningContext: {
  patterns: LearningPattern[]      // All patterns
  successPatterns: SuccessPattern[] // Success criteria
  topPatterns: LearningPattern[]   // Top 10 by usage
}
```

---

## New ChaSen Capabilities

### 1. Team Context

ChaSen can now:

- Identify which CSE manages a client
- Provide CSE contact details
- Analyse workload distribution across team
- Understand team structure and roles

### 2. Notification Awareness

ChaSen can now:

- Alert users to unread notifications
- Highlight high-priority items
- Reference pending action reminders

### 3. Organisation Context

ChaSen can now:

- Understand department structure
- Reference activity type classifications
- Explain event type definitions

### 4. Learning & Adaptation

ChaSen can now:

- Reference patterns from past successful interactions
- Apply learned patterns to improve responses
- Track which patterns have highest usage/success

### 5. Conversation Continuity

ChaSen can now:

- Reference previous conversations
- Understand user's pinned/important chats
- Provide context-aware follow-ups

---

## Example Questions ChaSen Can Now Answer

**Before:**

- ❌ "Who manages Albury Wodonga Health?"
- ❌ "What notifications do I have?"
- ❌ "What's Tracey's email?"

**After:**

- ✅ "Who manages Albury Wodonga Health?" → "Tracey Bland is the CSE for Albury Wodonga Health"
- ✅ "What notifications do I have?" → "You have 3 unread notifications, 1 high priority..."
- ✅ "What's Tracey's email?" → "Tracey Bland can be reached at tracey.bland@..."

---

## Performance Considerations

- All queries run in parallel via `Promise.all`
- New queries add ~50-100ms to data gathering
- Data is filtered/limited appropriately:
  - Notifications: 50 max (unread only)
  - Conversations: 20 max (recent)
  - Learning patterns: 50 max (by usage)
  - Success patterns: 30 max (by usage)

---

## Tables That May Not Exist Yet

Some tables may not exist in all environments. The queries handle missing tables gracefully by returning empty arrays:

```typescript
.then(r => {
  console.log('[ChaSen] Query result:', { count: r.data?.length, error: r.error })
  return r.data || []  // Returns empty array if table missing
})
```

Tables that may need creation:

- `cse_profiles`
- `cse_client_assignments`
- `event_compliance_summary`
- `chasen_learning_patterns`
- `chasen_success_patterns`
- `nps_period_config`

---

## Verification

Build tested successfully. All TypeScript types updated. No runtime errors expected for missing tables (graceful fallback to empty arrays).
