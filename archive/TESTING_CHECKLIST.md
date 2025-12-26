# Testing Checklist: Single Source of Truth Migration

**Test Date:** **\*\***\_**\*\***
**Tester:** **\*\***\_**\*\***
**Environment:** Production / Staging / Local
**Browser:** **\*\***\_**\*\***
**OS:** **\*\***\_**\*\***

---

## ✅ Pre-Test Setup

- [ ] Dev server running at `http://localhost:3002`
- [ ] Logged in with test account
- [ ] Browser console open (F12) to monitor logs
- [ ] Network tab open to verify API calls

---

## 1️⃣ Phase 1: Saved Views Migration

### Test 1.1: Existing Views Migration (If Applicable)

**Prerequisite:** Have saved views in localStorage from before migration

- [ ] Log in to dashboard
- [ ] Open browser console
- [ ] Look for migration success message:
  ```
  ✅ Migrated X saved views from localStorage to Supabase
  ```
- [ ] Verify all previous saved views appear in dropdown
- [ ] Check view names match exactly
- [ ] Verify filters are correct for each view

**Expected:** All existing views migrated successfully, localStorage cleared

**Actual:** **********\*\***********\_**********\*\***********

### Test 1.2: Create New Saved View

- [ ] Navigate to Briefing Room (`/meetings`)
- [ ] Set filters:
  - Time Range: "This Month"
  - View Mode: "My Meetings"
  - Status: "Completed"
- [ ] Click "Save View" button
- [ ] Enter name: "Test View - [Your Name]"
- [ ] Click "Save"
- [ ] Verify success message appears
- [ ] Refresh page
- [ ] Verify view still appears in saved views list

**Expected:** View saved and persists after refresh

**Actual:** **********\*\***********\_**********\*\***********

### Test 1.3: Cross-Device Sync

- [ ] Note the name of a saved view on Device 1
- [ ] Open dashboard on Device 2 (different browser/computer)
- [ ] Log in with same account
- [ ] Navigate to Briefing Room
- [ ] Verify saved view from Device 1 appears

**Expected:** Saved view syncs across devices

**Actual:** **********\*\***********\_**********\*\***********

### Test 1.4: Delete Saved View

- [ ] Select a test view from dropdown
- [ ] Click delete icon
- [ ] Confirm deletion
- [ ] Verify view removed from list
- [ ] Refresh page
- [ ] Verify view does not reappear

**Expected:** View deleted permanently

**Actual:** **********\*\***********\_**********\*\***********

### Test 1.5: Rename Saved View

- [ ] Select a saved view
- [ ] Click edit/rename icon
- [ ] Enter new name: "Renamed Test View"
- [ ] Save changes
- [ ] Refresh page
- [ ] Verify new name persists

**Expected:** View renamed successfully

**Actual:** **********\*\***********\_**********\*\***********

### Test 1.6: View Sharing - Public

- [ ] Create or select a saved view
- [ ] Click "Share" icon
- [ ] Select "Share with Everyone"
- [ ] Confirm sharing
- [ ] Log in as different user (or ask colleague)
- [ ] Verify shared view appears in their saved views list

**Expected:** View visible to all team members

**Actual:** **********\*\***********\_**********\*\***********

### Test 1.7: View Sharing - Private

- [ ] Create or select a saved view
- [ ] Click "Share" icon
- [ ] Select "Share with Specific People"
- [ ] Enter colleague's email address
- [ ] Save sharing settings
- [ ] Ask colleague to check their dashboard
- [ ] Verify view appears for them
- [ ] Ask different colleague (not in share list)
- [ ] Verify view does NOT appear for them

**Expected:** View only visible to specified emails

**Actual:** **********\*\***********\_**********\*\***********

---

## 2️⃣ Phase 2: User Preferences Migration

### Test 2.1: Preferences Migration (If Applicable)

**Prerequisite:** Have preferences in localStorage from before migration

- [ ] Log in to dashboard
- [ ] Check browser console for:
  ```
  ✅ Migrated user preferences from localStorage to Supabase
  ```
- [ ] Verify dashboard layout matches previous settings
- [ ] Check favorite clients are preserved
- [ ] Check hidden clients are preserved
- [ ] Verify notification settings unchanged

**Expected:** All preferences migrated successfully

**Actual:** **********\*\***********\_**********\*\***********

### Test 2.2: Default View Preference

- [ ] Navigate to Intelligence Dashboard home
- [ ] Change default view setting (e.g., from "My Clients" to "All Clients")
- [ ] Save preferences
- [ ] Log out
- [ ] Log back in
- [ ] Verify default view preference persisted

**Expected:** Default view setting saved and restored on login

**Actual:** **********\*\***********\_**********\*\***********

### Test 2.3: Favorite Clients

- [ ] Navigate to client list
- [ ] Add a client to favourites
- [ ] Refresh page
- [ ] Verify client still marked as favorite
- [ ] Log in on different device
- [ ] Verify favorite status synced

**Expected:** Favorite clients persist and sync across devices

**Actual:** **********\*\***********\_**********\*\***********

### Test 2.4: Hidden Clients

- [ ] Navigate to client list
- [ ] Hide a client
- [ ] Refresh page
- [ ] Verify client remains hidden
- [ ] Remove from hidden list
- [ ] Verify client reappears

**Expected:** Hidden clients setting persists

**Actual:** **********\*\***********\_**********\*\***********

### Test 2.5: Notification Preferences

- [ ] Open notification settings
- [ ] Toggle various notification types:
  - [ ] Critical Alerts
  - [ ] Compliance Warnings
  - [ ] Upcoming Events
  - [ ] NPS Changes
- [ ] Save preferences
- [ ] Refresh page
- [ ] Verify settings persisted

**Expected:** Notification preferences saved successfully

**Actual:** **********\*\***********\_**********\*\***********

### Test 2.6: Dashboard Layout

- [ ] Toggle dashboard widgets:
  - [ ] Command Centre visibility
  - [ ] Smart Insights visibility
  - [ ] ChaSen visibility
- [ ] Save layout
- [ ] Refresh page
- [ ] Verify layout persisted

**Expected:** Dashboard layout settings saved

**Actual:** **********\*\***********\_**********\*\***********

---

## 3️⃣ Phase 3: CSE Profile & Role Assignment

### Test 3.1: CSE Role Detection

**For CSE Users:**

- [ ] Log in as CSE user
- [ ] Verify name displays correctly in header
- [ ] Navigate to client list
- [ ] Verify only assigned clients visible
- [ ] Check client count matches expected number
- [ ] Verify role indicator shows "CSE" (if applicable)

**Expected:** CSE sees only their assigned clients

**Actual:** **********\*\***********\_**********\*\***********

### Test 3.2: Manager Role Detection

**For Manager Users:**

- [ ] Log in as Manager/Executive user
- [ ] Verify name displays correctly
- [ ] Navigate to client list
- [ ] Verify ALL clients visible
- [ ] Verify role indicator shows "Manager" or "Executive"

**Expected:** Manager sees all clients

**Actual:** **********\*\***********\_**********\*\***********

### Test 3.3: Dynamic Role Change (Admin Test Only)

**Requires:** Database access

- [ ] Update user's role in `cse_profiles` table
- [ ] User refreshes dashboard
- [ ] Verify new role reflected immediately
- [ ] Verify client access updated accordingly

**Expected:** Role changes take effect without code deployment

**Actual:** **********\*\***********\_**********\*\***********

### Test 3.4: New Team Member Addition (Admin Test Only)

**Requires:** Database access

- [ ] Add new user to `cse_profiles` table
- [ ] New user logs in
- [ ] Verify role assigned correctly
- [ ] Verify assigned clients visible

**Expected:** New team member has immediate access

**Actual:** **********\*\***********\_**********\*\***********

---

## 4️⃣ Performance & Reliability Tests

### Test 4.1: Cache Performance

- [ ] Navigate to Briefing Room
- [ ] Note page load time: **\_\_\_** ms
- [ ] Refresh page (within 5 minutes)
- [ ] Note cached load time: **\_\_\_** ms
- [ ] Verify cached load faster than initial

**Expected:** Cache improves performance, loads < 500ms

**Actual:** **********\*\***********\_**********\*\***********

### Test 4.2: Cache Invalidation

- [ ] Navigate to Briefing Room
- [ ] Note meeting count in stats
- [ ] Delete a meeting
- [ ] Check stats update immediately
- [ ] Verify count decreased by 1

**Expected:** Stats update within 1 second

**Actual:** **********\*\***********\_**********\*\***********

### Test 4.3: Offline Behavior

- [ ] Disable internet connection
- [ ] Try to create a saved view
- [ ] Note error handling behavior
- [ ] Re-enable internet
- [ ] Retry creating saved view

**Expected:** Graceful error handling, retry succeeds

**Actual:** **********\*\***********\_**********\*\***********

### Test 4.4: Concurrent Edits

- [ ] Open dashboard on two devices with same account
- [ ] On Device 1: Create a saved view "Test Concurrent 1"
- [ ] On Device 2: Create a saved view "Test Concurrent 2"
- [ ] Refresh both devices
- [ ] Verify both views appear on both devices

**Expected:** No data conflicts, both views saved

**Actual:** **********\*\***********\_**********\*\***********

---

## 5️⃣ Security & Access Control Tests

### Test 5.1: Row Level Security (RLS)

- [ ] Log in as User A
- [ ] Create a private saved view
- [ ] Note the view ID from database
- [ ] Log in as User B
- [ ] Try to access User A's private view (direct URL manipulation)
- [ ] Verify access denied

**Expected:** RLS prevents unauthorized access

**Actual:** **********\*\***********\_**********\*\***********

### Test 5.2: Shared View Access Control

- [ ] Create a view shared with specific email: user@example.com
- [ ] Log in as user@example.com
- [ ] Verify view visible
- [ ] Log in as different-user@example.com
- [ ] Verify view NOT visible

**Expected:** Only specified users can access

**Actual:** **********\*\***********\_**********\*\***********

### Test 5.3: Data Isolation

- [ ] Log in as CSE
- [ ] Open browser console → Network tab
- [ ] Navigate to client list
- [ ] Check API response
- [ ] Verify only assigned clients returned (not all clients)

**Expected:** API respects role-based filtering

**Actual:** **********\*\***********\_**********\*\***********

---

## 6️⃣ Error Handling & Edge Cases

### Test 6.1: Duplicate View Names

- [ ] Create saved view: "Test View"
- [ ] Try to create another view: "Test View"
- [ ] Note behavior

**Expected:** System allows duplicates OR shows clear warning

**Actual:** **********\*\***********\_**********\*\***********

### Test 6.2: Very Long View Name

- [ ] Try to create view with 200+ character name
- [ ] Note behavior

**Expected:** Validation prevents excessively long names

**Actual:** **********\*\***********\_**********\*\***********

### Test 6.3: Invalid Filter Data

- [ ] Manually corrupt saved view filters in database
- [ ] Try to load corrupted view
- [ ] Note error handling

**Expected:** Graceful fallback to default filters

**Actual:** **********\*\***********\_**********\*\***********

### Test 6.4: Browser Data Clear

- [ ] Create saved views and preferences
- [ ] Clear all browser data (cookies, cache, localStorage)
- [ ] Log back in
- [ ] Verify saved views still present
- [ ] Verify preferences still present

**Expected:** Data survives browser data clear

**Actual:** **********\*\***********\_**********\*\***********

---

## 7️⃣ Console Log Verification

### Expected Console Messages

Check browser console contains these SUCCESS messages:

- [ ] `✅ Migrated X saved views from localStorage to Supabase` (if applicable)
- [ ] `✅ Migrated user preferences from localStorage to Supabase` (if applicable)
- [ ] `✅ Preferences saved to Supabase` (when updating preferences)

### Unexpected Console Messages

Check console does NOT contain these ERROR messages:

- [ ] No `Failed to fetch saved views` errors
- [ ] No `Failed to save preferences` errors
- [ ] No `Failed to migrate` errors
- [ ] No database connection errors

---

## 8️⃣ Database Verification

**Requires:** Database access (admin only)

### Check saved_views Table

```sql
SELECT COUNT(*), user_email
FROM saved_views
GROUP BY user_email
ORDER BY COUNT(*) DESC;
```

- [ ] Verify all users have their views migrated
- [ ] Check no duplicate entries
- [ ] Verify `is_shared` flags correct
- [ ] Verify `shared_with` arrays populated correctly

### Check user_preferences Table

```sql
SELECT user_email, created_at, updated_at
FROM user_preferences
ORDER BY created_at DESC;
```

- [ ] Verify all active users have preferences row
- [ ] Check `updated_at` changes when preferences modified
- [ ] Verify JSON columns valid

### Check cse_profiles Table

```sql
SELECT email, full_name, role
FROM cse_profiles
WHERE role IS NOT NULL;
```

- [ ] Verify all 19 CSEs have role assigned
- [ ] Verify managers have correct role
- [ ] Verify no NULL roles for active users

---

## 🐛 Bugs Found

| Bug # | Description | Severity     | Steps to Reproduce | Status |
| ----- | ----------- | ------------ | ------------------ | ------ |
| 1     |             | High/Med/Low |                    |        |
| 2     |             | High/Med/Low |                    |        |
| 3     |             | High/Med/Low |                    |        |

---

## ✅ Test Summary

**Total Tests:** **_ / _**
**Passed:** **\_
**Failed:** \_**
**Blocked:** **\_
**Pass Rate:** \_**%

**Overall Assessment:**

- [ ] Ready for Production
- [ ] Minor issues - proceed with caution
- [ ] Critical issues - do not deploy

**Tester Signature:** ****\*\*****\_****\*\*****
**Date:** ****\*\*****\_****\*\*****

---

**Notes:**
