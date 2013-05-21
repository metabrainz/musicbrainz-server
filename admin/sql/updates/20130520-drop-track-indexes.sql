\set ON_ERROR_STOP 1

BEGIN;
    DROP INDEX track_idx_artist_credit;
    DROP INDEX track_idx_gid;
    DROP INDEX track_idx_medium;
    DROP INDEX track_idx_name;
    DROP INDEX track_idx_recording;
COMMIT;
