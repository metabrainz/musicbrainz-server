\set ON_ERROR_STOP 1

-- This adds a column to the album table to let us know when a release was added to MB

BEGIN;

ALTER TABLE album ADD COLUMN dateadded TIMESTAMP WITH TIME ZONE DEFAULT now();

COMMIT;
