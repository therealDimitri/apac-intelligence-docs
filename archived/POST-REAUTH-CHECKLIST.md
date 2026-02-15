# Post Re-Authentication Checklist

After signing out and back in, use this checklist to verify everything works.

## 1. Sign Out and Sign In

- [ ] Click **Logout** in sidebar (bottom left)
- [ ] Sign in with Microsoft account
- [ ] **Grant Calendars.Read permission** when Azure AD prompts
- [ ] Verify you're signed in (name shows in sidebar)

## 2. Check Browser Console

Open browser DevTools (F12) and check Console tab:

### Expected Logs:

```
[Auth] Configuration initialized with NEXTAUTH_URL: https://apac-cs-dashboards.com
```

### No Errors Expected:

- ❌ No "401 Unauthorized" errors
- ❌ No "403 Forbidden" errors
- ❌ No "Access token expired" errors

## 3. Test Outlook Import

- [ ] Navigate to Briefing Room (/meetings)
- [ ] Click **Import from Outlook** button
- [ ] Modal should open and load calendar events

### Expected Behavior:

1. **Loading spinner** appears
2. **Calendar events list** displays (may take 5-10 seconds)
3. Events show:
   - ✅ Meeting subject
   - ✅ Client name (if detected)
   - ✅ Date and time
   - ✅ Duration
   - ✅ Attendee count

### If Loading Fails:

Check browser console for error message:

- "Unable to access calendar" → Permission not granted
- "Access token expired" → Token refresh failed
- "Failed to fetch calendar events" → Graph API error

## 4. Test Meeting Selection

- [ ] Click on a meeting to select it (orange highlight)
- [ ] Click "Select All" button
- [ ] Verify count updates: "X of Y selected"
- [ ] Unselect a meeting
- [ ] Verify count decreases

## 5. Test Skip Functionality

- [ ] Click **Skip** button on a meeting
- [ ] Verify meeting is grayed out
- [ ] Verify meeting removed from selection
- [ ] Click "Show Skipped" button
- [ ] Verify skipped meeting appears
- [ ] Click **Unskip** button
- [ ] Verify meeting returns to normal list

## 6. Test Import Process

- [ ] Select 2-3 meetings
- [ ] Click **Import X Meetings** button
- [ ] Wait for import to complete

### Expected Success:

```
Import Successful!
Imported meetings to your dashboard

✓ Imported: 3
• Skipped (duplicates): 0
✗ Failed: 0
```

### If Import Fails:

Check error message in modal:

- "Unauthorized" → Session expired, sign in again
- "No access token" → Permission issue
- Specific meeting failed → Check that meeting's error

## 7. Verify Imported Meetings

- [ ] Close import modal
- [ ] Refresh Briefing Room page
- [ ] Verify new meetings appear in list
- [ ] Check meeting details:
  - [ ] Client name
  - [ ] Date/time correct
  - [ ] Duration shows (e.g., "60 min")
  - [ ] Meeting type (if detected)
  - [ ] Status (should be "scheduled" or "completed")

## 8. Test Duplicate Prevention

- [ ] Open Outlook import again
- [ ] Try to import same meetings again
- [ ] Expected: "Skipped (duplicates): X"
- [ ] Imported count should be 0

## 9. Browser Console Debugging

If anything fails, check browser console (F12 → Console tab) for:

### Import API Logs:

```
[Import] Successfully imported: Meeting Name
[Import] Skipping duplicate: Meeting Name (event-id-123)
```

### Error Logs:

```
[Outlook Events API] Error: <error details>
[Import Meetings API] Error: <error details>
```

### Network Tab:

- [ ] Check `/api/outlook/events` request
  - Status should be **200 OK**
  - Response should have `"success": true`
  - `data` array should contain meetings

- [ ] Check `/api/meetings/import` request
  - Status should be **200 OK**
  - Response should have `"success": true`
  - `results.imported` should be > 0

## 10. Test Token Refresh (Long-term)

After 1+ hours of being signed in:

- [ ] Try importing again
- [ ] Should work automatically (token auto-refreshes)
- [ ] No manual re-auth needed
- [ ] Check console for: `[Auth] Access token refreshed successfully`

## Common Issues & Solutions

### Issue: "Unable to access calendar"

**Solution:**

1. Sign out completely
2. Clear browser cache/cookies
3. Sign in again
4. Make sure to **grant calendar permission** when prompted

### Issue: Calendar loads but import fails

**Solution:**

1. Open browser console (F12)
2. Check Network tab → `/api/meetings/import` request
3. Look at Response tab for specific error
4. Common causes:
   - Missing required fields
   - Invalid date format
   - Database connection issue

### Issue: Some meetings import, others fail

**Solution:**

1. Check import results in modal
2. Look at failed meeting names
3. Common causes:
   - Invalid duration (all-day events)
   - Missing start/end time
   - Special characters in subject

### Issue: Profile photo not showing

**Solution:**

1. Check if you have photo set in Microsoft account
2. Fallback to initials is normal if no photo
3. If shows broken image, check browser console

### Issue: Meetings imported but don't appear

**Solution:**

1. Refresh Briefing Room page (F5)
2. Check if filters are active (Filter button)
3. Check search box (clear any search text)
4. Verify meetings in database (62 total currently)

## Success Criteria

All of these should work after re-authentication:

✅ Outlook import modal opens
✅ Calendar events load from Outlook
✅ Meetings can be selected
✅ Skip/Unskip functionality works
✅ Import completes successfully
✅ Imported meetings appear in Briefing Room
✅ Duplicate detection prevents re-import
✅ Token auto-refreshes (no manual re-auth needed after 1 hour)

## Diagnostic Tools

If issues persist, run:

```bash
node debug-import.js
```

This validates:

- Environment variables
- Supabase connection
- Database schema
- Import functionality
- Duplicate detection

## Getting Help

If problems continue after re-authentication:

1. **Check browser console logs** (F12 → Console)
2. **Check Network tab** (F12 → Network)
3. **Run debug script**: `node debug-import.js`
4. **Check Netlify deploy logs** (if recent deployment)
5. **Verify environment variables** in Netlify dashboard

## Related Documentation

- `debug-import.js` - Diagnostic script
- `docs/BUG-REPORT-DASHBOARD-ENHANCEMENTS-SESSION-2.md` - Skip functionality
- `docs/DEPLOYMENT-PLATFORM-ANALYSIS.md` - Platform setup
- `src/auth.ts` - Token refresh implementation
