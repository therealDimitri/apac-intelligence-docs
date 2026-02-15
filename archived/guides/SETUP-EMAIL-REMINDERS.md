# Email Reminders Setup Guide

## Overview

The APAC Intelligence Dashboard includes an automated email reminder system for actions using Microsoft Graph sendMail API. This system can send individual action reminders and daily/weekly digest emails.

## Features

### Email Types

1. **Overdue Action Alerts** 🚨
   - Sent for actions past their due date
   - Red-themed urgent notification
   - Includes action details and dashboard link

2. **Due Today Reminders** ⏰
   - Sent for actions due on the current day
   - Yellow-themed notice
   - Prompts immediate action

3. **Upcoming Action Reminders** 📅
   - Sent for actions due within 3 days (configurable)
   - Blue-themed preview
   - Optional feature

4. **Action Digest Emails** 📊
   - Summary of all actions requiring attention
   - Includes statistics (overdue, due today, due this week, total)
   - Lists top 10 priority actions
   - Can be sent daily or weekly

### Email Features

- **Professional HTML Design**: Beautiful responsive email templates
- **Priority Color Coding**: Visual indicators (red=critical, amber=high, blue=medium, gray=low)
- **Dashboard Integration**: Direct links to actions in dashboard
- **Automatic Recipient Detection**: Emails sent to action owners based on CSE profiles
- **Batch Processing**: Efficient handling of multiple reminders

---

## Prerequisites

### Required Data

1. **CSE Profile Emails**
   - Email addresses must be configured in `cse_profiles` table
   - Each CSE must have `email` field populated
   - Example: `gilbert.so@alteradigitalhealth.com`

2. **Microsoft Graph API Access**
   - User must be signed in with Microsoft account (OAuth)
   - Requires `Mail.Send` permission scope
   - Access token automatically obtained via NextAuth

3. **Action Owner Assignment**
   - Actions must have `Owners` field populated
   - Format: Comma-separated CSE names (e.g., "Gilbert So, Laura Messing")
   - Owners must match `full_name` in `cse_profiles` table

### Database Setup

**Verify CSE Profile Emails:**

```sql
-- Check which CSEs have email addresses configured
SELECT full_name, email
FROM cse_profiles
WHERE email IS NOT NULL;

-- Add/update CSE email addresses
UPDATE cse_profiles
SET email = 'gilbert.so@alteradigitalhealth.com'
WHERE full_name = 'Gilbert So';
```

---

## API Endpoints

### POST /api/actions/reminders

Send email reminders based on action due dates.

**Authentication:** Requires valid Microsoft OAuth session

**Request Body:**

```typescript
{
  mode?: 'auto' | 'overdue-only' | 'upcoming-only' | 'digest',
  recipients?: string[],    // Optional: override default recipients
  daysAhead?: number        // Default: 3 (send reminders for actions due within X days)
}
```

**Modes:**

- **`auto`** (default): Send overdue + due today reminders
- **`overdue-only`**: Send only overdue action alerts
- **`upcoming-only`**: Send only upcoming action reminders
- **`digest`**: Send summary email (requires `recipients` parameter)

**Response:**

```json
{
  "success": true,
  "message": "Successfully sent 5 reminder email(s)",
  "stats": {
    "total": 52,
    "overdue": 3,
    "dueToday": 2,
    "upcoming": 7,
    "emailsSent": 5
  },
  "errors": [] // Optional: array of error messages if some emails failed
}
```

**Example Requests:**

```bash
# Send overdue and due today reminders (auto mode)
curl -X POST "http://localhost:3002/api/actions/reminders" \
  -H "Content-Type: application/json" \
  -d '{}'

# Send only overdue reminders
curl -X POST "http://localhost:3002/api/actions/reminders" \
  -H "Content-Type: application/json" \
  -d '{"mode": "overdue-only"}'

# Send daily digest to specific recipients
curl -X POST "http://localhost:3002/api/actions/reminders" \
  -H "Content-Type: application/json" \
  -d '{
    "mode": "digest",
    "recipients": ["manager@alteradigitalhealth.com", "team@alteradigitalhealth.com"]
  }'

# Send upcoming reminders for actions due within 5 days
curl -X POST "http://localhost:3002/api/actions/reminders" \
  -H "Content-Type: application/json" \
  -d '{"mode": "upcoming-only", "daysAhead": 5}'
```

### GET /api/actions/reminders

Get reminder statistics without sending emails (preview mode).

**Response:**

```json
{
  "total": 52,
  "overdue": 3,
  "dueToday": 2,
  "upcoming": 7,
  "actions": {
    "overdue": [
      {
        "id": "O03",
        "description": "Schedule follow-up demo",
        "dueDate": "2025-11-28",
        "owners": "Gilbert So, Laura Messing"
      }
    ],
    "dueToday": [...],
    "upcoming": [...]
  }
}
```

---

## Manual Execution

### Option 1: API Call (Recommended for Testing)

1. **Sign in to the dashboard** at https://apac-intelligence.alteradigitalhealth.com
2. **Open browser console** (F12 → Console tab)
3. **Run API call:**

```javascript
// Send overdue and due today reminders
fetch('/api/actions/reminders', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({}),
})
  .then(res => res.json())
  .then(data => console.log('Reminders sent:', data))
```

### Option 2: Direct URL Request

**Using curl:**

```bash
# Get reminder statistics (no emails sent)
curl -s "https://apac-intelligence.alteradigitalhealth.com/api/actions/reminders"

# Send reminders (requires authentication - use session cookie)
curl -X POST "https://apac-intelligence.alteradigitalhealth.com/api/actions/reminders" \
  -H "Content-Type: application/json" \
  -H "Cookie: next-auth.session-token=YOUR_SESSION_TOKEN" \
  -d '{}'
```

---

## Automated Execution (Scheduled)

### Option 1: Netlify Scheduled Functions (Recommended)

**Create:** `netlify/functions/scheduled-reminders.ts`

```typescript
import { schedule } from '@netlify/functions'

const handler = schedule('0 9 * * *', async () => {
  // Daily at 9am AEST
  try {
    const response = await fetch(
      'https://apac-intelligence.alteradigitalhealth.com/api/actions/reminders',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${process.env.SERVICE_ACCOUNT_TOKEN}`, // System auth
        },
        body: JSON.stringify({ mode: 'auto' }),
      }
    )

    const data = await response.json()
    console.log('Daily reminders sent:', data)

    return {
      statusCode: 200,
      body: JSON.stringify(data),
    }
  } catch (error) {
    console.error('Failed to send reminders:', error)
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Failed to send reminders' }),
    }
  }
})

export { handler }
```

**Setup:**

1. Add file to `netlify/functions/` directory
2. Deploy to Netlify
3. Function will run automatically at 9am daily

### Option 2: GitHub Actions Workflow

**Create:** `.github/workflows/daily-reminders.yml`

```yaml
name: Daily Action Reminders

on:
  schedule:
    - cron: '0 23 * * *' # 9am AEST (UTC+11) = 11pm UTC previous day
  workflow_dispatch: # Allow manual trigger

jobs:
  send-reminders:
    runs-on: ubuntu-latest
    steps:
      - name: Send Reminders
        env:
          API_URL: https://apac-intelligence.alteradigitalhealth.com
          SERVICE_TOKEN: ${{ secrets.SERVICE_ACCOUNT_TOKEN }}
        run: |
          response=$(curl -X POST "$API_URL/api/actions/reminders" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $SERVICE_TOKEN" \
            -d '{"mode": "auto"}')

          echo "Response: $response"

          # Check if successful
          if echo "$response" | jq -e '.success' > /dev/null; then
            echo "✅ Reminders sent successfully"
          else
            echo "❌ Failed to send reminders"
            exit 1
          fi
```

**Setup:**

1. Add file to `.github/workflows/` directory
2. Add `SERVICE_ACCOUNT_TOKEN` to GitHub repository secrets
3. Commit and push to GitHub
4. Workflow will run automatically at 9am AEST daily

### Option 3: Vercel Cron Jobs

**Update:** `vercel.json`

```json
{
  "crons": [
    {
      "path": "/api/actions/reminders",
      "schedule": "0 23 * * *"
    }
  ]
}
```

**Note:** Requires Vercel Pro plan for cron jobs

### Option 4: External Cron Service (EasyCron, cron-job.org)

1. **Sign up** at https://www.easycron.com or https://cron-job.org
2. **Create cron job:**
   - URL: `https://apac-intelligence.alteradigitalhealth.com/api/actions/reminders`
   - Method: `POST`
   - Schedule: `0 9 * * *` (9am daily)
   - Headers: `Content-Type: application/json`
   - Body: `{}`
3. **Enable job**

---

## Email Templates

### Individual Action Reminder Template

**Subject:** `🚨 OVERDUE: [O03] Schedule follow-up demo`

**Body Preview:**

```
┌─────────────────────────────────────────┐
│ 🚨 Overdue Action Alert                 │
│                                          │
│ This action is overdue. Immediate       │
│ attention required.                      │
├─────────────────────────────────────────┤
│ 🔴 HIGH PRIORITY                        │
│                                          │
│ [O03] Schedule follow-up demo           │
│                                          │
│ Client: SingHealth                      │
│ Assigned To: Gilbert So, Laura Messing  │
│ Due Date: Thursday, 28 November 2025    │
│ Status: Open                             │
│                                          │
│ [View in Dashboard →]                   │
└─────────────────────────────────────────┘
```

### Digest Email Template

**Subject:** `📊 Daily Action Digest - 3 Overdue, 2 Due Today`

**Body Preview:**

```
┌─────────────────────────────────────────┐
│ 📊 Daily Action Digest                  │
│                                          │
│ Here's your summary of actions          │
│ requiring attention                      │
├─────────────────────────────────────────┤
│  3         │  2        │                │
│  Overdue   │  Due Today│                │
├────────────┼───────────┤                │
│  7         │  52       │                │
│  This Week │  Total    │                │
├─────────────────────────────────────────┤
│ Actions Requiring Immediate Attention   │
│                                          │
│ 🔴 [O03] Schedule follow-up demo        │
│    SingHealth • Due: 28/11/2025         │
│                                          │
│ 🟡 [M05] Quarterly business review      │
│    Epworth • Due: 01/12/2025            │
│                                          │
│ ... and 8 more actions                  │
│                                          │
│ [View All Actions →]                    │
└─────────────────────────────────────────┘
```

---

## Troubleshooting

### Error: "Unauthorized. Please sign in."

**Problem:** User not authenticated or session expired

**Solution:**

1. Sign in to dashboard with Microsoft account
2. Ensure OAuth token has `Mail.Send` permission
3. Check `session.accessToken` is present

### Error: "Failed to send email"

**Possible Causes:**

1. **Invalid Access Token**
   - Check token expiry
   - Re-authenticate if needed

2. **Missing Mail.Send Permission**
   - Update Azure AD app registration
   - Add `Mail.Send` to API permissions
   - Grant admin consent

3. **Invalid Recipient Email**
   - Verify CSE email addresses in database
   - Check email format is valid

**Debugging:**

```sql
-- Check which CSEs are missing emails
SELECT full_name, email
FROM cse_profiles
WHERE email IS NULL OR email = '';

-- Check action owners that won't receive emails
SELECT DISTINCT Owners
FROM actions
WHERE Status IN ('open', 'in-progress')
  AND Owners NOT IN (
    SELECT full_name FROM cse_profiles WHERE email IS NOT NULL
  );
```

### No Emails Sent (0 emails sent)

**Check:**

1. **Are there open actions?**

   ```sql
   SELECT COUNT(*) FROM actions
   WHERE Status IN ('open', 'in-progress');
   ```

2. **Do they have due dates?**

   ```sql
   SELECT COUNT(*) FROM actions
   WHERE Status IN ('open', 'in-progress')
     AND Due_Date IS NOT NULL;
   ```

3. **Are any overdue or due today?**
   ```bash
   curl -s "http://localhost:3002/api/actions/reminders" | jq .
   ```

### Emails Not Appearing in Inbox

**Check:**

1. **Spam/Junk Folder**: Microsoft Graph emails may be filtered
2. **Sent Items**: Check sender's Sent Items folder (emails saved automatically)
3. **Email Rules**: Check for Outlook rules that move/delete emails
4. **Quarantine**: Check Office 365 quarantine for blocked emails

---

## Configuration

### Environment Variables

**Required:**

- `NEXT_PUBLIC_SUPABASE_URL` - Supabase project URL
- `SUPABASE_SERVICE_ROLE_KEY` - Service role key for database access
- `NEXTAUTH_URL` - Dashboard URL (https://apac-intelligence.alteradigitalhealth.com)
- `NEXTAUTH_SECRET` - NextAuth secret for session encryption

**Optional:**

- `REMINDER_DEFAULT_RECIPIENTS` - Fallback emails if action has no owners
- `REMINDER_DAYS_AHEAD` - Days ahead for upcoming reminders (default: 3)

### Customization

**Change Reminder Schedule:**

Edit reminder logic in `src/app/api/actions/reminders/route.ts`:

```typescript
// Change "days ahead" for upcoming reminders
const daysAhead = 7 // Send reminders for actions due within 7 days

// Change categorization logic
if (dueDate < today) {
  // Overdue
} else if (dueDate.getTime() === today.getTime()) {
  // Due today
} else if (dueDate <= upcomingThreshold) {
  // Upcoming
}
```

**Change Email Templates:**

Edit email generation in `src/lib/microsoft-graph.ts`:

```typescript
// Customize email subject
const subject = `Custom prefix: [${action.id}] ${action.description}`

// Customize HTML template
function generateActionReminderEmailBody(...) {
  // Modify HTML structure, colours, text, etc.
}
```

---

## Best Practices

### Recommended Schedule

- **Daily Reminders**: 9am AEST every day
  - Mode: `auto` (overdue + due today)
  - Ensures CSEs start their day aware of urgent actions

- **Weekly Digest**: Monday 9am AEST
  - Mode: `digest`
  - Recipients: Leadership team emails
  - Provides high-level overview

### Testing

**Before Production:**

1. Test with GET endpoint first (preview mode)
2. Send test email to yourself only
3. Verify email formatting in Outlook
4. Check spam folder
5. Test different action scenarios (overdue, due today, upcoming)

**Test Command:**

```bash
# Preview reminder statistics (no emails sent)
curl -s "http://localhost:3002/api/actions/reminders" | jq .

# Send test reminder to yourself
curl -X POST "http://localhost:3002/api/actions/reminders" \
  -H "Content-Type: application/json" \
  -d '{"mode": "digest", "recipients": ["your.email@alteradigitalhealth.com"]}'
```

### Performance

- Email sending is sequential (one at a time)
- Large batches (>20 emails) may take 30+ seconds
- Microsoft Graph has rate limits: 30 emails/minute per user
- Consider implementing queue for high-volume scenarios

---

## Related Documentation

- [Microsoft Graph sendMail API](https://learn.microsoft.com/en-us/graph/api/user-sendmail)
- [Microsoft 365 Integration](./FEATURE-MICROSOFT-365-INTEGRATION.md)
- [Teams Webhook Setup](./SETUP-TEAMS-WEBHOOK.md)
- [NextAuth Configuration](https://next-auth.js.org/configuration/options)

---

## Support

**Common Issues:**

- Check database connection and CSE profiles
- Verify Microsoft OAuth permissions
- Review Supabase logs for errors
- Test with GET endpoint before sending emails

**For Additional Help:**

- Microsoft Graph API: https://docs.microsoft.com/graph
- NextAuth Documentation: https://next-auth.js.org
- Netlify Functions: https://docs.netlify.com/functions/scheduled-functions

---

**Setup Guide Created:** 2025-12-01
**Status:** Ready for Configuration
**Next Step:** Configure CSE email addresses in database and test with GET endpoint
