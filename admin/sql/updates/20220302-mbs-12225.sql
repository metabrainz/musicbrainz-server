\set ON_ERROR_STOP 1

BEGIN;

-- The internal comment had the word "slaves" changed to "mirrors."
-- The function is otherwise unchanged.
CREATE OR REPLACE FUNCTION set_recordings_first_release_dates(recording_ids INTEGER[])
RETURNS VOID AS $$
BEGIN
  -- DO NOT modify any replicated tables in this function; it's used
  -- by a trigger on mirrors.
  DELETE FROM recording_first_release_date
  WHERE recording = ANY(recording_ids);

  INSERT INTO recording_first_release_date
  SELECT * FROM get_recording_first_release_date_rows(
    format('track.recording = any(%L)', recording_ids)
  );
END;
$$ LANGUAGE 'plpgsql' STRICT;

-- The internal comment had the word "slaves" changed to "mirrors."
-- The function is otherwise unchanged.
CREATE OR REPLACE FUNCTION set_release_first_release_date(release_id INTEGER)
RETURNS VOID AS $$
BEGIN
  -- DO NOT modify any replicated tables in this function; it's used
  -- by a trigger on mirrors.
  DELETE FROM release_first_release_date
  WHERE release = release_id;

  INSERT INTO release_first_release_date
  SELECT * FROM get_release_first_release_date_rows(
    format('release = %L', release_id)
  );

  INSERT INTO artist_release_pending_update VALUES (release_id);
END;
$$ LANGUAGE 'plpgsql' STRICT;

COMMIT;
