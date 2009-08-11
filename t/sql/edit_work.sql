BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE artist CASCADE;
TRUNCATE artist_name CASCADE;
TRUNCATE artist_credit CASCADE;
TRUNCATE artist_credit_name CASCADE;
TRUNCATE work_name CASCADE;
TRUNCATE work CASCADE;
TRUNCATE work_type CASCADE;

INSERT INTO artist_name (id, name) VALUES (1, 'Artist');
INSERT INTO artist (id, gid, name, sortname)
    VALUES (1, '32552f80-755f-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO artist_credit (id, artistcount) VALUES (1, 1);
INSERT INTO artist_credit_name (artist_credit, name, artist, position, joinphrase)
    VALUES (1, 1, 1, 0, NULL);

INSERT INTO work_type (id, name) VALUES (1, 'Remix');
INSERT INTO work_name (id, name) VALUES (1, 'Traits (remix)');
INSERT INTO work (id, gid, name, artist_credit) VALUES (1, '581556f0-755f-11de-8a39-0800200c9a66', 1, 1);

ALTER SEQUENCE work_name_id_seq RESTART 2;

COMMIT;
