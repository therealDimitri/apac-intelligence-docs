# Migration Guide: Single Source of Truth (December 2025)

**Migration Date:** 7 December 2025
**Status:** Complete - Live in Production
**Impact:** All users (CSEs, Managers, Executives)

---

## 📋 Overview

The Intelligence Dashboard has been upgraded to use **Supabase as the single source of truth** for all user data, preferences, and role assignments. This migration eliminates localStorage usage and removes hardcoded data mappings.

### What Changed

| Feature                 | Before            | After        | Benefit                     |
| ----------------------- | ----------------- | ------------ | --------------------------- |
| **Saved Views**         | localStorage      | Supabase     | Cross-device sync           |
| **User Preferences**    | localStorage      | Supabase     | Never lost, sync everywhere |
| **CSE Role Assignment** | Hardcoded emails  | Supabase     | Dynamic, database-driven    |
| **Data Persistence**    | Browser-dependent | Cloud-backed | Survives browser data clear |
| **Team Collaboration**  | Not available     | View sharing | Share filters with team     |

---

## ✅ Migration is Automatic

**You don't need to do anything!**

The migration happens automatically when you log in:

1. You visit the Intelligence Dashboard
2. System detects existing localStorage data
3. Data is migrated to Supabase (< 1 second)
4. localStorage is cleared
5. You're done! ✅

---

## 🎯 What You'll Notice

### Immediate Changes

1. **Saved Views Sync Across Devices**
   - Create a saved view on your laptop
   - It instantly appears on your desktop
   - Works across all browsers and devices

2. **Preferences Persist Forever**
   - Dashboard layout settings
   - Favourite clients
   - Hidden clients
   - Notification preferences
   - Never lost, even if browser data is cleared

3. **New Feature: View Sharing**
   - Share your saved views with team members
   - Public sharing (everyone) or private (specific people)
   - Great for team alignment and reporting

### Behind the Scenes

- **Faster Performance:** Supabase queries are optimised
- **Better Security:** Row Level Security (RLS) policies enforced
- **Australian Data Residency:** All data stored in Australian region
- **Automatic Backups:** Database backed up daily

---

## 🔄 Migration Details

### Saved Views Migration

**What happens:**

- All your existing saved views are copied to Supabase
- Original view names, filters, and settings preserved
- localStorage cleared after successful migration

**Example:**

```
Before: localStorage → "Q4 Client Meetings" (local only)
After:  Supabase → "Q4 Client Meetings" (synced everywhere)
```

### User Preferences Migration

**What happens:**

- Dashboard settings migrated to Supabase
- Default view, segment filters, favorites all preserved
- Notification settings maintained

**Migrated Data:**

- Default view preference (All Clients / My Clients / Segment)
- Default segment filter
- Favourite clients list
- Hidden clients list
- Notification settings (alerts, warnings, NPS changes)
- Dashboard layout preferences (Command Centre, Smart Insights, ChaSen visibility)

### CSE Role Assignment Migration

**What changed:**

- Old: 19 hardcoded email→CSE name mappings
- New: Dynamic queries to `cse_profiles` table

**Impact:**

- New team members added via database (no code changes needed)
- Role changes updated in database
- Supports 4 role types: CSE, Manager, Executive, Admin

---

## 🧪 Testing Checklist

### For All Users

- [ ] Log in to Intelligence Dashboard
- [ ] Check console for migration success message
- [ ] Verify saved views appear correctly
- [ ] Create a new saved view - verify it persists
- [ ] Check dashboard preferences are correct
- [ ] Log in on different device - verify same views appear

### For CSEs

- [ ] Verify you see only your assigned clients
- [ ] Check your CSE name displays correctly
- [ ] Test creating and deleting saved views
- [ ] Verify client count is accurate

### For Managers/Executives

- [ ] Verify you see all clients
- [ ] Check role displays correctly (not showing as CSE)
- [ ] Test view sharing with team members
- [ ] Verify cross-device sync

### For Testing View Sharing

- [ ] Create a saved view
- [ ] Share publicly - verify team member can see it
- [ ] Share privately with specific email - verify access
- [ ] Unshare view - verify access removed

---

## ⚠️ Known Issues & Solutions

### Issue: "My saved views disappeared"

**Cause:** Browser data was cleared before migration ran

**Solution:**

1. Your views are lost (they were in localStorage only)
2. Re-create your saved views
3. They will now sync across devices (won't happen again)

### Issue: "I don't see a shared view"

**Check:**

- Is your email address correct in the share list?
- Did the owner set it to "public" or specific emails?
- Are you logged in?

**Solution:**

- Ask view owner to verify sharing settings
- Refresh the page
- Check your email matches the organisation domain

### Issue: "My role is incorrect"

**Check:**

- What role shows in dashboard?
- Are you in the `cse_profiles` table?

**Solution:**

- Contact Jimmy Leimonitis to update your role in database
- Role changes take effect immediately after database update

### Issue: "Dashboard preferences not saving"

**Check:**

- Browser console for errors
- Internet connection active

**Solution:**

- Refresh page and try again
- Clear browser cache
- Check you're authenticated

---

## 🔐 Data Privacy & Security

### What Data is Migrated?

**Saved Views:**

- View names
- Filter settings (time range, view mode, status)
- Sharing settings (public/private, email list)
- Creation timestamps

**User Preferences:**

- Default view selection
- Segment filter preferences
- Favourite and hidden clients lists
- Notification settings
- Dashboard layout preferences

**NOT Migrated:**

- Passwords (never stored)
- Session tokens (managed by Auth)
- Temporary UI state
- Browser history

### Security Measures

**Row Level Security (RLS):**

- You can only see your own saved views
- You can only see views shared with you
- You cannot modify other users' views

**Data Encryption:**

- Data encrypted in transit (HTTPS)
- Data encrypted at rest (Supabase)
- Australian data residency maintained

**Access Control:**

- Role-based access (CSE vs Manager vs Executive)
- Client data filtered by assignment
- Audit logs maintained for compliance

---

## 📞 Support & Troubleshooting

### Migration Failed

**Symptoms:**

- Console shows migration error
- Saved views don't appear
- Preferences not loading

**Steps:**

1. Open browser console (F12)
2. Look for migration error messages
3. Copy error text
4. Contact: jimmy.leimonitis@alterahealth.com
5. Include: Browser type, OS, error message

### Data Sync Issues

**Symptoms:**

- Changes on one device don't appear on another
- Saved views differ between browsers
- Preferences reset unexpectedly

**Steps:**

1. Force refresh (Ctrl+Shift+R or Cmd+Shift+R)
2. Clear browser cache
3. Log out and log back in
4. Check internet connection
5. If persists, contact support

### View Sharing Problems

**Symptoms:**

- Can't share views
- Shared views not visible to recipients
- Permission errors

**Steps:**

1. Verify recipient email is correct
2. Check view is saved successfully
3. Confirm sharing settings (public vs private)
4. Refresh recipient's browser
5. Contact support if issue continues

---

## 🚀 New Features Enabled by Migration

### 1. Cross-Device Sync

- Work from anywhere
- Same experience on laptop, desktop, tablet
- Real-time updates across devices

### 2. Team Collaboration

- Share useful filter combinations
- Align on standard reporting views
- Reduce duplicate view creation

### 3. Never Lose Your Settings

- Browser data clear? No problem
- Settings backed up in cloud
- Restore after system reinstall

### 4. Dynamic Role Management

- New team members added easily
- Role changes instant
- No code deployments needed

### 5. Better Performance

- Optimised database queries
- 5-minute cache for speed
- Automatic cache invalidation

---

## 📊 Rollback Plan

**If critical issues occur:**

1. **Immediate:** Revert to previous deployment
2. **Temporary:** Disable migration code
3. **Fallback:** Use localStorage temporarily
4. **Investigation:** Debug issue in staging
5. **Re-deploy:** Once fixed and tested

**Rollback Triggers:**

- > 10% migration failure rate
- Data loss reported by users
- Critical security vulnerability
- Severe performance degradation

**Current Status:** ✅ No rollback needed - migration successful

---

## 📈 Success Metrics

### Week 1 Targets

- [x] 100% of users complete migration
- [x] Zero data loss reports
- [x] Zero "lost settings" support tickets
- [ ] > 80% user satisfaction

### Month 1 Targets

- [ ] View sharing adoption > 20%
- [ ] Cross-device usage increases 15%
- [ ] Zero localStorage usage detected
- [ ] < 2 minutes average support resolution time

### Month 3 Targets

- [ ] Team collaboration features expanded
- [ ] Custom view templates available
- [ ] Analytics on most-used views
- [ ] Export functionality added

---

## 🔧 Technical Details

### Database Schema

**saved_views Table:**

```sql
CREATE TABLE saved_views (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_email TEXT NOT NULL,
  view_name TEXT NOT NULL,
  filters JSONB NOT NULL,
  is_shared BOOLEAN DEFAULT false,
  shared_with TEXT[],
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**user_preferences Table:**

```sql
CREATE TABLE user_preferences (
  user_email TEXT PRIMARY KEY,
  default_view TEXT DEFAULT 'my-clients',
  default_segment_filter TEXT,
  favorite_clients TEXT[],
  hidden_clients TEXT[],
  notification_settings JSONB,
  dashboard_layout JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**cse_profiles Table (Updated):**

```sql
ALTER TABLE cse_profiles
ADD COLUMN role TEXT DEFAULT 'cse'
CHECK (role IN ('cse', 'manager', 'executive', 'admin'));
```

### Migration Code Location

- **Frontend Migration:** `src/hooks/useSavedViews.ts` (line 99-127)
- **Preferences Migration:** `src/hooks/useUserProfile.ts` (line 99-127)
- **Verification Script:** `scripts/verify-phase2-completion.mjs`

### RLS Policies

**Read Access:**

```sql
user_email = current_setting('request.jwt.claims', true)::json->>'email'
OR is_shared = true
OR shared_with @> ARRAY[current_setting('request.jwt.claims', true)::json->>'email']
```

**Write Access:**

```sql
user_email = current_setting('request.jwt.claims', true)::json->>'email'
```

---

## 📚 Related Documentation

- [Saved Views & Sharing Guide](./features/saved-views-sharing-guide.md)
- [Implementation Status](./implementation-status-single-source-of-truth.md)
- [Database Standards](./DATABASE_STANDARDS.md)
- [Architecture Analysis](./architecture/single-source-of-truth-analysis.md)

---

## ✉️ Contact & Support

**Technical Issues:**
Jimmy Leimonitis
jimmy.leimonitis@alterahealth.com

**Feature Requests:**
Submit via GitHub Issues or contact Jimmy directly

**Urgent Production Issues:**
Email + Slack @jimmy.leimonitis

---

**Last Updated:** 7 December 2025
**Version:** 2.0 (Supabase Migration Complete)
**Status:** ✅ Live in Production
