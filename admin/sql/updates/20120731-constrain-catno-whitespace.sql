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

ALTER TABLE artist        ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE artist_name   ADD CHECK (controlled_for_whitespace(name));
ALTER TABLE label         ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE label_name    ADD CHECK (controlled_for_whitespace(name));
ALTER TABLE medium        ADD CHECK (controlled_for_whitespace(name));
ALTER TABLE recording     ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE release       ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE release_group ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE release_label ADD CHECK (controlled_for_whitespace(catalog_number));
ALTER TABLE release_name  ADD CHECK (controlled_for_whitespace(name));
ALTER TABLE track         ADD CHECK (controlled_for_whitespace(number));
ALTER TABLE track_name    ADD CHECK (controlled_for_whitespace(name));
ALTER TABLE url           ADD CHECK (controlled_for_whitespace(description));
ALTER TABLE work          ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE work_name     ADD CHECK (controlled_for_whitespace(name));

COMMIT;
