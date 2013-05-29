\set ON_ERROR_STOP 1

BEGIN;
    CREATE UNIQUE INDEX track_idx_gid ON track (gid);

    CREATE INDEX track_idx_recording ON track (recording);
    CREATE INDEX track_idx_medium ON track (medium, position);
    CREATE INDEX track_idx_name ON track (name);
    CREATE INDEX track_idx_artist_credit ON track (artist_credit);
COMMIT;
