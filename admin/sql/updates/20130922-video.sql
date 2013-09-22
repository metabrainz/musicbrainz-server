\set ON_ERROR_STOP 1
BEGIN;

-----------------------
-- CREATE NEW COLUMN --
-----------------------

ALTER TABLE recording ADD COLUMN video BOOLEAN NOT NULL DEFAULT FALSE;

COMMIT;
