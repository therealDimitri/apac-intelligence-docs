# ChaSen Hyper-Personalisation Feature

**Date**: 2025-12-19
**Status**: IMPLEMENTED
**Component**: ChaSen AI Chat - User Personalisation

---

## Summary

Added hyper-personalisation features to ChaSen, enabling personalised greetings using the user's first name and role-specific content tailoring.

## Features Implemented

### 1. First Name Extraction

ChaSen now extracts and uses the user's first name in responses.

```typescript
// Helper function added
function getFirstName(fullName: string): string {
  if (!fullName) return 'there'
  const parts = fullName.trim().split(' ')
  return parts[0] || 'there'
}

// Usage
getFirstName("Dimitri Leimonitis") → "Dimitri"
getFirstName("Tracey Bland") → "Tracey"
```

**Example ChaSen Response:**

> "Hi Dimitri, based on your portfolio data, here are your key priorities for today..."

### 2. Role-Based Priority Configuration

Each role has defined priorities that ChaSen uses to tailor responses.

```typescript
const ROLE_PRIORITIES = {
  cse: {
    title: 'Client Success Executive',
    description: 'Focused on individual client health and relationship management',
    keyMetrics: [
      'Client health scores',
      'Upcoming meetings and actions',
      'NPS trends for your clients',
      'Compliance status',
      'At-risk indicators',
    ],
    focusAreas: [
      'Building strong client relationships',
      'Meeting compliance targets',
      'Identifying upsell opportunities',
      'Managing client expectations',
      'Preventing churn',
    ],
    suggestedQuestions: [
      'Which of my clients need attention this week?',
      'What are the key talking points for my next client meeting?',
      'Which clients have declining health scores?',
      'What actions are overdue for my portfolio?',
      'How is my compliance tracking this quarter?',
      'Which clients are due for a check-in?',
    ],
  },
  manager: {
    title: 'CS Manager',
    description: 'Focused on team performance and portfolio-wide metrics',
    keyMetrics: [
      'Team workload distribution',
      'Portfolio-wide health trends',
      'CSE performance comparisons',
      'At-risk client counts',
      'Revenue metrics (ARR)',
    ],
    focusAreas: [
      'Balancing team workload',
      'Identifying coaching opportunities',
      'Strategic resource allocation',
      'Portfolio risk management',
      'Team performance optimisation',
    ],
    suggestedQuestions: [
      'How is the team workload distributed?',
      'Which CSEs have the highest at-risk client counts?',
      'What is our overall portfolio health trend?',
      'Which clients need escalation?',
      'What is our team compliance rate?',
      'Who has capacity for additional clients?',
    ],
  },
  executive: {
    title: 'Executive',
    description: 'Focused on strategic metrics and business outcomes',
    keyMetrics: [
      'Total portfolio ARR',
      'Revenue at risk',
      'NPS trends',
      'Churn indicators',
      'Strategic account health',
    ],
    focusAreas: [
      'Business growth opportunities',
      'Revenue protection',
      'Strategic account management',
      'Market expansion',
      'Executive relationship building',
    ],
    suggestedQuestions: [
      'What is our total ARR at risk?',
      'Which strategic accounts need attention?',
      'What is our NPS trend this quarter?',
      'What are the top growth opportunities?',
      'Which accounts are up for renewal soon?',
      'What is our overall portfolio health?',
    ],
  },
  admin: {
    title: 'Administrator',
    description: 'Full access to all data and system configuration',
    keyMetrics: ['System health', 'Data completeness', 'User activity', 'All portfolio metrics'],
    focusAreas: ['Data quality', 'System configuration', 'User management', 'Process optimisation'],
    suggestedQuestions: [
      'What is the overall portfolio status?',
      'Which clients have incomplete data?',
      'What are the system-wide trends?',
      'Are there any data quality issues?',
      'What is the team utilisation rate?',
      'Which areas need attention?',
    ],
  },
}
```

### 3. Personalised System Prompt

The system prompt now includes user-specific context:

```
**USER CONTEXT - PERSONALISATION:**
You are assisting Dimitri (Dimitri Leimonitis, dimitri.leimonitis@alterahealth.com).
- Role: CS Manager
- Focus: Focused on team performance and portfolio-wide metrics

**PERSONALISED COMMUNICATION:**
- Address Dimitri by their first name in greetings
- Tailor responses to their role priorities
- Use "you" and "your" to make responses personal

**DIMITRI'S KEY METRICS (prioritise these in responses):**
- Team workload distribution
- Portfolio-wide health trends
- CSE performance comparisons
- At-risk client counts
- Revenue metrics (ARR)

**DIMITRI'S FOCUS AREAS:**
- Balancing team workload
- Identifying coaching opportunities
- Strategic resource allocation
- Portfolio risk management
- Team performance optimisation
```

### 4. Welcome Prompt Personalisation

The welcome/daily briefing prompt now:

- Greets user by first name
- Tailors recommendations to role priorities
- Includes role-specific suggested follow-up questions

### 5. UI Data Available

The portfolio data now includes a `userPersonalisation` object for UI components:

```typescript
portfolioData.userPersonalisation: {
  firstName: string         // "Dimitri"
  fullName: string          // "Dimitri Leimonitis"
  role: string              // "manager"
  roleTitle: string         // "CS Manager"
  roleDescription: string   // "Focused on team performance..."
  keyMetrics: string[]      // Role-specific metrics
  focusAreas: string[]      // Role-specific focus areas
  suggestedQuestions: string[] // Role-specific suggested questions
}
```

---

## Implementation Details

### File Modified

`src/app/api/chasen/chat/route.ts`

### Changes Made

1. **Added `getFirstName()` helper function** (line 236-240)
2. **Added `ROLE_PRIORITIES` configuration** (lines 245-354)
3. **Added `getRoleContext()` helper function** (lines 359-361)
4. **Updated `getSystemPrompt()`** to include personalised greeting and role context (lines 2595-2639)
5. **Updated `getWelcomePrompt()`** to use first name and role priorities (lines 2389-2459)
6. **Added `userPersonalisation` to portfolio data return** (lines 2372-2386)
7. **Updated `PortfolioData` interface** (lines 563-573)

---

## Usage Examples

### ChaSen Greeting (Before)

> "Based on the portfolio data, here are the key insights..."

### ChaSen Greeting (After)

> "Hi Dimitri, here's your portfolio overview for today. Based on your role as CS Manager, I've prioritised team workload and at-risk client metrics..."

### Role-Specific Response Tailoring

**CSE asking "What should I focus on?":**

> "Tracey, your top priorities today are:
>
> 1. Albury Wodonga Health - health score dropped to 84, schedule a check-in
> 2. Your Q4 compliance is at 78% - 2 more meetings needed
> 3. 3 overdue actions for your clients..."

**Manager asking "What should I focus on?":**

> "Dimitri, here's your team overview:
>
> 1. Team workload: Tracey has 12 clients, Sarah has 8 - consider rebalancing
> 2. 5 clients across the team are at-risk (health < 60)
> 3. Portfolio compliance is at 72% - below 80% target..."

---

## Role Mapping

No separate database table needed - roles are defined in the existing `UserContext` interface:

```typescript
interface UserContext {
  email: string
  name: string
  cseName: string | null
  assignedClients: string[]
  role: 'cse' | 'manager' | 'executive' | 'admin' // Already exists
}
```

The `ROLE_PRIORITIES` configuration in the code defines what each role cares about.

---

## Future Enhancements

1. **User preferences table** - Allow users to customise their key metrics
2. **Learning from interactions** - Track which questions users ask most
3. **Time-based greetings** - "Good morning, Dimitri" vs "Good afternoon, Dimitri"
4. **Saved preferences** - Remember user's preferred response format
