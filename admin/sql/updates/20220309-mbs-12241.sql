\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE FUNCTION controlled_for_whitespace(TEXT) RETURNS boolean AS $$
  SELECT NOT padded_by_whitespace($1);
$$ LANGUAGE SQL IMMUTABLE SET search_path = musicbrainz, public;

DROP FUNCTION IF EXISTS whitespace_collapsed(TEXT);

COMMIT;
