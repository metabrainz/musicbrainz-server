BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE script CASCADE;
INSERT INTO script (id, isocode, isonumber, name)
    VALUES (1, 'Ugar', '040', 'Ugaritic');

COMMIT;
