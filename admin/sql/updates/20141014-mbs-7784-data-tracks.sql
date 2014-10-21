\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE track ADD COLUMN is_data_track BOOLEAN NOT NULL DEFAULT FALSE;

CREATE OR REPLACE FUNCTION track_count_matches_cdtoc(medium, int) RETURNS boolean AS $$
    SELECT $1.track_count = $2 + COALESCE(
        (SELECT count(*) FROM track
         WHERE medium = $1.id AND (position = 0 OR is_data_track = true)
    ), 0);
$$ LANGUAGE SQL IMMUTABLE;

COMMIT;
