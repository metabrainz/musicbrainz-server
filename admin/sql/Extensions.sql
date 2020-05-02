\set ON_ERROR_STOP 1
BEGIN;

CREATE EXTENSION IF NOT EXISTS cube WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS earthdistance WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;

-- The unaccent function, but IMMUTABLE. Based on a solution provided by
-- Erwin Brandstetter in [1], which removes the dependency on search_path.
-- Warning: changing the unaccent dictionary on the filesystem can still
-- break the IMMUTABLE assumption.
--
-- The answer in [1] suggests that using a C function for immutable_unaccent
-- allows it to be inlined in musicbrainz_unaccent below, and is 10x faster
-- than the fallback. Although this script is meant to execute as a
-- superuser, a fallback is provided specifically for instances where even
-- the "superuser" is restricted in creating C language functions, e.g.
-- Amazon RDS.
--
-- [1] https://stackoverflow.com/a/11007216

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

COMMIT;
-- vi: set ts=4 sw=4 et :
