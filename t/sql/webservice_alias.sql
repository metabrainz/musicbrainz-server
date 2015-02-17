INSERT INTO instrument_alias_type (id, name) VALUES (1, 'Instrument name');

UPDATE instrument_alias SET type = 1, locale = 'fr', primary_for_locale = '1' WHERE id = 1;
