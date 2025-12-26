# Feature: Last Updated Date in Compliance Details Modal

**Date**: 17 December 2024
**Status**: Completed
**Priority**: Low

## Summary

Added a "Last updated" timestamp to the Compliance Details modal header, showing when the compliance data was last refreshed from the database.

## User Request

> Add "Last updated" date to Compliance Details modal

## Implementation Details

### File Modified

**`src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx`**

Added the last_updated display in the modal header at line 1292-1303.

### Changes

The Compliance Details modal header now displays:

- Title: "2024 Compliance Details"
- Subtitle: "Client Name • X of Y Events Completed"
- **NEW**: "Last updated: 17 Dec 2024, 11:30 AM" (with clock icon)

### Code Added

```tsx
{
  compliance.last_updated && (
    <p className="text-xs text-white/60 mt-1 flex items-center gap-1">
      <Clock className="h-3 w-3" />
      Last updated:{' '}
      {new Date(compliance.last_updated).toLocaleDateString('en-AU', {
        day: 'numeric',
        month: 'short',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
      })}
    </p>
  )
}
```

### Data Source

The `last_updated` field is populated from:

1. The `event_compliance_summary` materialized view in Supabase
2. Falls back to current timestamp if not available

The timestamp reflects when the compliance data was last calculated/refreshed from the database.

## Testing

1. Navigate to Client Profile page
2. Click on a client to open their profile
3. Go to the "Insights" tab
4. View the Event Compliance section
5. Click to open the Compliance Details modal
6. Verify the "Last updated" timestamp appears in the modal header

## Notes

- The timestamp uses Australian date format (en-AU) as per project standards
- The Clock icon from lucide-react provides visual context
- The text is styled with reduced opacity (text-white/60) to be visible but not prominent
