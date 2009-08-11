BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE artist CASCADE;
TRUNCATE artist_name CASCADE;

INSERT INTO artist_name (id, name) VALUES (1, 'Name');

INSERT INTO artist (id, gid, name, sortname)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1);

COMMIT;
