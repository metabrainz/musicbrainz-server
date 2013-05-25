\set ON_ERROR_STOP 1

BEGIN;
    DROP INDEX IF EXISTS track_idx_artist_credit;
    DROP INDEX IF EXISTS track_idx_gid;
    DROP INDEX IF EXISTS track_idx_medium;
    DROP INDEX IF EXISTS track_idx_name;
    DROP INDEX IF EXISTS track_idx_recording;
COMMIT;
