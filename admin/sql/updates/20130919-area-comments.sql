\set ON_ERROR_STOP 1
BEGIN;

-----------------------
-- CREATE NEW COLUMN --
-----------------------

ALTER TABLE area ADD COLUMN comment VARCHAR(255) NOT NULL DEFAULT '';

COMMIT;
