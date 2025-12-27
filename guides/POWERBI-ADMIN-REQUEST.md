# Power BI Admin Access Request

**To:** Power BI Administrator
**From:** Dimitri Leimonitis
**Date:** 27 December 2025
**Subject:** Request to Enable Service Principal Access for APAC Intelligence Dashboard

---

## Summary

I'm requesting access for our Azure AD application to connect to Power BI via the REST API. This will allow the APAC Client Success Intelligence Dashboard to programmatically retrieve data from Power BI reports and display it alongside our other client metrics.

## Business Purpose

The APAC Intelligence Dashboard consolidates client health data from multiple sources (NPS surveys, meeting analytics, compliance tracking, etc.). Adding Power BI data integration will:

- Provide a unified view of client metrics in one dashboard
- Enable automated data synchronisation without manual exports
- Allow real-time insights from Power BI datasets

## Target Report

We need to access the underlying dataset for this Power BI report:

**Report URL:**
https://app.powerbi.com/groups/me/reports/bc5d6fec-3b73-4288-993b-4b460a172b0e/8529fce93569e1f6ec83

**Report ID:** `bc5d6fec-3b73-4288-993b-4b460a172b0e`

> **Note:** This report is currently in "My Workspace". For service principal access, the report/dataset will need to be in a shared workspace.

---

## Technical Requirements

### 1. Azure AD Application Details

| Property | Value |
|----------|-------|
| **App Name** | CS Connect Dashboard - Auth |
| **Application (Client) ID** | `e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3` |
| **Tenant ID** | `d4066c36-17ca-4e33-95d2-0db68e44900f` |
| **Purpose** | Service principal for API access (no user login required) |

This application is already registered in Azure AD and has admin consent for Microsoft Graph APIs (calendar, email).

### 2. Power BI Admin Portal Settings Required

Please enable the following in the [Power BI Admin Portal](https://app.powerbi.com/admin-portal/tenantSettings):

#### A. Allow Service Principals to Use Power BI APIs

**Location:** Tenant settings → Developer settings → "Allow service principals to use Power BI APIs"

**Options:**
- Enable for the entire organisation, OR
- Enable for a specific security group and add the app to that group

#### B. Enable Dataset Execute Queries REST API

**Location:** Tenant settings → Integration settings → "Dataset Execute Queries REST API"

**Options:**
- Enable for the entire organisation, OR
- Enable for the same security group as above

### 3. Move Report to Shared Workspace (If in My Workspace)

The target report is currently in "My Workspace" (personal workspace). Service principals cannot access personal workspaces directly.

**Option A: Move to existing shared workspace**
1. In Power BI Service, open the report
2. File → Save a copy → Select a shared workspace
3. Note the workspace ID for step 4

**Option B: Create a new shared workspace**
1. In Power BI Service, click "Workspaces" → "Create a workspace"
2. Name it (e.g., "APAC CS Integration")
3. Move or copy the report/dataset to this workspace

### 4. Add Service Principal to Workspace

Once the report is in a shared workspace:

1. Go to the workspace → Click "Access" (top right)
2. Add the application: Search for `CS Connect Dashboard - Auth` or use Client ID `e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3`
3. Grant **Member** or **Admin** role

---

## What We Will Access

- **Read-only access** to dataset tables via DAX queries
- We will NOT modify any data or reports
- We will NOT access any datasets outside the designated workspace
- All queries are logged for audit purposes

## Security Considerations

- The service principal uses client credentials (no user impersonation)
- Access is limited to workspaces where the app is explicitly added
- Row-Level Security (RLS) can still be applied at the dataset level if needed
- API calls are rate-limited by Power BI

---

## Verification Steps

Once configured, I can verify access by running our test script. If successful, I'll see:

```
✅ Power BI API connection: SUCCESS
   Workspaces accessible: 1+
   Datasets accessible: 1+
```

---

## Questions?

Please let me know if you need any additional information or have concerns about this request.

**Contact:**
Dimitri Leimonitis
dimitri.leimonitis@alterahealth.com

---

## Reference Documentation

- [Microsoft: Embed with Service Principal](https://learn.microsoft.com/en-us/power-bi/developer/embedded/embed-service-principal)
- [Microsoft: Execute Queries API](https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/execute-queries)
- [Power BI Admin Portal Settings](https://learn.microsoft.com/en-us/power-bi/admin/service-admin-portal)
