BEGIN;
SET client_min_messages TO 'WARNING';

TRUNCATE edit CASCADE;
TRUNCATE edit_label CASCADE;
TRUNCATE vote CASCADE;

SELECT setval('edit_id_seq', 99);

COMMIT;
