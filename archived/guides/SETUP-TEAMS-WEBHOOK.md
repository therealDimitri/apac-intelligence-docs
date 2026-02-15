# Microsoft Teams Webhook Setup Guide

## Overview

This guide will help you set up Microsoft Teams incoming webhook integration for APAC Intelligence Dashboard action notifications.

## Prerequisites

- Microsoft Teams admin access or channel owner permissions
- Access to the Teams channel where you want to receive notifications
- Access to your deployment environment variables (Netlify/Vercel or local `.env.local`)

---

## Step 1: Create Incoming Webhook in Teams

### Option A: Teams Desktop/Web App (Recommended)

1. **Open Microsoft Teams** (desktop app or web: https://teams.microsoft.com)

2. **Navigate to your desired channel**
   - Recommended: Create a dedicated channel called "APAC Intelligence - Actions" or "Client Success Alerts"
   - Or use an existing channel like "General" or "Notifications"

3. **Access Channel Settings**
   - Click the **"..."** (three dots) next to the channel name
   - Select **"Connectors"** from the dropdown menu

4. **Find Incoming Webhook**
   - In the Connectors dialogue, search for **"Incoming Webhook"**
   - Click **"Configure"** next to "Incoming Webhook"

5. **Configure the Webhook**
   - **Name:** `APAC Intelligence Dashboard` (or your preferred name)
   - **Upload Image (Optional):** Upload a logo for the dashboard
     - Recommended: Use Altera Digital Health logo or dashboard icon
   - Click **"Create"**

6. **Copy the Webhook URL**
   - Teams will display a webhook URL that looks like:
     ```
     https://outlook.office.com/webhook/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX@XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/IncomingWebhook/YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY/ZZZZZZZZ-ZZZZ-ZZZZ-ZZZZ-ZZZZZZZZZZZZ
     ```
   - **IMPORTANT:** Click **"Copy"** to copy this URL to your clipboard
   - **DO NOT SHARE THIS URL PUBLICLY** - it allows anyone to post to your channel

7. **Save the Configuration**
   - Click **"Done"**
   - The webhook is now active!

### Option B: Teams Admin Center (For IT Admins)

1. Go to **Microsoft Teams Admin Center**: https://admin.teams.microsoft.com
2. Navigate to **Teams** → **Manage teams**
3. Select your team
4. Go to **Apps** tab
5. Add **"Incoming Webhook"** app
6. Configure as described in Option A

---

## Step 2: Add Webhook URL to Environment Variables

### For Local Development (`.env.local`)

1. **Open your `.env.local` file** in the project root directory

2. **Add the webhook URL** at the end of the file:

   ```bash
   # Microsoft Teams Webhook for Action Notifications
   TEAMS_WEBHOOK_URL=https://outlook.office.com/webhook/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX@XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/IncomingWebhook/YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY/ZZZZZZZZ-ZZZZ-ZZZZ-ZZZZ-ZZZZZZZZZZZZ
   ```

3. **Save the file**

4. **Restart your development server**
   ```bash
   # Stop the current dev server (Ctrl+C)
   npm run dev
   ```

### For Production (Netlify)

1. **Log in to Netlify Dashboard**: https://app.netlify.com

2. **Select your site** (apac-intelligence or your site name)

3. **Navigate to Site Settings**
   - Click **"Site configuration"** in the left sidebar
   - Click **"Environment variables"**

4. **Add New Variable**
   - Click **"Add a variable"** → **"Add a single variable"**
   - **Key:** `TEAMS_WEBHOOK_URL`
   - **Value:** Paste your webhook URL
   - **Scopes:** Select all (Build time, Runtime, Local development)
   - Click **"Create variable"**

5. **Trigger Redeploy**
   - Go to **"Deploys"** tab
   - Click **"Trigger deploy"** → **"Deploy site"**
   - Wait for deployment to complete (~2-3 minutes)

### For Production (Vercel)

1. **Log in to Vercel Dashboard**: https://vercel.com/dashboard

2. **Select your project**

3. **Navigate to Settings**
   - Click **"Settings"** tab
   - Click **"Environment Variables"** in the left sidebar

4. **Add New Variable**
   - **Name:** `TEAMS_WEBHOOK_URL`
   - **Value:** Paste your webhook URL
   - **Environments:** Select all (Production, Preview, Development)
   - Click **"Save"**

5. **Redeploy**
   - Go to **"Deployments"** tab
   - Click **"..."** on the latest deployment
   - Click **"Redeploy"**

---

## Step 3: Test the Integration

### Test 1: Manual API Test (Optional)

You can test the webhook manually using curl:

```bash
curl -X POST "http://localhost:3002/api/actions/teams" \
  -H "Content-Type: application/json" \
  -d '{
    "action": {
      "id": "TEST-001",
      "description": "Test action notification from APAC Intelligence Dashboard",
      "owners": ["Your Name"],
      "dueDate": "2025-12-15",
      "priority": "high",
      "status": "open",
      "client": "Test Client"
    },
    "event": "created"
  }'
```

**Expected Result:**

- Response: `{"success":true,"message":"Action created notification posted to Teams"}`
- Teams channel shows adaptive card with action details

### Test 2: UI Test (Recommended)

1. **Navigate to Actions & Tasks page**
   - Go to: http://localhost:3002/actions (local) or your production URL

2. **Click Edit on any action**
   - Click the blue pencil icon on any action card

3. **Test "Post to Teams" button**
   - Scroll to "Microsoft 365 Integration" section
   - Click **"Post to Teams"** button (purple button)
   - Wait for success message: "✅ Posted to Microsoft Teams!"

4. **Check Teams Channel**
   - Open your Teams channel
   - You should see an adaptive card notification with:
     - Action ID and description
     - Owners, due date, priority, status, client
     - "View in Dashboard" link (should navigate to the action)

---

## Step 4: Verify Production Deployment

### After deploying to production:

1. **Test Production API**

   ```bash
   curl -X POST "https://your-production-domain.com/api/actions/teams" \
     -H "Content-Type: application/json" \
     -d '{
       "action": {
         "id": "PROD-TEST-001",
         "description": "Production test notification",
         "owners": ["Your Name"],
         "dueDate": "2025-12-15",
         "priority": "critical",
         "status": "open",
         "client": "Test Client"
       },
       "event": "created"
     }'
   ```

2. **Test from Production UI**
   - Navigate to your production actions page
   - Edit an action
   - Click "Post to Teams"
   - Verify notification appears in Teams

---

## Adaptive Card Format

When an action is posted to Teams, it displays as an adaptive card:

```
┌─────────────────────────────────────────────────────────┐
│ 🔔 Action Created                                        │
├─────────────────────────────────────────────────────────┤
│ [Action ABC123] Schedule follow-up demo                 │
│                                                          │
│ 👥 Owners: John Doe, Jane Smith                         │
│ 📅 Due Date: December 15, 2025                          │
│ 🔴 Priority: High                                       │
│ ⏳ Status: Open                                         │
│ 🏢 Client: SingHealth                                   │
│                                                          │
│ [View in Dashboard →]                                   │
└─────────────────────────────────────────────────────────┘
```

**Color Coding:**

- 🔴 **Critical/High Priority:** Red accent colour
- 🟡 **Medium Priority:** Yellow accent colour
- ⚪ **Low Priority:** Gray accent colour

**Event Types:**

- `created` - New action created
- `updated` - Action details updated
- `completed` - Action marked complete
- `overdue` - Action is overdue (future feature)
- `assigned` - Action assigned to new owner (future feature)

---

## Troubleshooting

### Error: "Teams webhook URL not configured"

**Problem:** The API returns a 500 error with message "Teams webhook URL not configured. Please set TEAMS_WEBHOOK_URL environment variable."

**Solution:**

1. Verify `TEAMS_WEBHOOK_URL` is set in your `.env.local` (local) or deployment platform (production)
2. Restart your development server: `npm run dev`
3. For production: Redeploy your site after adding the environment variable

### Error: "Failed to post to Teams"

**Problem:** The API returns a 500 error with message "Failed to post to Teams"

**Possible Causes:**

1. **Invalid Webhook URL:**
   - Verify the webhook URL is complete and hasn't been truncated
   - Ensure it starts with `https://outlook.office.com/webhook/`
   - No extra spaces or line breaks

2. **Webhook Disabled/Deleted:**
   - Check Teams channel connectors to verify webhook still exists
   - Recreate webhook if it was deleted
   - Update environment variable with new URL

3. **Network Issues:**
   - Check your internet connection
   - Verify no firewall blocking requests to `outlook.office.com`

### Notification Not Appearing in Teams

**Problem:** API returns success, but no card appears in Teams channel

**Possible Causes:**

1. **Wrong Channel:**
   - Verify you're looking at the correct channel
   - Check channel settings to confirm webhook is configured

2. **Teams Delay:**
   - Sometimes notifications take 5-10 seconds to appear
   - Refresh Teams or check notification bell

3. **Notification Settings:**
   - Check your Teams notification settings
   - Ensure channel notifications are enabled

### Adaptive Card Not Formatted Correctly

**Problem:** Card appears but formatting is broken

**Possible Causes:**

1. **Missing Data:**
   - Verify action object includes all required fields
   - Check API payload in browser network tab

2. **Webhook Version:**
   - Ensure you're using "Incoming Webhook" (not "Incoming Webhook (Legacy)")
   - Recreate webhook if using legacy version

---

## Security Best Practices

### Protecting Your Webhook URL

1. **Never Commit Webhook URL to Git**
   - `.env.local` is already in `.gitignore`
   - Never add webhook URL to `.env.example` or documentation

2. **Rotate Webhook URL Periodically**
   - Recommended: Rotate every 6-12 months
   - Delete old webhook in Teams
   - Create new webhook
   - Update environment variables

3. **Limit Access to Webhook URL**
   - Only share with authorized personnel
   - Store in password manager (1Password, LastPass)
   - Use secret management tools (Vault, AWS Secrets Manager)

4. **Monitor for Abuse**
   - Watch for unexpected notifications in Teams
   - If compromised: Delete webhook immediately and create new one

### Rate Limiting

**Microsoft Teams Webhook Limits:**

- **4 requests per second** per webhook URL
- **20,000 requests per hour** per webhook URL

**Recommendation:**

- Current implementation: 1 notification per action update
- No queueing system implemented yet
- For high-volume scenarios (>100 actions/minute), consider implementing a queue

---

## Advanced Configuration

### Multiple Webhooks for Different Channels

**Scenario:** Send notifications to different Teams channels based on client or CSE

**Future Enhancement:**

- Store webhook URLs per client in `nps_clients` table
- Store webhook URLs per CSE in `cse_profiles` table
- Modify `/api/actions/teams` to select appropriate webhook

**Example Implementation:**

```typescript
// Future: Dynamic webhook selection
const webhookUrl =
  action.client === 'SingHealth'
    ? process.env.TEAMS_WEBHOOK_SINGHEALTH
    : process.env.TEAMS_WEBHOOK_URL
```

### Custom Notification Templates

**Scenario:** Different card formats for different event types

**Current Implementation:**

- All events use same adaptive card template
- Only accent colour changes based on priority

**Future Enhancement:**

- Create custom templates per event type
- Add images/charts for completed actions
- Include action completion statistics

---

## Maintenance

### Monthly Checks

- [ ] Verify webhook is still active in Teams
- [ ] Test notification sending from production
- [ ] Review notification volume/frequency
- [ ] Check for any delivery failures in logs

### Quarterly Review

- [ ] Assess if current channel is appropriate
- [ ] Consider creating dedicated channels for high-volume clients
- [ ] Review team feedback on notification usefulness
- [ ] Update webhook configuration if team structure changes

---

## Related Documentation

- [Microsoft Teams Incoming Webhooks Documentation](https://learn.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook)
- [Adaptive Cards Documentation](https://adaptivecards.io/)
- [APAC Intelligence - Microsoft 365 Integration](./FEATURE-MICROSOFT-365-INTEGRATION.md)

---

## Support

**If you encounter issues:**

1. Check this troubleshooting guide
2. Review error logs in deployment platform
3. Verify webhook URL in Teams channel settings
4. Test with curl command to isolate UI vs API issues

**For additional help:**

- Microsoft Teams Support: https://support.microsoft.com/teams
- Deployment Platform Support (Netlify/Vercel)

---

**Setup Guide Created:** 2025-12-01
**Status:** Ready for Configuration
**Next Step:** Follow Step 1 to create your Teams webhook
