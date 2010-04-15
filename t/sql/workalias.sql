BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE artist CASCADE;
TRUNCATE artist_credit CASCADE;
TRUNCATE artist_credit_name CASCADE;
TRUNCATE artist_name CASCADE;
TRUNCATE work CASCADE;
TRUNCATE work_name CASCADE;
TRUNCATE work_alias CASCADE;

INSERT INTO artist_name (id, name) VALUES (1, 'Name');
INSERT INTO artist (id, gid, name, sortname)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO artist_credit (id, name, artistcount) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, joinphrase)
    VALUES (1, 1, 1, 0, NULL);

INSERT INTO work_name (id, name) VALUES (1, 'Name');
INSERT INTO work_name (id, name) VALUES (2, 'Empty Work');
INSERT INTO work_name (id, name) VALUES (3, 'Alias 1');
INSERT INTO work_name (id, name) VALUES (4, 'Alias 2');

INSERT INTO work (id, gid, name, artist_credit)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1);

INSERT INTO work (id, gid, name, artist_credit)
    VALUES (2, '73371ea0-7217-11de-8a39-0800200c9a66', 2, 1);

INSERT INTO work (id, gid, name, artist_credit)
    VALUES (3, '686cdcc0-7218-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO work_alias (id, work, name) VALUES (1, 1, 3);
INSERT INTO work_alias (id, work, name, locale) VALUES (2, 1, 4, 'en_GB');
INSERT INTO work_alias (id, work, name) VALUES (3, 3, 4);

ALTER SEQUENCE work_name_id_seq RESTART 5;
ALTER SEQUENCE work_alias_id_seq RESTART 4;

COMMIT;
