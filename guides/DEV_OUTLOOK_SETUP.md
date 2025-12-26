# Development Outlook Sync Setup

This guide explains how to use Outlook sync features while using dev-signin for local development.

## The Problem

Dev-signin bypasses Microsoft OAuth, so it doesn't have a Microsoft access token needed to call the Microsoft Graph API for Outlook calendar access.

## The Solution

Use a real Microsoft access token in development by adding it to your `.env.local` file.

## Setup Steps

### Option 1: Get Token from Microsoft SSO (Recommended)

1. **Sign in with Microsoft SSO** (not dev-signin):
   - Go to http://localhost:3002
   - Click "Sign in with Microsoft"
   - Complete the Azure AD authentication

2. **Extract the access token**:
   - Open browser DevTools (F12)
   - Go to Console tab
   - Run this command:

   ```javascript
   ;(await fetch('/api/auth/session').then(r => r.json())).accessToken
   ```

   - Copy the token (it's a long string starting with "eyJ...")

3. **Add to `.env.local`**:

   ```bash
   # Add this line to your .env.local file:
   DEV_MICROSOFT_ACCESS_TOKEN=<paste your token here>
   ```

4. **Restart dev server**:

   ```bash
   npm run dev
   ```

5. **Now use dev-signin**:
   - Sign out from Microsoft
   - Use dev-signin at http://localhost:3002/auth/dev-signin
   - Outlook sync will now work using the token from .env.local

### Option 2: Use Graph Explorer

1. Go to https://developer.microsoft.com/en-us/graph/graph-explorer
2. Sign in with your Altera Microsoft account
3. Grant the required permissions (Calendars.Read, Calendars.ReadWrite)
4. Copy the access token from the "Access token" tab
5. Add to `.env.local` as shown above

## Token Expiry

**Important**: Microsoft access tokens expire after ~1 hour.

When the token expires, you'll see authentication errors. Simply:

1. Get a fresh token using Option 1 or 2 above
2. Update `.env.local`
3. Restart the dev server

## Security Notes

- ⚠️ **Never commit `.env.local` to git** - it contains your personal access token
- ✅ `.env.local` is already in `.gitignore`
- 🔒 The `DEV_MICROSOFT_ACCESS_TOKEN` variable only works in development mode
- 🎯 This is for local testing only - production uses proper OAuth flow

## Verifying It Works

1. Use dev-signin to log in
2. Go to Meetings page
3. Click "Sync Outlook" button
4. You should see your real Outlook calendar events!

If you see an error about missing access token, check:

- Is `DEV_MICROSOFT_ACCESS_TOKEN` set in `.env.local`?
- Did you restart the dev server after adding it?
- Has the token expired? (Get a fresh one)

## Alternative: Just Use Microsoft SSO

If this is too cumbersome, you can always just sign in with Microsoft SSO instead of dev-signin. The token management is automatic with OAuth!
