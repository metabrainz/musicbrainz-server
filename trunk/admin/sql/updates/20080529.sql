\set ON_ERROR_STOP 1

BEGIN;

-- Drop the TRM tables
DROP TABLE trmjoin CASCADE;
DROP TABLE trmjoin_stat CASCADE;
DROP TABLE trm CASCADE;
DROP TABLE trm_stat CASCADE;

-- Remove the various trmids columns
ALTER TABLE albummeta DROP COLUMN trmids;
ALTER TABLE stats DROP COLUMN trmids;

-- Remove the TRM edits from the database
DELETE FROM moderation_closed where type = 22 or type = 27;

COMMIT;
