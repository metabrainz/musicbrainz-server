\set ON_ERROR_STOP 1
BEGIN;

CREATE EXTENSION cube WITH SCHEMA public;
CREATE EXTENSION musicbrainz_unaccent WITH SCHEMA musicbrainz;

COMMIT;

-- vi: set ts=4 sw=4 et :
