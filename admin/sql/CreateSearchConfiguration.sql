\set ON_ERROR_STOP 1

SET search_path = musicbrainz, public;

BEGIN;

CREATE TEXT SEARCH CONFIGURATION mb_simple (COPY = pg_catalog.simple);
ALTER TEXT SEARCH CONFIGURATION mb_simple
    ALTER MAPPING FOR word, numword, hword, numhword, hword_part, hword_numpart
    WITH musicbrainz_unaccentdict, simple;

COMMIT;
