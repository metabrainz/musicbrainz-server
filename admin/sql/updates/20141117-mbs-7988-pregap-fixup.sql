\set ON_ERROR_STOP 1
BEGIN;

UPDATE track SET is_data_track = false WHERE position = 0;

COMMIT;
