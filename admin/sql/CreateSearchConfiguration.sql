\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE FUNCTION unaccent (text) RETURNS text
    AS '$libdir/musicbrainz_unaccent'
    LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION dunaccentdict_init(internal)
    RETURNS internal
    AS '$libdir/musicbrainz_unaccent'
    LANGUAGE C STRICT;

CREATE OR REPLACE FUNCTION dunaccentdict_lexize(internal, internal, internal, internal)
    RETURNS internal
    AS '$libdir/musicbrainz_unaccent'
    LANGUAGE C STRICT;

CREATE TEXT SEARCH TEMPLATE unaccentdict_template (
    LEXIZE = dunaccentdict_lexize,
    INIT   = dunaccentdict_init
);

CREATE TEXT SEARCH DICTIONARY unaccentdict (
    TEMPLATE = unaccentdict_template
);

COMMENT ON TEXT SEARCH DICTIONARY unaccentdict IS 'unaccenting dictionary';

CREATE TEXT SEARCH CONFIGURATION mb_simple (COPY = pg_catalog.simple);
ALTER TEXT SEARCH CONFIGURATION mb_simple
    ALTER MAPPING FOR word, numword, hword, numhword, hword_part, hword_numpart
    WITH unaccentdict, simple;

COMMIT;
