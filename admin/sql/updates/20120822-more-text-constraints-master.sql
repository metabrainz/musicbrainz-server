\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE artist_name ADD CHECK (controlled_for_whitespace(name));
ALTER TABLE track_name ADD CHECK (controlled_for_whitespace(name));

COMMIT;
