\set ON_ERROR_STOP 1

SET search_path = musicbrainz, public;
SET statement_timeout = 0;

BEGIN;

-- The production database has the cube extension in the musicbrainz schema,
-- though it's supposed to be in `public` per admin/sql/Extensions.sql.
-- (This was apparently changed in 2012 with a08a8cb.)
ALTER EXTENSION cube SET SCHEMA public;
ALTER EXTENSION cube UPDATE;

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;
ALTER EXTENSION unaccent UPDATE TO '1.1';

CREATE OR REPLACE FUNCTION musicbrainz.ll_to_earth(float8, float8)
RETURNS public.earth
LANGUAGE SQL
IMMUTABLE STRICT
PARALLEL SAFE
AS 'SELECT public.cube(public.cube(public.cube(public.earth()*cos(radians($1))*cos(radians($2))),public.earth()*cos(radians($1))*sin(radians($2))),public.earth()*sin(radians($1)))::public.earth';

DO $$
BEGIN
  CREATE OR REPLACE FUNCTION public.immutable_unaccent(regdictionary, text)
    RETURNS text LANGUAGE c IMMUTABLE PARALLEL SAFE STRICT AS
  '$libdir/unaccent', 'unaccent_dict';

  CREATE OR REPLACE FUNCTION musicbrainz.musicbrainz_unaccent(text)
    RETURNS text LANGUAGE sql IMMUTABLE PARALLEL SAFE STRICT AS
  $func$
    SELECT public.immutable_unaccent(regdictionary 'public.unaccent', $1)
  $func$;
EXCEPTION
  WHEN insufficient_privilege THEN
    CREATE OR REPLACE FUNCTION musicbrainz.musicbrainz_unaccent(text)
      RETURNS text LANGUAGE sql IMMUTABLE PARALLEL SAFE STRICT AS
    $func$
      SELECT public.unaccent('public.unaccent', $1)
    $func$;
END
$$;

DROP COLLATION IF EXISTS musicbrainz.musicbrainz CASCADE;
CREATE COLLATION musicbrainz (
    provider = icu,
    locale = '@colCaseFirst=lower;colNumeric=yes'
);

CREATE TEXT SEARCH CONFIGURATION mb_simple (COPY = pg_catalog.simple);
ALTER TEXT SEARCH CONFIGURATION mb_simple
    ALTER MAPPING FOR word, numword, hword, numhword, hword_part, hword_numpart
    WITH unaccent, simple;

CREATE OR REPLACE FUNCTION mb_lower(input text) RETURNS text AS $$
  SELECT lower(input COLLATE musicbrainz.musicbrainz);
$$ LANGUAGE SQL IMMUTABLE PARALLEL SAFE STRICT;

CREATE OR REPLACE FUNCTION mb_simple_tsvector(input text) RETURNS tsvector AS $$
  SELECT to_tsvector('musicbrainz.mb_simple', musicbrainz.mb_lower(input));
$$ LANGUAGE SQL IMMUTABLE PARALLEL SAFE STRICT;

ALTER FUNCTION mb_lower(text) OWNER TO musicbrainz;
ALTER FUNCTION mb_simple_tsvector(text) OWNER TO musicbrainz;

CREATE INDEX artist_idx_txt ON artist USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX artist_idx_txt_sort ON artist USING gin(musicbrainz.mb_simple_tsvector(sort_name));
CREATE INDEX artist_alias_idx_txt ON artist_alias USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX artist_alias_idx_txt_sort ON artist_alias USING gin(musicbrainz.mb_simple_tsvector(sort_name));
CREATE INDEX artist_credit_idx_txt ON artist_credit USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX artist_credit_name_idx_txt ON artist_credit_name USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX event_idx_txt ON event USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX event_alias_idx_txt ON event_alias USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX event_alias_idx_txt_sort ON event_alias USING gin(musicbrainz.mb_simple_tsvector(sort_name));
CREATE INDEX instrument_idx_txt ON instrument USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX label_idx_txt ON label USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX label_alias_idx_txt ON label_alias USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX label_alias_idx_txt_sort ON label_alias USING gin(musicbrainz.mb_simple_tsvector(sort_name));
CREATE INDEX release_idx_txt ON release USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX release_alias_idx_txt ON release_alias USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX release_alias_idx_txt_sort ON release_alias USING gin(musicbrainz.mb_simple_tsvector(sort_name));
CREATE INDEX release_group_idx_txt ON release_group USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX release_group_alias_idx_txt ON release_group_alias USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX release_group_alias_idx_txt_sort ON release_group_alias USING gin(musicbrainz.mb_simple_tsvector(sort_name));
CREATE INDEX recording_idx_txt ON recording USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX recording_alias_idx_txt ON recording_alias USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX recording_alias_idx_txt_sort ON recording_alias USING gin(musicbrainz.mb_simple_tsvector(sort_name));
CREATE INDEX series_idx_txt ON series USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX series_alias_idx_txt ON series_alias USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX series_alias_idx_txt_sort ON series_alias USING gin(musicbrainz.mb_simple_tsvector(sort_name));
CREATE INDEX work_idx_txt ON work USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX work_alias_idx_txt ON work_alias USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX work_alias_idx_txt_sort ON work_alias USING gin(musicbrainz.mb_simple_tsvector(sort_name));
CREATE INDEX area_idx_name_txt ON area USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX area_alias_idx_txt ON area_alias USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX area_alias_idx_txt_sort ON area_alias USING gin(musicbrainz.mb_simple_tsvector(sort_name));
CREATE INDEX place_idx_name_txt ON place USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX place_alias_idx_txt ON place_alias USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX place_alias_idx_txt_sort ON place_alias USING gin(musicbrainz.mb_simple_tsvector(sort_name));
CREATE INDEX tag_idx_name_txt ON tag USING gin(musicbrainz.mb_simple_tsvector(name));

CREATE INDEX release_idx_musicbrainz_collate ON release (name COLLATE musicbrainz.musicbrainz);
CREATE INDEX release_group_idx_musicbrainz_collate ON release_group (name COLLATE musicbrainz.musicbrainz);
CREATE INDEX artist_idx_musicbrainz_collate ON artist (name COLLATE musicbrainz.musicbrainz);
CREATE INDEX artist_credit_idx_musicbrainz_collate ON artist_credit (name COLLATE musicbrainz.musicbrainz);
CREATE INDEX artist_credit_name_idx_musicbrainz_collate ON artist_credit_name (name COLLATE musicbrainz.musicbrainz);
CREATE INDEX label_idx_musicbrainz_collate ON label (name COLLATE musicbrainz.musicbrainz);
CREATE INDEX recording_idx_musicbrainz_collate ON recording (name COLLATE musicbrainz.musicbrainz);
CREATE INDEX work_idx_musicbrainz_collate ON work (name COLLATE musicbrainz.musicbrainz);

CREATE INDEX place_idx_geo ON place USING gist (musicbrainz.ll_to_earth(coordinates[0], coordinates[1])) WHERE coordinates IS NOT NULL;

COMMIT;
