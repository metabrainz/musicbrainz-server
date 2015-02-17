\set ON_ERROR_STOP 1

BEGIN;
    DROP INDEX IF EXISTS medium_idx_release;
    CREATE INDEX medium_idx_release ON medium (release);
COMMIT;
