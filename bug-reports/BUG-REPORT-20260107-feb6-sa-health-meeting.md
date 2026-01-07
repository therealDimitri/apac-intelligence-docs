# Bug Report: Feb 6 SA Health Meeting Missing from Outlook Sync

**Date**: 7 January 2026
**Status**: Requires More Information
**Severity**: Medium
**Component**: Outlook Calendar Sync

## Issue

A meeting scheduled for Feb 6 with SA Health is reportedly missing from the Outlook sync/import.

## Investigation

### Current SA Health Meetings Found
As of 7 January 2026, there are 20+ SA Health meetings in the database, with the most recent being:
- Jan 28, 2026: SA Health Contract Review
- Jan 15, 2026: Sunrise CarePath - SALHN
- Jan 12, 2026: Altera : DHSA
- Jan 7, 2026: Various SA Health meetings

### No Feb 6 Meeting Found
No meeting dated 2026-02-06 was found for any SA Health variant (iPro, iQemo, Sunrise).

## Possible Causes

1. **Meeting Not Yet in Outlook Calendar**
   - Feb 6 is approximately 1 month in the future
   - The meeting may not have been scheduled yet in Outlook

2. **Outlook Sync Window**
   - The Outlook import modal fetches events from the past 90 days
   - Future events should be included, but there may be a limit

3. **Meeting Skipped**
   - The user may have previously skipped this meeting in the import modal
   - Check the "Show Skipped" toggle in the Outlook import

4. **Calendar Permissions**
   - The Microsoft Graph API token may have expired
   - User may need to re-authenticate

## Recommended Actions

1. **Open Outlook Import Modal**
   - Navigate to Briefing Room
   - Click "Sync from Outlook"
   - Use the new search bar to search for "SA Health Feb"
   - Check if the meeting appears

2. **Check Skipped Meetings**
   - Click "Show Skipped" toggle
   - Look for the Feb 6 meeting in the skipped list
   - Unskip if needed

3. **Verify in Outlook**
   - Confirm the meeting exists in Outlook calendar
   - Note the exact subject line for searching

4. **Re-authenticate if Needed**
   - If no meetings load, sign out and sign back in
   - Grant calendar permissions again

## Resolution

Awaiting more details:
- What is the exact subject line of the missing meeting?
- Which SA Health variant? (iPro, iQemo, Sunrise)
- Is the meeting visible in the Outlook desktop/web app?
- Has this meeting been synced before?
