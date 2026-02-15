# Bug Report: Health Check (Opal) Requirement Removal for Department of Health - Victoria

**Date:** 23 December 2025
**Status:** Fixed
**Severity:** Medium
**Component:** Compliance View, Client Event Exclusions

---

## Problem Description

"Health Check (Opal)" was appearing as a required event type for Department of Health - Victoria, but this client should not have this requirement. The requirement should only apply to other Nurture segment clients.

---

## Root Cause Analysis

The `event_compliance_summary` materialized view was calculating requirements based solely on the client's segment tier. All Nurture tier clients were receiving the same event requirements, including Health Check (Opal).

There was no mechanism to exclude specific event types for individual clients.

---

## Solution Implemented

### 1. Created Client Event Exclusions Table

A new table `client_event_exclusions` was created to store client-specific event exclusions:

```sql
CREATE TABLE client_event_exclusions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_name TEXT NOT NULL,
  event_type_id UUID NOT NULL REFERENCES segmentation_event_types(id),
  reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  created_by TEXT,
  UNIQUE(client_name, event_type_id)
);
```

### 2. Added Exclusion Record

```sql
INSERT INTO client_event_exclusions (client_name, event_type_id, reason, created_by)
SELECT
  'Department of Health - Victoria',
  id,
  'DoH Victoria does not require Health Check (Opal) events per business decision - Dec 2025',
  'system'
FROM segmentation_event_types
WHERE event_name = 'Health Check (Opal)';
```

### 3. Updated Materialized View

The `event_compliance_summary` view was recreated with exclusion support:

```sql
combined_requirements AS (
  SELECT
    csp.client_name,
    csp.year,
    tr.event_type_id,
    tr.event_name,
    tr.event_code,
    MAX(tr.expected_frequency) as expected_count
  FROM client_segment_periods csp
  INNER JOIN tier_requirements tr ON tr.tier_id = csp.tier_id
  -- EXCLUDE client-specific exclusions
  WHERE NOT EXISTS (
    SELECT 1 FROM client_event_exclusions cee
    WHERE cee.client_name = csp.client_name
      AND cee.event_type_id = tr.event_type_id
  )
  GROUP BY ...
)
```

---

## Results

| Metric                       | Before | After |
| ---------------------------- | ------ | ----- |
| Overall Compliance Score     | 82%    | 90%   |
| Total Event Types Required   | 11     | 10    |
| Health Check (Opal) Required | Yes    | No    |

### Current Required Event Types for DoH Victoria

| Event Type                     | Actual | Expected | Status      |
| ------------------------------ | ------ | -------- | ----------- |
| Satisfaction Action Plan       | 0      | 1        | ✗ Critical  |
| APAC Client Forum / User Group | 1      | 1        | ✓ Compliant |
| Upcoming Release Planning      | 2      | 2        | ✓ Compliant |
| Insight Touch Point            | 12     | 12       | ✓ Compliant |
| Updating Client 360            | 12     | 8        | ✓ Exceeded  |
| Strategic Ops Plan Meeting     | 3      | 2        | ✓ Exceeded  |
| Whitespace Demos (Sunrise)     | 3      | 2        | ✓ Exceeded  |
| CE On-Site Attendance          | 4      | 2        | ✓ Exceeded  |
| SLA/Service Review Meeting     | 12     | 4        | ✓ Exceeded  |
| EVP Engagement                 | 8      | 1        | ✓ Exceeded  |

---

## Files Changed

| File                                                       | Changes                           |
| ---------------------------------------------------------- | --------------------------------- |
| `docs/migrations/20251223_add_client_event_exclusions.sql` | Full migration SQL                |
| `scripts/setup-client-exclusion.mjs`                       | Script to insert exclusion record |
| `scripts/run-exclusion-migration.mjs`                      | Script to run the view update     |

---

## How to Add More Exclusions

To exclude an event type for another client:

```javascript
// Using the Supabase client with service role key
const { error } = await supabase.from('client_event_exclusions').insert({
  client_name: 'Client Name',
  event_type_id: 'uuid-of-event-type',
  reason: 'Business reason for exclusion',
  created_by: 'user@email.com',
})

// Then refresh the materialized view
await supabase.rpc('exec_sql', {
  sql_query: 'REFRESH MATERIALIZED VIEW event_compliance_summary',
})
```

---

## Notes

- This exclusion only affects Department of Health - Victoria
- Other Nurture segment clients still have Health Check (Opal) as a requirement
- The exclusion is stored permanently in the database
- Future view refreshes will respect this exclusion automatically
