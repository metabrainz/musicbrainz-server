-- This patch needs to be run against the old unaccent libs

\set ON_ERROR_STOP 1

BEGIN;
-- Drop the old functions
DROP TEXT SEARCH CONFIGURATION IF EXISTS mb_simple CASCADE;
DROP TEXT SEARCH DICTIONARY IF EXISTS unaccentdict CASCADE;
DROP TEXT SEARCH TEMPLATE IF EXISTS unaccentdict_template CASCADE;
DROP FUNCTION dunaccentdict_init (internal);
DROP FUNCTION dunaccentdict_lexize (internal, internal, internal, internal);
DROP FUNCTION unaccent (text);

COMMIT;
