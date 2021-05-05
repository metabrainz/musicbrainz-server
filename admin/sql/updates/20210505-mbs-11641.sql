\set ON_ERROR_STOP 1

BEGIN;

DROP INDEX IF EXISTS artist_rating_raw_idx_artist;
DROP INDEX IF EXISTS event_rating_raw_idx_event;
DROP INDEX IF EXISTS label_rating_raw_idx_label;
DROP INDEX IF EXISTS release_group_rating_raw_idx_release_group;

COMMIT;
