\set ON_ERROR_STOP 1

-- This adds a column to the album table to let us know when a release was added to MB

BEGIN;

ALTER TABLE albummeta ADD COLUMN dateadded TIMESTAMP WITH TIME ZONE DEFAULT '1970-01-01 00:00:00-00';
ALTER TABLE albummeta ALTER COLUMN dateadded DROP DEFAULT;
ALTER TABLE albummeta ALTER COLUMN dateadded SET DEFAULT now();

COMMIT;
