-- Adjust this setting to control where the objects get created.
SET search_path = public;

DROP TEXT SEARCH DICTIONARY unaccentdict;

DROP TEXT SEARCH TEMPLATE unaccentdict_template;

DROP FUNCTION dunaccentdict_init (internal);

DROP FUNCTION dunaccentdict_lexize (internal, internal, internal, internal);

DROP FUNCTION unaccent (text);
