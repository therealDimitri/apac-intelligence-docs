# Update Production URL to Custom Domain

**Date:** 2025-11-26
**Change:** Update production URL from Netlify subdomain to custom domain
**From:** `https://cs-connect-dashboard.netlify.app`
**To:** `https://apac-cs-dashboards.com`

---

## ✅ Current Status

**Custom Domain Working:**

```bash
$ curl -sI https://apac-cs-dashboards.com | grep server
server: Netlify ✅

$ dig apac-cs-dashboards.com +short
54.253.94.210 ✅ (Netlify IP)
```

**Verification:** Both custom domain and subdomain work and point to Netlify

---

## 🔧 Required Updates

### 1. **Update Netlify Environment Variable** (CRITICAL)

**Action:** Update NEXTAUTH_URL in Netlify dashboard

**Steps:**

1. Go to: https://app.netlify.com
2. Select site: `cs-connect-dashboard` or `apac-cs-dashboards`
3. Click **Site settings** → **Environment variables**
4. Find: `NEXTAUTH_URL`
5. Update value from:
   ```
   OLD: https://cs-connect-dashboard.netlify.app
   NEW: https://apac-cs-dashboards.com
   ```
6. Click **Save**
7. Trigger redeploy: **Deploys** → **Trigger deploy** → **Deploy site**

**Why:** NextAuth needs to know the primary domain for redirect URIs

---

### 2. **Update Azure AD Redirect URIs** (CRITICAL)

**Action:** Update redirect URIs in Azure Portal to use custom domain

**Steps:**

1. Go to: https://portal.azure.com
2. Navigate to: **Azure Active Directory** → **App registrations**
3. Select: **APAC Intelligence Hub** (App ID: e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3)
4. Click: **Authentication** (left sidebar)
5. Under **Platform configurations** → **Web**

**Add these URIs** (if not present):

```
https://apac-cs-dashboards.com/api/auth/callback/azure-ad
https://apac-cs-dashboards.com/api/auth/callback/microsoft
https://apac-cs-dashboards.com/api/auth/signin
```

**Keep these URIs** (as fallbacks):

```
https://cs-connect-dashboard.netlify.app/api/auth/callback/azure-ad
https://cs-connect-dashboard.netlify.app/api/auth/callback/microsoft
https://cs-connect-dashboard.netlify.app/api/auth/signin
http://localhost:3001/api/auth/callback/azure-ad
```

6. Click **Save**
7. Wait 2-5 minutes for changes to propagate

**Why:** Azure AD validates redirect URIs must exactly match

---

### 3. **Update Netlify Custom Domain Settings** (Optional)

**Action:** Verify custom domain is set as primary

**Steps:**

1. Go to Netlify dashboard
2. Click **Domain settings**
3. Under **Custom domains**
4. Verify `apac-cs-dashboards.com` is listed
5. Click **Options** → **Set as primary domain**

**Result:** Netlify will automatically redirect subdomain → custom domain

---

## 📝 **Configuration Summary**

### Environment Variables (Netlify)

```bash
# Primary production URL
NEXTAUTH_URL=https://apac-cs-dashboards.com

# Azure AD
AZURE_AD_CLIENT_ID=e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3
AZURE_AD_CLIENT_SECRET=[configured in Netlify]
AZURE_AD_TENANT_ID=d4066c36-17ca-4e33-95d2-0db68e44900f
NEXTAUTH_SECRET=HmvIfUvhdch4AJ5vB63upBdQUMGQKGjeJSoXnpY9pGM=

# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://usoyxsunetvxdjdglkmn.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=[configured in Netlify]
SUPABASE_SERVICE_ROLE_KEY=[configured in Netlify]

# App Config
NEXT_PUBLIC_APP_NAME=APAC Client Success Intelligence Hub
NEXT_PUBLIC_ENABLE_AI=true
NEXT_PUBLIC_ENABLE_ANALYTICS=true
NODE_ENV=production
```

### Azure AD Redirect URIs (Complete List)

```
# Production - Custom Domain (PRIMARY)
https://apac-cs-dashboards.com/api/auth/callback/azure-ad
https://apac-cs-dashboards.com/api/auth/callback/microsoft
https://apac-cs-dashboards.com/api/auth/signin

# Fallback - Netlify Subdomain
https://cs-connect-dashboard.netlify.app/api/auth/callback/azure-ad
https://cs-connect-dashboard.netlify.app/api/auth/callback/microsoft
https://cs-connect-dashboard.netlify.app/api/auth/signin

# Development
http://localhost:3001/api/auth/callback/azure-ad
```

---

## 🧪 **Testing Procedure**

### Step 1: Update Environment Variable

```bash
# After updating NEXTAUTH_URL in Netlify
# Trigger redeploy and wait ~3 minutes
```

### Step 2: Test Custom Domain Access

```bash
# Test domain responds
curl -sI https://apac-cs-dashboards.com

# Expected:
# HTTP/2 200 or 307
# server: Netlify
```

### Step 3: Test Authentication

1. Clear browser cache/cookies
2. Navigate to: https://apac-cs-dashboards.com
3. Click "Sign In with Microsoft"
4. Complete Azure AD authentication
5. Verify redirect back to custom domain
6. Confirm dashboard loads

**Expected:**

- ✅ Redirect to Azure AD works
- ✅ No AADSTS errors
- ✅ Redirect back to `https://apac-cs-dashboards.com/`
- ✅ User session established
- ✅ Dashboard loads with data

### Step 4: Check Redirect URI in Browser

1. Open browser DevTools (F12)
2. Go to **Network** tab
3. Click "Sign In"
4. Find request to `login.microsoftonline.com`
5. Check `redirect_uri` parameter

**Expected:**

```
redirect_uri=https://apac-cs-dashboards.com/api/auth/callback/azure-ad
```

**NOT:**

```
redirect_uri=https://cs-connect-dashboard.netlify.app/... ❌
```

---

## ⚠️ **Potential Issues & Solutions**

### Issue: AADSTS50011 after updating

**Cause:** Azure AD redirect URI not saved or not propagated

**Solution:**

1. Verify URIs saved in Azure Portal
2. Wait 5-10 minutes for propagation
3. Clear browser cookies
4. Try again

### Issue: Infinite redirect loop

**Cause:** NEXTAUTH_URL doesn't match domain being accessed

**Solution:**

1. Verify NEXTAUTH_URL = `https://apac-cs-dashboards.com`
2. Redeploy Netlify site
3. Clear browser cache
4. Access via custom domain only

### Issue: Subdomain still works, custom domain doesn't

**Cause:** DNS or Netlify domain settings

**Solution:**

1. Verify DNS points to Netlify (dig apac-cs-dashboards.com)
2. Check Netlify domain settings
3. Set custom domain as primary
4. Wait for DNS propagation (can take 24 hours)

---

## 📊 **Before vs After**

| Configuration     | Before                           | After                  |
| ----------------- | -------------------------------- | ---------------------- |
| **Primary URL**   | cs-connect-dashboard.netlify.app | apac-cs-dashboards.com |
| **NEXTAUTH_URL**  | Netlify subdomain                | Custom domain          |
| **Azure AD URIs** | Subdomain only                   | Custom + subdomain     |
| **User Access**   | Subdomain                        | Custom domain          |
| **Branding**      | Generic Netlify                  | Professional domain    |

---

## ✅ **Verification Checklist**

- [ ] NEXTAUTH_URL updated in Netlify to `https://apac-cs-dashboards.com`
- [ ] Netlify site redeployed
- [ ] Azure AD redirect URIs added for custom domain
- [ ] Azure AD redirect URIs kept for subdomain (fallback)
- [ ] Custom domain set as primary in Netlify
- [ ] Browser test: Sign in via custom domain works
- [ ] Browser test: No AADSTS errors
- [ ] Browser test: Dashboard loads after auth
- [ ] Documentation updated with production URL

---

## 📚 **Files to Update** (After environment changes)

### Update these docs with custom domain:

1. `README.md` - Update production URL
2. `docs/NETLIFY-VERIFICATION-CHECKLIST.md` - Update URLs
3. `docs/DEPLOYMENT-PLATFORM-ANALYSIS.md` - Update production reference
4. Any user-facing documentation

### No code changes needed:

- `src/auth.ts` - Uses `process.env.NEXTAUTH_URL` ✅
- `netlify.toml` - Domain agnostic ✅
- All API routes - Use environment variable ✅

---

## 🎯 **Final Production Configuration**

**Production URL:** https://apac-cs-dashboards.com
**Platform:** Netlify
**Authentication:** NextAuth.js with Azure AD
**Database:** Supabase
**Deployment:** Git push → Netlify auto-deploy

**Access URLs:**

- **Primary:** https://apac-cs-dashboards.com (custom domain)
- **Fallback:** https://cs-connect-dashboard.netlify.app (Netlify subdomain)
- **Development:** http://localhost:3001

---

## 🚀 **Next Steps**

1. **Update Netlify Environment Variable** (10 minutes)
   - NEXTAUTH_URL = `https://apac-cs-dashboards.com`
   - Trigger redeploy

2. **Update Azure AD Redirect URIs** (15 minutes)
   - Add custom domain URIs
   - Keep subdomain URIs as fallback
   - Wait for propagation

3. **Test Authentication** (5 minutes)
   - Access custom domain
   - Sign in with Microsoft
   - Verify redirect works

4. **Update Documentation** (10 minutes)
   - Update all docs with production URL
   - Communicate change to team

**Total Time:** ~40 minutes

---

**Status:** Ready for implementation
**Priority:** High (production URL configuration)
**Impact:** User-facing URL change to professional domain
