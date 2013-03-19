\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE medium ADD COLUMN track_count INTEGER NOT NULL DEFAULT 0;

UPDATE medium
    SET track_count = tc.count
    FROM (SELECT count(id),medium FROM track GROUP BY medium) tc
    WHERE tc.medium = medium.id;

CREATE INDEX medium_idx_track_count ON medium (track_count);

COMMIT;
