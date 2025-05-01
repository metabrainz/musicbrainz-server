\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE FUNCTION set_mediums_recordings_first_release_dates(medium_ids INTEGER[])
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
        PERFORM set_mediums_recordings_first_release_dates(ARRAY[OLD.id]);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER a_upd_medium AFTER UPDATE ON medium
    FOR EACH ROW EXECUTE PROCEDURE a_upd_medium_mirror();

TRUNCATE recording_first_release_date;

COMMIT;
