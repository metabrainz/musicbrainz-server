BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE language CASCADE;
INSERT INTO language (id, isocode_3t, isocode_3b, isocode_2, name)
    VALUES (1, 'deu', 'ger', 'de', 'German');

COMMIT;
