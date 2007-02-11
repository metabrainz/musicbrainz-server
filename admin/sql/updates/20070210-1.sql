-- Abstract: add column locked column to album table

\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE artist ADD COLUMN strict INTEGER DEFAULT 0; 

COMMIT;

-- vi: set ts=4 sw=4 et :
