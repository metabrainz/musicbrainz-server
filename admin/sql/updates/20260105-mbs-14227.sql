\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE url ADD COLUMN key TEXT;

-- Cannot be unique as some sites share IDs in URLs, for example Amazon and Amazon Music.
CREATE INDEX url_idx_key ON url (key);

COMMIT;
