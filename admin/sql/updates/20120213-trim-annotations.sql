BEGIN;

UPDATE annotation SET text = regexp_replace(text, E'\\s+$', '') WHERE text ~ E'\\s+$';

COMMIT;
