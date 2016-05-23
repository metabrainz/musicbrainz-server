\set ON_ERROR_STOP 1
BEGIN;

CREATE EXTENSION IF NOT EXISTS cube WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS earthdistance WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS musicbrainz_unaccent WITH SCHEMA musicbrainz;
CREATE EXTENSION IF NOT EXISTS musicbrainz_collate WITH SCHEMA musicbrainz;

COMMIT;
-- vi: set ts=4 sw=4 et :
