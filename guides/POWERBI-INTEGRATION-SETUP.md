# Power BI Integration Setup Guide

**Date**: 2025-12-27
**Status**: POC Created - Pending Admin Configuration

## Overview

This guide covers the setup required to integrate Power BI data into the APAC Intelligence Dashboard using the Power BI REST API with service principal authentication.

## POC Components Created

| File | Purpose |
|------|---------|
| `src/lib/powerbi-client.ts` | Power BI API client library with DAX query support |
| `src/app/api/powerbi/discover/route.ts` | API endpoint to list workspaces, datasets, reports |
| `src/app/api/powerbi/query/route.ts` | API endpoint to execute DAX queries |
| `scripts/test-powerbi-connection.mjs` | Test script to validate connectivity |

## Current Status

✅ **Working:**
- Azure AD authentication (token acquisition successful)
- Power BI API client library created
- API routes implemented

❌ **Requires Admin Configuration:**
- Service principal not authorised for Power BI APIs (401 error)
- Need to enable "Allow service principals to use Power BI APIs" in Power BI Admin Portal

## Target Report

```
URL: https://app.powerbi.com/groups/me/apps/2db88611-7fbc-4f7c-8325-99284ac81e1d/reports/765b8f21-1d50-4cd0-87a8-6856cc43a0d6/ReportSection299ab8ae52dd3bb51890

Parsed Components:
- App ID: 2db88611-7fbc-4f7c-8325-99284ac81e1d
- Report ID: 765b8f21-1d50-4cd0-87a8-6856cc43a0d6
- Section ID: 299ab8ae52dd3bb51890
```

> **Note:** This is a Power BI App, which is a published version of a workspace. The underlying data is in the source workspace.

---

## Setup Steps (Admin Required)

### Step 1: Enable Service Principal Access in Power BI Admin Portal

1. Go to [Power BI Admin Portal](https://app.powerbi.com/admin-portal/tenantSettings)
2. Navigate to **Tenant settings** → **Developer settings**
3. Enable **"Allow service principals to use Power BI APIs"**
4. Choose one of:
   - **The entire organisation** (easiest)
   - **Specific security groups** (more secure - create a group and add the service principal)

![Power BI Admin Settings](https://learn.microsoft.com/en-us/power-bi/developer/embedded/media/embed-service-principal/admin-portal.png)

### Step 2: Enable Execute Queries API (If Using DAX Queries)

1. In Power BI Admin Portal, go to **Tenant settings** → **Integration settings**
2. Enable **"Dataset Execute Queries REST API"**
3. Choose the same security group or entire organisation

### Step 3: Add Service Principal to Power BI Workspace

1. Identify the workspace that contains the dataset you want to query
   - For Apps: Find the source workspace that published the app
2. In Power BI Service, go to the workspace
3. Click **Access** (top right)
4. Add the Azure AD app as a **Member** or **Admin**:
   - App Name: `CS Connect Dashboard - Auth`
   - Client ID: `e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3`

### Step 4: Get Workspace and Dataset IDs

Once the service principal has access, run the test script:

```bash
node scripts/test-powerbi-connection.mjs
```

This will list all accessible workspaces and datasets. Note down:
- **Workspace ID** (the GUID of the workspace)
- **Dataset ID** (the GUID of the dataset you want to query)

### Step 5: Test DAX Query

Use the API endpoint to test a query:

```bash
curl -X POST http://localhost:3001/api/powerbi/query \
  -H "Content-Type: application/json" \
  -d '{
    "datasetId": "YOUR_DATASET_ID",
    "workspaceId": "YOUR_WORKSPACE_ID",
    "query": "EVALUATE ROW(\"Test\", 1)"
  }'
```

---

## API Usage

### Discover Available Resources

```
GET /api/powerbi/discover
GET /api/powerbi/discover?workspaceId=<workspace-id>
```

### Execute DAX Query

```
POST /api/powerbi/query

Body:
{
  "datasetId": "required-dataset-guid",
  "workspaceId": "optional-workspace-guid",
  "query": "EVALUATE TableName"
}
```

### Example DAX Queries

| Purpose | Query |
|---------|-------|
| Get all rows | `EVALUATE TableName` |
| Select columns | `EVALUATE SELECTCOLUMNS(Table, "Alias", [Column])` |
| Filter rows | `EVALUATE FILTER(Table, [Status] = "Active")` |
| Aggregate | `EVALUATE SUMMARIZECOLUMNS(Table[Category], "Sum", SUM(Table[Amount]))` |
| Top N | `EVALUATE TOPN(10, Table, [Date], DESC)` |

---

## Architecture Diagram

```
┌─────────────────────┐
│  Power BI Service   │
│  (Dataset + Report) │
└──────────┬──────────┘
           │ DAX Query (REST API)
           ▼
┌─────────────────────┐
│  Azure AD           │
│  Service Principal  │
│  (CS Connect Auth)  │
└──────────┬──────────┘
           │ Bearer Token
           ▼
┌─────────────────────┐     ┌─────────────────┐
│  /api/powerbi/*     │────▶│  Supabase       │
│  (Next.js API)      │     │  (Cache/Store)  │
└──────────┬──────────┘     └────────┬────────┘
           │                         │
           ▼                         ▼
┌─────────────────────────────────────────────┐
│              Dashboard UI                    │
│  (React components + hooks)                  │
└─────────────────────────────────────────────┘
```

---

## Troubleshooting

### Error: 401 Unauthorized

**Cause:** Service principal not authorised for Power BI APIs.

**Solution:**
1. Enable "Allow service principals to use Power BI APIs" in Power BI Admin Portal
2. Ensure the app is added to the allowed security group

### Error: 403 Forbidden

**Cause:** Service principal doesn't have access to the specific workspace/dataset.

**Solution:**
1. Add the service principal to the workspace as Member or Admin
2. For datasets with RLS: Use delegated user auth instead of service principal

### Error: Dataset has RLS enabled

**Cause:** Row-Level Security datasets don't work with service principals.

**Solution:**
1. Disable RLS on the dataset (if not needed)
2. Use delegated user authentication instead
3. Create a separate dataset without RLS for API access

### Error: Invalid DAX Query

**Cause:** Syntax error in DAX query.

**Solution:**
1. Test the query in Power BI Desktop first
2. Ensure table/column names are correct
3. Use proper DAX syntax (EVALUATE, SUMMARIZECOLUMNS, etc.)

---

## Security Considerations

1. **Service Principal Scope:** Only grant access to specific workspaces, not the entire tenant
2. **RLS:** If data needs row-level filtering, use delegated auth with user context
3. **Query Limits:** DAX queries are limited to 1M values or 100K rows
4. **Rate Limits:** Power BI API has rate limits; implement caching in Supabase

---

## Next Steps After Admin Setup

1. Run `node scripts/test-powerbi-connection.mjs` to verify access
2. Identify the dataset ID for the target report
3. Create DAX queries to extract the required data
4. Implement a caching layer in Supabase for performance
5. Create React hooks for consuming the data in the dashboard

---

## Resources

- [Power BI REST API Reference](https://learn.microsoft.com/en-us/rest/api/power-bi/)
- [Execute Queries API](https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/execute-queries)
- [Service Principal Setup](https://learn.microsoft.com/en-us/power-bi/developer/embedded/embed-service-principal)
- [DAX Query Examples](https://dax.guide/)
