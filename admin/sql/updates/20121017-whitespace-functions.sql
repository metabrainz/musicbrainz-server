BEGIN;

CREATE OR REPLACE FUNCTION padded_by_whitespace(TEXT) RETURNS boolean AS $$
  SELECT btrim($1) <> $1;
$$ LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION whitespace_collapsed(TEXT) RETURNS boolean AS $$
  SELECT $1 !~ E'\\s{2,}';
$$ LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION controlled_for_whitespace(TEXT) RETURNS boolean AS $$
  SELECT NOT padded_by_whitespace($1) AND whitespace_collapsed($1);
$$ LANGUAGE SQL IMMUTABLE SET search_path = musicbrainz, public;

COMMIT;
