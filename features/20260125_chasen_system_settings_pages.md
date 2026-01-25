# ChaSen Preferences and System Settings Pages Implementation

**Date**: 25 January 2026
**Type**: Enhancement
**Status**: Completed

## Summary

Implemented two new settings pages that were previously marked as "Coming Soon":
1. **ChaSen Preferences** (`/settings/chasen`) - Configure ChaSen AI behaviour
2. **System Settings** (`/settings/system`) - System-wide configuration

## Changes Made

### 1. ChaSen Preferences Page
**File**: `src/app/(dashboard)/settings/chasen/page.tsx`

Features:
- **Response Style Settings**:
  - Response Format (detailed, concise, bullet points)
  - Tone (professional, formal, casual)
  - Detail Level (high, medium, low)
  - Maximum Response Length (short, medium, long)

- **AI Response Content Toggles**:
  - Include Recommendations
  - Include Follow-Up Questions
  - Include Data Highlights

- **Client Preferences**:
  - Favourite Clients (prioritised in responses)
  - Excluded Clients (omitted from responses)

Uses existing `useChaSenPreferences` hook and `chasen_user_preferences` table.

### 2. System Settings Page
**File**: `src/app/(dashboard)/settings/system/page.tsx`

Features:
- **Health Score Configuration**:
  - Health Score Version (v4, v6)
  - Healthy Threshold (default: 70)
  - At-Risk Threshold (default: 60)

- **Alert Thresholds**:
  - Health Decline Alert (points)
  - NPS Risk Threshold
  - Compliance Critical Threshold (%)
  - Renewal Warning (days)
  - Action Overdue (days)

- **Feature Toggles**:
  - AI Features (master toggle)
  - Proactive Insights
  - Churn Prediction
  - Email Generator

- **Notification Settings**:
  - In-App Notifications
  - Email Alerts
  - Default Alert Severity Filter

- **Data Retention**:
  - Audit Log Retention (days)
  - Conversation History (days)

### 3. Database Migration
**Table**: `system_settings`

Created new table via Supabase Management API with:
- All configuration columns with sensible defaults
- RLS enabled with appropriate policies
- Default 'global' row inserted

### 4. Settings Index Update
**File**: `src/app/(dashboard)/settings/page.tsx`

Updated both ChaSen Preferences and System Settings status from `'coming_soon'` to `'available'`.

## Technical Details

### Database Schema
```sql
CREATE TABLE system_settings (
  id TEXT PRIMARY KEY DEFAULT 'global',
  health_score_version TEXT DEFAULT 'v4',
  healthy_threshold INTEGER DEFAULT 70,
  at_risk_threshold INTEGER DEFAULT 60,
  health_decline_alert_threshold INTEGER DEFAULT 10,
  nps_risk_threshold INTEGER DEFAULT 6,
  compliance_critical_threshold INTEGER DEFAULT 50,
  renewal_warning_days INTEGER DEFAULT 90,
  action_overdue_days INTEGER DEFAULT 7,
  enable_ai_features BOOLEAN DEFAULT true,
  enable_proactive_insights BOOLEAN DEFAULT true,
  enable_churn_prediction BOOLEAN DEFAULT true,
  enable_email_generator BOOLEAN DEFAULT true,
  enable_in_app_notifications BOOLEAN DEFAULT true,
  enable_email_alerts BOOLEAN DEFAULT true,
  default_alert_severity TEXT DEFAULT 'all',
  audit_log_retention_days INTEGER DEFAULT 365,
  conversation_retention_days INTEGER DEFAULT 90,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### RLS Policies
- Read: Allow for all authenticated users
- Update: Allow for service role
- Insert: Allow for service role

## UI Components Used
- Card, CardContent, CardHeader, CardTitle, CardDescription
- Switch (from `@/components/ui/Switch`)
- Select, SelectContent, SelectItem, SelectTrigger, SelectValue
- Input, Label, Button, Badge
- Alert, AlertDescription

## Testing
- TypeScript compilation: Passed
- Database table: Created and verified
- Default settings: Populated correctly

## Commit
```
75792bf8 Add ChaSen Preferences and System Settings pages
```
