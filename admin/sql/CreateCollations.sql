\set ON_ERROR_STOP 1

SET search_path = musicbrainz, public;

BEGIN;

CREATE COLLATION musicbrainz (
    provider = icu,
    locale = '@colCaseFirst=lower;colNumeric=yes'
);

COMMIT;
