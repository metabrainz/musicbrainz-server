\set ON_ERROR_STOP 1
BEGIN;

CREATE INDEX medium_idx_release_position ON medium (release, position);

CREATE INDEX track_idx_medium_position ON track (medium, position);

COMMIT;
