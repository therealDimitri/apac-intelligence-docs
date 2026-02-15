# 🚨 CRITICAL: Verify Vercel Environment Variables

**The SSO error is caused by incorrect environment variables in Vercel!**

## ⚠️ IMMEDIATE ACTION REQUIRED

### Step 1: Check Current NEXTAUTH_URL Setting

1. **Go to Vercel Dashboard:** https://vercel.com/dashboard
2. **Click:** apac-intelligence-v2 project
3. **Navigate to:** Settings → Environment Variables
4. **Find:** NEXTAUTH_URL

### ❌ WRONG Values (will cause error):

```
http://localhost:3001
https://apac-cs-dashboards.com
https://apac-intelligence-v2.vercel.app
```

### ✅ CORRECT Value (MUST be exactly this):

```
https://cs-connect-dashboard.netlify.app
```

## Step 2: Update NEXTAUTH_URL

1. **Click the edit icon** next to NEXTAUTH_URL
2. **Replace the value with:**
   ```
   https://cs-connect-dashboard.netlify.app
   ```
3. **Important:** Do NOT include trailing slash
4. **Click:** Save

## Step 3: CRITICAL - Redeploy Application

**Environment variables only take effect after redeployment!**

1. **Go to:** Deployments tab
2. **Find:** Your most recent deployment
3. **Click:** ⋮ (three dots menu)
4. **Select:** "Redeploy"
5. **In the dialog:** Click "Redeploy" again
6. **Wait:** ~2-3 minutes for completion

## Step 4: Verify All Environment Variables

Ensure these are ALL set correctly:

| Variable               | Correct Value                                  |
| ---------------------- | ---------------------------------------------- |
| NEXTAUTH_URL           | `https://cs-connect-dashboard.netlify.app`     |
| NEXTAUTH_SECRET        | `HmvIfUvhdch4AJ5vB63upBdQUMGQKGjeJSoXnpY9pGM=` |
| AZURE_AD_CLIENT_ID     | `e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3`         |
| AZURE_AD_CLIENT_SECRET | `132c54bb-7d1f-4e09-a25d-f4089f41bf51`         |
| AZURE_AD_TENANT_ID     | `d4066c36-17ca-4e33-95d2-0db68e44900f`         |

## 🔴 Why This Is Happening

NextAuth.js automatically constructs the redirect_uri based on NEXTAUTH_URL:

- If NEXTAUTH_URL = `https://cs-connect-dashboard.netlify.app`
- Then redirect_uri = `https://cs-connect-dashboard.netlify.app/api/auth/callback/azure-ad`

**If NEXTAUTH_URL is wrong, the redirect_uri will be wrong, causing AADSTS900971!**

## ✅ Verification After Redeploy

1. Wait for green checkmark ✅ in Vercel deployments
2. Clear browser cache completely
3. Visit: https://cs-connect-dashboard.netlify.app
4. Click "Sign In"
5. Should work without AADSTS900971 error

## 🆘 If Still Failing

If the error persists after updating NEXTAUTH_URL and redeploying:

1. **Double-check Azure AD has these redirect URIs:**
   - `https://cs-connect-dashboard.netlify.app/api/auth/callback/azure-ad`
   - `https://cs-connect-dashboard.netlify.app/api/auth/callback/microsoft`

2. **Try adding this as well:**
   - `https://cs-connect-dashboard.netlify.app/api/auth/signin/azure-ad`

---

**This is the #1 cause of the AADSTS900971 error - incorrect NEXTAUTH_URL!**
