
BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE artist CASCADE;
TRUNCATE artist_name CASCADE;
TRUNCATE artist_credit CASCADE;
TRUNCATE artist_credit_name CASCADE;
TRUNCATE release_group CASCADE;
TRUNCATE release_name CASCADE;
TRUNCATE release_group_type CASCADE;

INSERT INTO artist_name (id, name) VALUES (1, 'Name');
INSERT INTO artist (id, gid, name, sortname)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO artist_credit (id, artistcount) VALUES (1, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, joinphrase)
    VALUES (1, 1, 1, 0, NULL);

INSERT INTO release_name (id, name) VALUES (1, 'Release Name');
INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, '018acbc0-803c-11de-8a39-0800200c9a66', 1, 1),
           (2, 'ddc18390-8041-11de-8a39-0800200c9a66', 1, 1);

COMMIT;
