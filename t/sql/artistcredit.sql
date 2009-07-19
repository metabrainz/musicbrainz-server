BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE artist CASCADE;
TRUNCATE artist_name CASCADE;
TRUNCATE artist_credit CASCADE;
TRUNCATE artist_credit_name CASCADE;

INSERT INTO artist_name (id, name) VALUES (1, 'Queen');
INSERT INTO artist_name (id, name) VALUES (2, 'David Bowie');
INSERT INTO artist_name (id, name) VALUES (3, 'Merge');

INSERT INTO artist (id, gid, name, sortname)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1);

INSERT INTO artist (id, gid, name, sortname)
    VALUES (2, '5441c29d-3602-4898-b1a1-b77fa23b8e50', 2, 2);

INSERT INTO artist (id, gid, name, sortname)
    VALUES (3, '5f9913b0-7219-11de-8a39-0800200c9a66', 3, 3);

INSERT INTO artist_credit (id, artistcount) VALUES (1, 2);

INSERT INTO artist_credit_name (artist_credit, position, artist, name, joinphrase)
    VALUES (1, 0, 1, 1, ' & ');

INSERT INTO artist_credit_name (artist_credit, position, artist, name, joinphrase)
    VALUES (1, 1, 2, 2, NULL);

ALTER SEQUENCE artist_name_id_seq RESTART 4;
ALTER SEQUENCE artist_credit_id_seq RESTART 2;

COMMIT;
