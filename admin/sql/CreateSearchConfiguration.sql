\set ON_ERROR_STOP 1

SET search_path = musicbrainz, public;

BEGIN;

CREATE OR REPLACE FUNCTION musicbrainz_unaccent (text) RETURNS text
    AS '$libdir/musicbrainz_unaccent'
    LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION musicbrainz_dunaccentdict_init(internal)
    RETURNS internal
    AS '$libdir/musicbrainz_unaccent'
    LANGUAGE C STRICT;

CREATE OR REPLACE FUNCTION musicbrainz_dunaccentdict_lexize(internal, internal, internal, internal)
    RETURNS internal
    AS '$libdir/musicbrainz_unaccent'
    LANGUAGE C STRICT;

CREATE TEXT SEARCH TEMPLATE musicbrainz_unaccentdict_template (
    LEXIZE = musicbrainz_dunaccentdict_lexize,
    INIT   = musicbrainz_dunaccentdict_init
);

CREATE TEXT SEARCH DICTIONARY musicbrainz_unaccentdict (
    TEMPLATE = musicbrainz_unaccentdict_template
);

COMMENT ON TEXT SEARCH DICTIONARY musicbrainz_unaccentdict IS 'musicbrainz unaccenting dictionary';

CREATE TEXT SEARCH CONFIGURATION mb_simple (COPY = pg_catalog.simple);
ALTER TEXT SEARCH CONFIGURATION mb_simple
    ALTER MAPPING FOR word, numword, hword, numhword, hword_part, hword_numpart
    WITH musicbrainz_unaccentdict, simple;

COMMIT;
