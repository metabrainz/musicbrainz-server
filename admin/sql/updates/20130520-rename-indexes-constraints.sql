\set ON_ERROR_STOP 1

BEGIN;
    ALTER INDEX medium_2013_pkey RENAME TO medium_pkey;
    ALTER INDEX track_2013_pkey RENAME TO track_pkey;

    ALTER TABLE track DROP CONSTRAINT IF EXISTS track2013_edits_pending_check;
    ALTER TABLE track DROP CONSTRAINT IF EXISTS track2013_length_check;
    ALTER TABLE track DROP CONSTRAINT IF EXISTS track2013_number_check;
COMMIT;
