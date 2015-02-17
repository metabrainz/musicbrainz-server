\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE editor ADD COLUMN deleted BOOLEAN DEFAULT FALSE NOT NULL;

UPDATE EDITOR SET deleted = TRUE WHERE name = 'Deleted Editor #' || id::text and password = '{CRYPT}*';

COMMIT;
