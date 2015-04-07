\set ON_ERROR_STOP 1

CREATE UNIQUE INDEX CONCURRENTLY track_idx_medium_position_uniq ON track (medium, position);

DROP INDEX IF EXISTS track_idx_medium;
