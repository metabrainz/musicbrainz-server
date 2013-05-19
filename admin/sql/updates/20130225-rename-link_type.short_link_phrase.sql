\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE link_type RENAME short_link_phrase TO long_link_phrase;

COMMIT;
