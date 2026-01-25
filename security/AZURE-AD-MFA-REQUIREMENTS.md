# Azure AD MFA Requirements for APAC Intelligence Hub

**Document Date**: 2026-01-25
**Status**: Action Required
**Priority**: Critical
**Target Audience**: IT Administrator / Azure AD Administrator

---

## Executive Summary

The APAC Client Success Intelligence Hub uses Azure AD Single Sign-On (SSO) for authentication. To ensure enterprise-grade security, Multi-Factor Authentication (MFA) must be enforced via Azure AD Conditional Access policies.

**Current State**: MFA may not be consistently enforced for all users accessing this application.

**Required Action**: Azure AD Administrator must verify and configure Conditional Access policies as outlined below.

---

## Application Details

| Setting | Value |
|---------|-------|
| **Application Name** | APAC Client Success Intelligence Hub |
| **Client ID** | `e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3` |
| **Tenant ID** | `d4066c36-17ca-4e33-95d2-0db68e44900f` |
| **Redirect URI** | `https://apac-cs-dashboards.com/api/auth/callback/azure-ad` |
| **Authentication Method** | OAuth 2.0 with PKCE |

---

## Required Conditional Access Policies

### Policy 1: Require MFA for All Users (Critical)

**Purpose**: Ensure all users authenticate with a second factor when accessing the application.

| Setting | Configuration |
|---------|---------------|
| **Name** | `APAC-Intelligence-Require-MFA-All-Users` |
| **Users** | All users (or security group containing all APAC users) |
| **Cloud Apps** | APAC Client Success Intelligence Hub (Client ID above) |
| **Conditions** | All locations, all device platforms |
| **Grant** | Require multifactor authentication |
| **Session** | Sign-in frequency: 12 hours (recommended) |

### Policy 2: Require MFA for Administrators (Critical)

**Purpose**: Apply stricter controls for privileged accounts.

| Setting | Configuration |
|---------|---------------|
| **Name** | `APAC-Intelligence-Require-MFA-Admins` |
| **Users** | Global Administrators, Privileged Role Administrators |
| **Cloud Apps** | APAC Client Success Intelligence Hub |
| **Grant** | Require multifactor authentication + Require phishing-resistant MFA |
| **Session** | Sign-in frequency: 4 hours |

### Policy 3: Block Legacy Authentication (Critical)

**Purpose**: Prevent authentication via protocols that cannot enforce MFA.

| Setting | Configuration |
|---------|---------------|
| **Name** | `Block-Legacy-Authentication-All-Apps` |
| **Users** | All users |
| **Cloud Apps** | All cloud apps |
| **Conditions** | Client apps: Exchange ActiveSync, Other clients |
| **Grant** | Block access |

### Policy 4: Risk-Based Step-Up Authentication (High Priority)

**Purpose**: Require additional verification for suspicious sign-in attempts.

| Setting | Configuration |
|---------|---------------|
| **Name** | `Require-MFA-High-Risk-Signins` |
| **Users** | All users |
| **Cloud Apps** | All cloud apps |
| **Conditions** | Sign-in risk: Medium and High |
| **Grant** | Require multifactor authentication |

> **Note**: This policy requires Microsoft Entra ID P2 licensing.

---

## Recommended MFA Methods

Configure these authentication methods in order of preference:

| Priority | Method | Security Level | Notes |
|----------|--------|----------------|-------|
| 1 | **FIDO2 Security Keys** | Highest | Hardware-backed, phishing-resistant |
| 2 | **Passkeys** | Highest | Device-bound, phishing-resistant |
| 3 | **Windows Hello for Business** | High | Biometric + TPM |
| 4 | **Microsoft Authenticator (Number Matching)** | Good | Push notifications with number matching |
| 5 | **Authenticator App (TOTP)** | Acceptable | Time-based one-time passwords |
| 6 | **SMS/Phone Call** | Low | **Avoid** - Vulnerable to SIM-swapping |

### Configuration Path

**Microsoft Entra Admin Centre** → **Protection** → **Authentication Methods** → **Policies**

---

## Verification Steps

### Step 1: Check Existing Policies

1. Navigate to: **Microsoft Entra ID** → **Security** → **Conditional Access** → **Policies**
2. Search for policies targeting:
   - All users
   - The APAC Intelligence Hub application specifically
3. Verify "Require multifactor authentication" is in the Grant controls

### Step 2: Verify Application Coverage

1. Navigate to: **Enterprise Applications**
2. Search for: `APAC Client Success Intelligence Hub` or Client ID `e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3`
3. Select the application → **Conditional Access** tab
4. Confirm MFA policies are listed and enabled

### Step 3: Test with New User Session

1. Open an incognito/private browser window
2. Navigate to: `https://apac-cs-dashboards.com`
3. Click "Sign in with Altera SSO"
4. **Expected**: User should be prompted for password AND MFA
5. If MFA is not prompted, policies are not correctly applied

### Step 4: Review Sign-In Logs

1. Navigate to: **Microsoft Entra ID** → **Sign-in logs**
2. Filter by Application: APAC Client Success Intelligence Hub
3. Check the "Conditional Access" column
4. Verify policies are being applied (not bypassed)

---

## Common Issues and Solutions

### Issue: MFA Not Prompting

| Possible Cause | Solution |
|----------------|----------|
| No CA policy targets the app | Create policy specifically including the app |
| App excluded from policy | Remove exclusion or create app-specific policy |
| User in excluded group | Review group memberships |
| Trusted location configured | Review Named Locations settings |
| Session frequency too long | Reduce sign-in frequency to 12 hours or less |

### Issue: Policies Not Applying

| Possible Cause | Solution |
|----------------|----------|
| Policy in Report-only mode | Change to On (after testing) |
| Conflicting policies | Review policy precedence |
| Legacy authentication used | Ensure Block Legacy Auth policy is active |

---

## Security Compliance Notes

### Microsoft Mandatory MFA Enforcement (2025-2026)

As of **October 2025**, Microsoft has mandated MFA for:
- All Azure service users
- CLI and PowerShell access
- REST API endpoints (Create/Update/Delete operations)

This enforcement has blocked **more than 99%** of account compromise attempts according to Microsoft telemetry.

### Regulatory Considerations

Enforcing MFA helps meet compliance requirements for:
- ISO 27001 (Access Control)
- SOC 2 (Logical Access Controls)
- HIPAA (Access Management)
- Australian Privacy Principles (Security Safeguards)

---

## Emergency Access (Break-Glass Accounts)

Ensure emergency access accounts are configured with:
- Phishing-resistant MFA (FIDO2 or Certificate-based)
- Excluded from sign-in frequency policies (but NOT from MFA requirement)
- Documented and tested recovery procedures
- Activity monitoring and alerts

Create a contingency policy named: `ENABLE IN EMERGENCY - Bypass MFA`
- Keep this policy **disabled** by default
- Only enable during Azure AD outages
- Document the enable/disable procedure

---

## References

- [Azure Identity & Access Security Best Practices - Microsoft Learn](https://learn.microsoft.com/en-us/azure/security/fundamentals/identity-management-best-practices)
- [Plan Your Microsoft Entra Conditional Access Deployment](https://learn.microsoft.com/en-us/entra/identity/conditional-access/plan-conditional-access)
- [Require MFA for Azure Management](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-old-require-mfa-azure-mgmt)
- [Deployment Considerations for Microsoft Entra MFA](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-mfa-getstarted)

---

## Action Checklist

- [ ] Verify Conditional Access policies exist for the APAC Intelligence Hub
- [ ] Confirm MFA is required for all users (not just admins)
- [ ] Block legacy authentication protocols
- [ ] Configure phishing-resistant MFA methods
- [ ] Test with incognito browser session
- [ ] Review sign-in logs for policy application
- [ ] Document emergency access procedures
- [ ] Set up monitoring and alerts for failed sign-ins

---

**Document Owner**: IT Security / Azure AD Administrator
**Review Frequency**: Quarterly
**Next Review Date**: April 2026
