BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE script CASCADE;
INSERT INTO script (id, iso_code, iso_number, name)
    VALUES (1, 'Ugar', '040', 'Ugaritic');

COMMIT;
