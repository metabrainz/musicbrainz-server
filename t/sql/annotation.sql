BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE artist CASCADE;
TRUNCATE artist_credit CASCADE;
TRUNCATE artist_credit_name CASCADE;
TRUNCATE artist_name CASCADE;
TRUNCATE editor CASCADE;
TRUNCATE label CASCADE;
TRUNCATE label_name CASCADE;
TRUNCATE recording CASCADE;
TRUNCATE release CASCADE;
TRUNCATE release_group CASCADE;
TRUNCATE release_name CASCADE;
TRUNCATE track_name CASCADE;
TRUNCATE work_name CASCADE;
TRUNCATE work CASCADE;

TRUNCATE artist_annotation CASCADE;
TRUNCATE label_annotation CASCADE;
TRUNCATE recording_annotation CASCADE;
TRUNCATE release_annotation CASCADE;

INSERT INTO artist_name (id, name) VALUES (1, 'Artist Name');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '745c079d-374e-4436-9448-da92dedef3ce', 1, 1);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, name, position, artist, join_phrase)
    VALUES (1, 1, 1, 1, NULL);

INSERT INTO label_name (id, name) VALUES (1, 'Label Name');
INSERT INTO label (id, gid, name, sort_name)
    VALUES (1, '56a40160-8ff2-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO track_name (id, name) VALUES (1, 'Recording Name');
INSERT INTO recording (id, gid, name, artist_credit)
    VALUES (1, 'e4919fa0-8ff2-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO release_name (id, name) VALUES (1, 'Release Name');
INSERT INTO release_name (id, name) VALUES (2, 'Release Group Name');

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, 'ca10b110-8ff3-11de-8a39-0800200c9a66', 2, 1);

INSERT INTO release (id, gid, name, release_group, artist_credit)
    VALUES (1, 'e4919fa0-8ff2-11de-8a39-0800200c9a66', 1, 1, 1);

INSERT INTO work_name (id, name) VALUES (1, 'Work Name');
INSERT INTO work (id, gid, name, artist_credit)
    VALUES (1, 'b0c3aea0-8ff4-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO editor (id, name, password) VALUES (1, 'editor', 'pass');

COMMIT;
