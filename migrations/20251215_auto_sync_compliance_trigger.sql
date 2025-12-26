-- Migration: Auto-sync segmentation_event_compliance from segmentation_events
-- Date: 15 December 2025
-- Purpose: Automatically update actual_count in segmentation_event_compliance
--          when events are marked complete/incomplete in segmentation_events

-- Drop existing trigger and function if they exist
DROP TRIGGER IF EXISTS sync_compliance_on_event_change ON segmentation_events;
DROP FUNCTION IF EXISTS sync_compliance_actual_count();

-- Create function to sync compliance actual_count
CREATE OR REPLACE FUNCTION sync_compliance_actual_count()
RETURNS TRIGGER AS $$
DECLARE
    v_client_name TEXT;
    v_event_type_id UUID;
    v_year INT;
    v_actual_count INT;
    v_compliance_client TEXT;
BEGIN
    -- Determine which row to use (NEW for INSERT/UPDATE, OLD for DELETE)
    IF TG_OP = 'DELETE' THEN
        v_client_name := OLD.client_name;
        v_event_type_id := OLD.event_type_id;
        v_year := EXTRACT(YEAR FROM OLD.event_date)::INT;
    ELSE
        v_client_name := NEW.client_name;
        v_event_type_id := NEW.event_type_id;
        v_year := EXTRACT(YEAR FROM NEW.event_date)::INT;
    END IF;

    -- Count all completed events for this client/event_type/year
    SELECT COUNT(*)
    INTO v_actual_count
    FROM segmentation_events
    WHERE event_type_id = v_event_type_id
      AND completed = true
      AND EXTRACT(YEAR FROM event_date) = v_year
      AND (
          -- Exact match
          client_name = v_client_name
          -- Or normalized match (handles "Albury Wodonga" vs "Albury Wodonga Health")
          OR LOWER(REGEXP_REPLACE(client_name, '[^a-zA-Z]', '', 'g'))
             LIKE '%' || LOWER(REGEXP_REPLACE(v_client_name, '[^a-zA-Z]', '', 'g')) || '%'
          OR LOWER(REGEXP_REPLACE(v_client_name, '[^a-zA-Z]', '', 'g'))
             LIKE '%' || LOWER(REGEXP_REPLACE(client_name, '[^a-zA-Z]', '', 'g')) || '%'
      );

    -- Find the compliance record - try exact match first
    SELECT client_name INTO v_compliance_client
    FROM segmentation_event_compliance
    WHERE event_type_id = v_event_type_id
      AND year = v_year
      AND client_name = v_client_name
    LIMIT 1;

    -- If no exact match, try normalized match
    IF v_compliance_client IS NULL THEN
        SELECT client_name INTO v_compliance_client
        FROM segmentation_event_compliance
        WHERE event_type_id = v_event_type_id
          AND year = v_year
          AND (
              LOWER(REGEXP_REPLACE(client_name, '[^a-zA-Z]', '', 'g'))
              LIKE '%' || LOWER(REGEXP_REPLACE(v_client_name, '[^a-zA-Z]', '', 'g')) || '%'
              OR LOWER(REGEXP_REPLACE(v_client_name, '[^a-zA-Z]', '', 'g'))
              LIKE '%' || LOWER(REGEXP_REPLACE(client_name, '[^a-zA-Z]', '', 'g')) || '%'
          )
        LIMIT 1;
    END IF;

    -- Update the compliance record if found
    IF v_compliance_client IS NOT NULL THEN
        UPDATE segmentation_event_compliance
        SET actual_count = v_actual_count,
            updated_at = NOW()
        WHERE event_type_id = v_event_type_id
          AND year = v_year
          AND client_name = v_compliance_client;

        RAISE NOTICE 'Updated compliance for % (event_type: %, year: %): actual_count = %',
                     v_compliance_client, v_event_type_id, v_year, v_actual_count;
    END IF;

    -- Return appropriate row
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on segmentation_events
CREATE TRIGGER sync_compliance_on_event_change
AFTER INSERT OR UPDATE OF completed OR DELETE
ON segmentation_events
FOR EACH ROW
EXECUTE FUNCTION sync_compliance_actual_count();

-- Add updated_at column to segmentation_event_compliance if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'segmentation_event_compliance'
        AND column_name = 'updated_at'
    ) THEN
        ALTER TABLE segmentation_event_compliance
        ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- Grant execute permission on the function
GRANT EXECUTE ON FUNCTION sync_compliance_actual_count() TO authenticated;
GRANT EXECUTE ON FUNCTION sync_compliance_actual_count() TO service_role;

COMMENT ON FUNCTION sync_compliance_actual_count() IS
'Automatically syncs actual_count in segmentation_event_compliance when events are marked complete/incomplete in segmentation_events. Handles client name variations.';

COMMENT ON TRIGGER sync_compliance_on_event_change ON segmentation_events IS
'Triggers compliance sync when event completion status changes';
