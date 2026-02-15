# Saved Views & Sharing Guide

**Feature:** Save and share custom filter views in the Briefing Room

**Available:** December 2025

---

## 📋 Overview

The Saved Views feature allows you to save your favourite filter combinations and share them with your team. All saved views are stored in Supabase and sync across all your devices.

---

## 🎯 Key Features

### 1. **Save Custom Views**

Save your current filter settings with a memorable name.

**Filters You Can Save:**

- Time range (All / This Week / This Month)
- View mode (All Meetings / My Meetings)
- Meeting status (Completed / Scheduled / Cancelled)

### 2. **Cross-Device Sync**

Your saved views automatically sync across:

- Desktop browser
- Laptop browser
- Multiple devices
- Different locations

All changes appear instantly on all your devices.

### 3. **Share with Team**

Share your saved views with colleagues in two ways:

**Public Sharing:**

- Share with everyone in the organisation
- Anyone can see and use your view
- Great for standard team filters

**Private Sharing:**

- Share with specific team members only
- Choose who can access your view
- Perfect for department-specific filters

---

## 📖 How to Use

### Creating a Saved View

1. **Set Your Filters**
   - Go to Briefing Room
   - Adjust time range, view mode, and status filters
   - Review the meetings shown

2. **Save the View**
   - Click "Save View" button
   - Enter a descriptive name (e.g., "Q4 Client Meetings")
   - Choose sharing settings (optional)
   - Click "Save"

3. **Access Anytime**
   - Your view appears in the Saved Views dropdown
   - Click to instantly apply those filters
   - Works across all devices

### Sharing a Saved View

#### Option 1: Share with Everyone

1. Create or select an existing view
2. Click "Share" icon next to the view name
3. Select "Share with Everyone"
4. Confirm

**Result:** All team members can now see and use this view

#### Option 2: Share with Specific People

1. Create or select an existing view
2. Click "Share" icon next to the view name
3. Select "Share with Specific People"
4. Enter email addresses:
   - tracey.bland@alterahealth.com
   - jonathan.salisbury@alterahealth.com
5. Click "Share"

**Result:** Only specified people can see and use this view

### Managing Your Views

#### Rename a View

1. Click the "Edit" icon next to the view name
2. Enter the new name
3. Click "Save"

#### Delete a View

1. Click the "Delete" icon next to the view name
2. Confirm deletion
3. View removed from all devices

#### Update Sharing Settings

1. Click "Share" icon
2. Change from public to private (or vice versa)
3. Update email list if using private sharing
4. Click "Save"

---

## 💡 Best Practices

### Naming Conventions

Use clear, descriptive names:

**Good Examples:**

- "Q4 2025 - Completed Client Meetings"
- "This Month - My Scheduled Meetings"
- "Healthcare Clients - All Time"
- "Aged Care - This Week"

**Avoid:**

- "View 1", "Test", "My View"
- Single-word names
- Vague descriptions

### When to Share Publicly

Share with everyone when:

- The view is useful for the whole team
- It represents a standard filter combination
- It's for a common reporting period (e.g., "This Month")
- It helps with team alignment

### When to Share Privately

Share with specific people when:

- The view is department-specific
- It's for a project team
- It contains client-specific filters
- Only certain CSEs need access

### Organising Your Views

**Create views for common tasks:**

- Weekly review meetings
- Monthly reporting
- Client-specific reviews
- Segment-focused analysis

**Delete outdated views:**

- Old quarter-specific views
- Completed project filters
- Deprecated team structures

---

## 🔄 Migration from localStorage

### Automatic Migration

**What happens on first login:**

If you had saved views before December 2025, they will be automatically migrated to Supabase:

1. You log in to the Intelligence Dashboard
2. System detects saved views in browser storage
3. Views are copied to Supabase database
4. Browser storage is cleared
5. Your views now sync across devices ✅

**Important Notes:**

- Migration happens only once per user
- All your existing views are preserved
- No action required from you
- Takes less than 1 second

### What Changed?

| Before (localStorage)        | After (Supabase)         |
| ---------------------------- | ------------------------ |
| Saved in browser only        | Saved in cloud database  |
| Lost if browser data cleared | Never lost               |
| No cross-device sync         | Syncs across all devices |
| No sharing capability        | Can share with team      |
| Manual backup required       | Auto-backed up           |

---

## 🛠️ Troubleshooting

### My Saved Views Disappeared

**Cause:** Browser data was cleared before migration

**Solution:**

1. Re-create your saved views
2. They will now sync across devices
3. Won't happen again with Supabase storage

### I Can't See a Shared View

**Check:**

1. Are you logged in with the correct email?
2. Was the view shared with your email address?
3. Is the view set to "Public" or "Private"?

**Solution:**

- Ask the view owner to verify sharing settings
- Check your email matches the shared list
- Refresh the page

### Changes Not Syncing

**Check:**

1. Are you connected to the internet?
2. Did the save operation complete?
3. Look for confirmation message

**Solution:**

- Refresh the page
- Check browser console for errors
- Contact support if issue persists

### Duplicate Views After Migration

**Cause:** Migration ran twice (rare edge case)

**Solution:**

1. Delete duplicate views manually
2. Keep the version you prefer
3. System prevents future duplicates

---

## 🔐 Privacy & Security

### Data Storage

- Saved views stored in Supabase (Australian region)
- Row Level Security (RLS) policies enforced
- You can only see views:
  - Created by you
  - Shared publicly
  - Shared specifically with your email

### Sharing Permissions

- Only view owners can modify sharing settings
- Only view owners can delete views
- Shared users can view and apply filters only

### Data Retention

- Views persist indefinitely
- Deleted views removed immediately
- No recovery after deletion (permanent)

---

## 📞 Support

**Issues or Questions?**

Contact: Jimmy Leimonitis
Email: jimmy.leimonitis@alterahealth.com

**Common Support Requests:**

- Migration issues
- Sharing permission problems
- View recovery (not possible after deletion)
- Feature requests

---

## 🚀 Future Enhancements

Planned features:

- Export views to CSV
- Schedule automatic filter application
- View templates for common scenarios
- Analytics on most-used views

---

**Last Updated:** December 2025
**Version:** 2.0 (Supabase Migration)
