\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE FUNCTION set_medium_recordings_first_release_dates(medium_ids INTEGER[])
RETURNS VOID AS $$
BEGIN
  PERFORM set_recordings_first_release_dates((
    SELECT array_agg(recording)
      FROM track
     WHERE track.medium = any(medium_ids)
  ));
  RETURN;
END;
$$ LANGUAGE 'plpgsql' STRICT;

CREATE OR REPLACE FUNCTION a_upd_medium_mirror()
RETURNS trigger AS $$
BEGIN
    -- DO NOT modify any replicated tables in this function; it's used
    -- by a trigger on mirrors.
    IF NEW.release IS DISTINCT FROM OLD.release THEN
        PERFORM set_medium_recordings_first_release_dates(ARRAY[OLD.id]);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER a_upd_medium AFTER UPDATE ON medium
    FOR EACH ROW EXECUTE PROCEDURE a_upd_medium_mirror();

DO $$
BEGIN
  PERFORM 1 FROM recording_first_release_date;
  IF FOUND THEN
    RAISE NOTICE 'Truncating recording_first_release_date...';
    TRUNCATE recording_first_release_date;
    RAISE NOTICE 'Rebuilding recording_first_release_date...';
    INSERT INTO recording_first_release_date SELECT * FROM get_recording_first_release_date_rows('TRUE');
    RAISE NOTICE 'Clustering recording_first_release_date...';
    CLUSTER recording_first_release_date USING recording_first_release_date_pkey;
  END IF;
END $$;

COMMIT;
