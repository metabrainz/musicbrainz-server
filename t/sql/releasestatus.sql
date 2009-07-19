BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE release_status CASCADE;
INSERT INTO release_status (id, name) VALUES (1, 'Official');

COMMIT;
