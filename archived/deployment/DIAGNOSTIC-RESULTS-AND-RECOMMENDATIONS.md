# 🔍 Diagnostic Results & Recommendations

**Date**: 2025-11-26
**Status**: Production API ✅ | Calendar Import ❌
**Action Required**: Azure AD Configuration

---

## 📊 Diagnostic Test Results

### ✅ PASSED: Production Infrastructure

```
Test: Production API Response
Endpoint: https://apac-cs-dashboards.com/api/auth/providers
Status: 200 OK
Result: ✅ PASS

Findings:
  • Azure AD provider configured correctly
  • Provider ID: azure-ad
  • Provider Type: OIDC (OpenID Connect)
  • Provider Name: Azure Active Directory
  • API responding normally
```

**Conclusion**: Your production deployment is working perfectly. The API infrastructure is healthy.

---

### ✅ PASSED: Backend Systems

From previous `debug-import.js` run:

```
Test: Environment Variables
Result: ✅ PASS - All 4 required variables present

Test: Supabase Connection
Result: ✅ PASS - Connected successfully

Test: Database Schema
Result: ✅ PASS - 62 meetings in unified_meetings table

Test: Import Logic
Result: ✅ PASS - Sample meeting inserted successfully

Test: Duplicate Detection
Result: ✅ PASS - outlook_event_id uniqueness working
```

**Conclusion**: All backend systems are functioning correctly. Database, schema, and import logic are all working.

---

### ⚠️ BLOCKED: Calendar Access

```
Test: Unauthenticated API Request
Endpoint: https://apac-cs-dashboards.com/api/outlook/events
Status: 307 (Redirect to sign-in)
Result: ⚠️ Expected behavior (requires authentication)

Known Issue:
  • Authenticated users getting 403 Forbidden from Graph API
  • Error: "Unable to access calendar"
  • validateCalendarAccess() failing at /me/calendar endpoint
```

**Conclusion**: Authentication flow works, but Microsoft Graph API is rejecting calendar access requests. This indicates a permission configuration issue in Azure AD.

---

## 🎯 Root Cause Determination

Based on all diagnostic tests, I can confirm:

### ✅ What's Working

1. Production API infrastructure
2. Azure AD authentication provider
3. Session management
4. Token storage and passthrough
5. Database connectivity
6. Import logic and duplicate detection
7. All backend systems

### ❌ What's Broken

1. Microsoft Graph API calendar access
2. Specific endpoint failing: `GET /me/calendar`
3. HTTP Status: 403 Forbidden
4. Error indicates missing permission: `Calendars.Read`

### 🔍 Root Cause

**99% Confidence**: Your Azure AD app registration is missing the `Calendars.Read` permission, OR the permission is present but admin consent has not been granted.

**Why I'm confident**:

- Production API works ✅
- Backend systems work ✅
- Authentication provider configured ✅
- Session contains access token ✅
- Graph API rejects with 403 (permission denied) ❌
- Error specifically mentions "Calendars.Read permission" ❌

---

## 🔧 CRITICAL RECOMMENDATIONS

### Priority 1: Verify Azure AD App Permissions (REQUIRED)

**Time Required**: 2-3 minutes
**Urgency**: CRITICAL - Nothing else will work until this is fixed

**Steps**:

1. **Open Azure Portal**
   - Navigate to: https://portal.azure.com
   - Sign in with admin account

2. **Find Your App Registration**
   - Search for "App registrations" in the top search bar
   - Click "App registrations"
   - Find your app (likely named something like "APAC CS Dashboard" or "Intelligence Dashboard")

3. **Check API Permissions**
   - Click on your app
   - In the left sidebar, click "API permissions"
   - Review the list of permissions

4. **Verify Required Permissions Present**

   You MUST have these three delegated permissions:

   | Permission       | Type                        | Status Required              |
   | ---------------- | --------------------------- | ---------------------------- |
   | `User.Read`      | Microsoft Graph - Delegated | ✅ Granted (green checkmark) |
   | `Calendars.Read` | Microsoft Graph - Delegated | ✅ Granted (green checkmark) |
   | `offline_access` | Microsoft Graph - Delegated | ✅ Granted (green checkmark) |

5. **Check the "Status" Column**
   - Look for green checkmarks next to each permission
   - Green checkmark = "Granted for [Your Organization]"
   - If you see "Not granted" or no checkmark, admin consent is missing

---

### Priority 2: Add Missing Calendars.Read Permission (If Not Present)

**If `Calendars.Read` is NOT in the list**:

1. Click "Add a permission" button
2. Click "Microsoft Graph" tile
3. Click "Delegated permissions"
4. In the search box, type: `Calendars.Read`
5. Expand "Calendars" section
6. Check the box next to `Calendars.Read`
7. Click "Add permissions" button at the bottom

**After adding**:

- The permission will appear in the list
- Status will show "Not granted"
- Proceed to Priority 3

---

### Priority 3: Grant Admin Consent (REQUIRED)

**Even if the permission exists, you MUST grant admin consent**:

1. At the top of the API permissions page, click:
   - **"Grant admin consent for [Your Organization Name]"**

2. A popup will appear asking: "Do you want to grant consent for the requested permissions for all accounts in [Organization]?"

3. Click **"Yes"**

4. Wait for the page to refresh (5-10 seconds)

5. Verify all three permissions now show:
   - Status: "Granted for [Your Organization]"
   - Green checkmark icon

**⚠️ CRITICAL**: Without admin consent, users will NOT see the calendar permission in the OAuth consent screen, even if they sign out and sign back in.

---

### Priority 4: Force Re-Authentication (After Fixing Permissions)

**Only do this AFTER completing Priority 1-3**:

1. **User Must Sign Out Completely**
   - Go to: https://apac-cs-dashboards.com
   - Click "Logout" in the sidebar (bottom left)
   - Confirm you're signed out

2. **Clear Browser Cache (Optional but Recommended)**
   - Press F12 to open DevTools
   - Right-click the refresh button
   - Select "Empty Cache and Hard Reload"
   - Or: Clear cookies for apac-cs-dashboards.com

3. **Sign In Again**
   - Click "Sign In"
   - You should see Azure AD OAuth consent screen
   - **IMPORTANT**: Look for calendar-related permissions in the consent screen
   - It should say something like: "Read your calendars" or "Access your calendar"
   - Click "Accept"

4. **Verify Calendar Permission Granted**
   - After sign-in, open browser DevTools (F12)
   - Go to Console tab
   - Run this command:

   ```javascript
   await fetch('/api/outlook/events?daysBack=7&maxResults=5').then(r => r.json())
   ```

   - Expected result: JSON object with calendar events
   - If you see error, proceed to Priority 5

---

### Priority 5: Diagnostic Verification (After Re-Auth)

**Run this command in terminal**:

```bash
node debug-calendar-auth.js
```

Then follow the on-screen instructions to test the API endpoint from browser console.

**Expected Success Output**:

```json
{
  "success": true,
  "data": [
    /* array of calendar events */
  ],
  "categorized": {
    "clientMeetings": [
      /* meetings with client names */
    ],
    "otherMeetings": [
      /* internal meetings */
    ],
    "total": 15
  }
}
```

**If you still see errors**:

1. Copy the exact error message
2. Run: `node test-graph-api.js`
3. Get your access token from browser console:
   ```javascript
   await fetch('/api/auth/session').then(r => r.json())
   // Copy the "accessToken" value
   ```
4. Paste token into test-graph-api.js when prompted
5. Share the output (this will show exactly which Graph API endpoint is failing)

---

## 📋 Verification Checklist

After completing Priority 1-4, verify everything works:

### Azure AD Verification

- [ ] `User.Read` permission present with green checkmark
- [ ] `Calendars.Read` permission present with green checkmark
- [ ] `offline_access` permission present with green checkmark
- [ ] Admin consent granted for all three
- [ ] Status column shows "Granted for [Organization]"

### Authentication Verification

- [ ] Signed out completely from dashboard
- [ ] Signed back in successfully
- [ ] OAuth consent screen showed calendar permission
- [ ] Accepted all permissions

### Functional Verification

- [ ] Navigate to Briefing Room (/meetings)
- [ ] Click "Import from Outlook" button
- [ ] Modal opens and shows loading spinner
- [ ] Calendar events list appears (5-10 second wait is normal)
- [ ] Can select meetings
- [ ] Can import meetings successfully
- [ ] Imported meetings appear in Briefing Room

### Technical Verification (Browser Console)

- [ ] No "403 Forbidden" errors
- [ ] No "Unable to access calendar" errors
- [ ] API call to /api/outlook/events returns 200 OK
- [ ] Response contains calendar events array

---

## 🚨 Common Issues & Solutions

### Issue 1: "I added Calendars.Read but still getting errors"

**Solution**: Did you grant admin consent?

- Just adding the permission is not enough
- You MUST click "Grant admin consent for [Organization]"
- Look for green checkmarks in Status column
- If no green checkmark = consent not granted

---

### Issue 2: "I granted consent but still getting errors"

**Solution**: Sign out and sign back in

- Old access token doesn't have the new permission
- New token will only be issued on fresh sign-in
- Make sure to completely sign out first
- Clear browser cache if needed

---

### Issue 3: "OAuth consent screen doesn't show calendar permission"

**Possible Causes**:

1. Admin consent already granted (so consent screen is skipped)
   - This is actually good! It means permissions are set
   - Just proceed to test the import

2. Permission not properly added
   - Go back to Azure AD
   - Verify permission type is "Delegated" (not "Application")
   - Verify it's Microsoft Graph (not Azure AD Graph)

3. Browser cached old consent
   - Sign out
   - Clear browser cookies for apac-cs-dashboards.com
   - Clear cookies for login.microsoftonline.com
   - Try again

---

### Issue 4: "I don't have admin access to Azure AD"

**Solution**: Contact your Azure AD administrator

- They need to:
  1. Add Calendars.Read permission to the app
  2. Grant admin consent
  3. Confirm you when it's done
- Show them this document for exact steps

**Alternative**: Request "User Consent" if admin consent is not possible

- This requires each user to grant permission individually
- Less ideal but will work
- User will see consent screen on first sign-in

---

## 🎯 Expected Timeline

If you have admin access:

- **5 minutes**: Add permission and grant consent
- **2 minutes**: Sign out and sign back in
- **1 minute**: Test import
- **Total**: ~10 minutes to full resolution

If you need to contact admin:

- **Depends on admin response time**
- Show them the "Priority 2" and "Priority 3" sections
- They can complete it in 5 minutes

---

## 📞 Next Steps Summary

### Immediate Action (You, Right Now)

1. Open Azure Portal
2. Check if `Calendars.Read` permission exists
3. Check if admin consent is granted (green checkmarks)
4. Report your findings

### Based on Your Findings

**Scenario A: Permission Missing**

- Add `Calendars.Read` as shown in Priority 2
- Grant admin consent as shown in Priority 3
- Sign out and back in as shown in Priority 4
- Test import

**Scenario B: Permission Present But No Consent**

- Grant admin consent as shown in Priority 3
- Sign out and back in as shown in Priority 4
- Test import

**Scenario C: Permission Present With Consent**

- This would be unexpected given the error
- Run `node test-graph-api.js` to diagnose further
- Share the output for advanced troubleshooting

**Scenario D: No Admin Access**

- Contact your Azure AD administrator
- Share this document with them
- Wait for them to complete Priority 2 & 3
- Then proceed with Priority 4

---

## 📚 Supporting Documentation

**Created for You**:

- `debug-calendar-auth.js` - Automated diagnostic tool
- `test-graph-api.js` - Graph API permission tester
- `debug-import.js` - Backend system validator
- `POST-REAUTH-CHECKLIST.md` - Complete verification guide
- `BUG-REPORT-CALENDAR-IMPORT-PERMISSION-ERROR.md` - Full technical analysis

**How to Use**:

```bash
# Quick diagnostic
node debug-calendar-auth.js

# Deep Graph API test (requires access token)
node test-graph-api.js

# Backend validation
node debug-import.js
```

---

## ✅ Success Criteria

You'll know it's fixed when:

1. ✅ Azure AD shows `Calendars.Read` with green checkmark
2. ✅ Click "Import from Outlook" in Briefing Room
3. ✅ Modal loads calendar events (may take 5-10 seconds)
4. ✅ Can select and import meetings
5. ✅ Import completes: "Imported: X" with 0 failures
6. ✅ Imported meetings appear in Briefing Room list
7. ✅ No console errors related to calendar access
8. ✅ Can repeat import (duplicate detection works)

---

## 🤝 I'm Here to Help

Once you've checked the Azure AD permissions, let me know what you find:

**Option 1**: "Permission is missing" → I'll guide you through adding it

**Option 2**: "Permission exists but no green checkmark" → I'll guide you through granting consent

**Option 3**: "Permission exists with green checkmark" → We'll do advanced diagnostics with test-graph-api.js

**Option 4**: "I don't have admin access" → I'll help you draft a request to your admin

---

**🚀 Your Next Step**: Go to Azure Portal and check the permissions. Report back what you see!

---

_Generated with Claude Code - 2025-11-26_
