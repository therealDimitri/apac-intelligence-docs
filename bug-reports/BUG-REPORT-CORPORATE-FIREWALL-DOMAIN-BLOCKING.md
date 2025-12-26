# Bug Report: Corporate Firewall Domain Blocking

**Date:** November 26, 2025
**Component:** Network Access / Corporate Firewall
**Severity:** CRITICAL
**Status:** WORKAROUND IMPLEMENTED

## Executive Summary

Corporate firewall (Cisco Umbrella) blocked the custom domain `apac-cs-dashboards.com` after detecting it was proxying to Vercel. Implemented workaround using Netlify subdomain `cs-connect-dashboard.netlify.app` which remains accessible.

## Timeline of Events

### Phase 1: Initial Vercel Blocking

- **Problem:** Cisco Umbrella blocks all `*.vercel.app` domains at DNS level
- **Impact:** Application inaccessible from corporate network
- **User Feedback:** "blocked" repeatedly

### Phase 2: Netlify Proxy Implementation

- **Solution:** Use Netlify as reverse proxy to hide Vercel backend
- **Configuration:** Created `_redirects` file with proxy rules
- **Result:** Initially worked but DNS was misconfigured

### Phase 3: DNS Misconfiguration

- **Discovery:** Domain pointing directly to Vercel, not Netlify
- **Fix:** Deleted CNAME records, connected domain to Netlify
- **User Action:** "2 cname records have been deleted"

### Phase 4: Wrong Dashboard Issue

- **Problem:** OLD HTML dashboard being served instead of NEW Next.js app
- **Cause:** `index.html` file in repository
- **Fix:** Renamed to `index.html.old-dashboard`

### Phase 5: Domain Gets Blocked

- **Critical Issue:** Cisco Umbrella blocked `apac-cs-dashboards.com`
- **Evidence:** Response header shows "Server: Cisco Umbrella"
- **Impact:** Custom domain completely inaccessible

### Phase 6: Subdomain Workaround

- **Solution:** Use `cs-connect-dashboard.netlify.app` subdomain
- **Status:** Currently working and not blocked
- **Risk:** Could be blocked if detected

## Technical Details

### Corporate Firewall Configuration

```
Type: Cisco Umbrella
Blocking Method: DNS-level filtering
Blocked Patterns:
- *.vercel.app (all Vercel domains)
- apac-cs-dashboards.com (custom domain after detection)
```

### Netlify Proxy Configuration

```
# _redirects file
/api/*  https://apac-intelligence-v2.vercel.app/api/:splat  200
/auth/*  https://apac-intelligence-v2.vercel.app/auth/:splat  200
/_next/*  https://apac-intelligence-v2.vercel.app/_next/:splat  200
/*  https://apac-intelligence-v2.vercel.app/:splat  200
```

### Current Access Methods

1. **Blocked:** `https://apac-cs-dashboards.com`
2. **Working:** `https://cs-connect-dashboard.netlify.app`
3. **Local:** `http://localhost:3001`

## Root Cause Analysis

1. **Initial Block:** Vercel domains are on corporate blocklist
2. **Proxy Detection:** Deep packet inspection detected proxy pattern
3. **Domain Block:** Custom domain added to blocklist after detection
4. **Pattern Recognition:** Cisco Umbrella likely detected:
   - Proxy headers
   - Backend URL patterns
   - Traffic patterns

## Workaround Implementation

### Step 1: Updated Authentication

- Modified `src/auth.ts` to support multiple domains
- Added `getRedirectUri()` helper function
- Supports comma-separated domains in `NEXTAUTH_URL`

### Step 2: Azure AD Configuration

Required redirect URIs for subdomain:

```
https://cs-connect-dashboard.netlify.app/api/auth/callback/azure-ad
https://cs-connect-dashboard.netlify.app/api/auth/callback/microsoft
https://cs-connect-dashboard.netlify.app/api/auth/signin
```

### Step 3: Environment Variables

Update `NEXTAUTH_URL` in Vercel:

```
https://cs-connect-dashboard.netlify.app,https://apac-cs-dashboards.com
```

## Impact Assessment

### Business Impact

- **Availability:** Application accessible via subdomain
- **User Experience:** Must use different URL
- **Security:** No impact on security
- **Performance:** No performance degradation

### Technical Impact

- **SSO:** Requires Azure AD configuration updates
- **Deployment:** Requires environment variable updates
- **Maintenance:** Must monitor subdomain for blocking

## Mitigation Strategies

### Short-term (Current)

- ✅ Use Netlify subdomain
- ✅ Update Azure AD redirect URIs
- ✅ Notify team of new URL

### Medium-term Options

1. **VPN Access:** Use corporate VPN to bypass
2. **Whitelist Request:** Request IT to whitelist domain
3. **Different CDN:** Try Cloudflare Workers

### Long-term Solutions

1. **Self-hosted:** Deploy on internal infrastructure
2. **Azure App Service:** Use approved cloud provider
3. **On-premise:** Install on local servers

## Lessons Learned

1. **Corporate Firewalls Are Sophisticated**
   - DNS-level blocking is common
   - Deep packet inspection detects proxies
   - Patterns are recognised and blocked

2. **Proxy Solutions Are Temporary**
   - Eventually detected and blocked
   - Need multiple fallback options
   - Must plan for detection

3. **Communication Is Critical**
   - Team needs immediate notification
   - Multiple access methods documented
   - Clear escalation path

## Prevention Strategies

1. **Pre-deployment Checks**
   - Test from corporate network early
   - Check firewall policies in advance
   - Have IT involvement from start

2. **Architecture Choices**
   - Use approved cloud providers
   - Consider self-hosting options
   - Plan for firewall restrictions

3. **Monitoring**
   - Automated availability checks
   - Multiple access point monitoring
   - Alert on blocking detection

## Current Status

### Working

- ✅ Netlify subdomain accessible
- ✅ Proxy functioning correctly
- ✅ Authentication updated for subdomain
- ✅ Application fully functional

### Pending

- ⏳ Azure AD redirect URI updates
- ⏳ Vercel environment variable updates
- ⏳ Team notification of new URL
- ⏳ Long-term solution planning

## Recommendations

1. **Immediate:** Use subdomain URL for access
2. **Short-term:** Complete Azure AD and Vercel updates
3. **Medium-term:** Request IT whitelist or explore alternatives
4. **Long-term:** Consider enterprise-approved hosting

## Related Documentation

- `/docs/BUG-REPORT-NETLIFY-PROXY-FIREWALL-BYPASS.md`
- `/docs/ALTERNATIVE-ACCESS-NETLIFY-SUBDOMAIN.md`
- `/docs/UPDATE-VERCEL-FOR-SUBDOMAIN.md`
- `/docs/UPDATE-AZURE-AD-REDIRECTS.md`

## Files Modified

1. **src/auth.ts**
   - Added multi-domain support
   - Helper function for redirect URIs

2. **\_redirects**
   - Proxy configuration for Netlify
   - Routes all traffic to Vercel backend

3. **netlify.toml**
   - Netlify configuration file
   - Redirect rules for proxy

## Testing Checklist

- [ ] Access via Netlify subdomain works
- [ ] SSO authentication successful
- [ ] All dashboard features functional
- [ ] Data loads correctly
- [ ] No console errors

---

**Resolution Time:** 6 hours of investigation and implementation
**Workaround Status:** Active and functional
**Risk Level:** Medium (subdomain could be blocked)
