-- Adjust this setting to control where the objects get created.
SET search_path = public;

DROP TEXT SEARCH DICTIONARY musicbrainz_unaccentdict;

DROP TEXT SEARCH TEMPLATE musicbrainz_unaccentdict_template;

DROP FUNCTION musicbrainz_dunaccentdict_init (internal);

DROP FUNCTION musicbrainz_dunaccentdict_lexize (internal, internal, internal, internal);

DROP FUNCTION musicbrainz_unaccent (text);
