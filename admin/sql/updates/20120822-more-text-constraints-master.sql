BEGIN;

ALTER TABLE artist_name ADD CHECK (controlled_for_whitespace(name));
ALTER TABLE url ADD CHECK (controlled_for_whitespace(description));
ALTER TABLE track_name ADD CHECK (controlled_for_whitespace(name));

COMMIT;
