BEGIN;
SET client_min_messages TO 'WARNING';

TRUNCATE release_group_type CASCADE;
TRUNCATE release_status CASCADE;

INSERT INTO release_group_type (id, name)
    VALUES (1, 'Album'), (2, 'Single');

INSERT INTO release_status (id, name)
    VALUES (1, 'Official');

COMMIT;
