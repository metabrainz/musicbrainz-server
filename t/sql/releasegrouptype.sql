BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE release_group_type CASCADE;

INSERT INTO release_group_type (id, name) VALUES (1, 'Album'), (2, 'Single');

COMMIT;
