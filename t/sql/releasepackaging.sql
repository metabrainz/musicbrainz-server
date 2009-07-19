BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE release_packaging CASCADE;
INSERT INTO release_packaging (id, name) VALUES (1, 'Jewel Case');

COMMIT;
