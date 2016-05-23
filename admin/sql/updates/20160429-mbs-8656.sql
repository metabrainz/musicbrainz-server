\set ON_ERROR_STOP 1
BEGIN;

-- MBS-8656: Bring edit table indexes back into sync
DROP INDEX IF EXISTS edit_close_time_idx;
DROP INDEX IF EXISTS edit_date_trunc_idx;
DROP INDEX IF EXISTS edit_date_trunc_idx1;
DROP INDEX IF EXISTS edit_date_trunc_idx2;
DROP INDEX IF EXISTS edit_id_idx;
DROP INDEX IF EXISTS edit_open_time_idx1;
DROP INDEX IF EXISTS edit_status_idx;
ALTER INDEX IF EXISTS edit_open_time_idx RENAME TO edit_idx_open_time;

COMMIT;
