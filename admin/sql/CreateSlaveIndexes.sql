\set ON_ERROR_STOP 1
BEGIN;

CREATE INDEX medium_idx_release ON medium (release, position);

CREATE INDEX track_idx_medium ON track (medium, position);

COMMIT;
