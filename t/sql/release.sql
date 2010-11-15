BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE annotation CASCADE;
TRUNCATE artist CASCADE;
TRUNCATE artist_credit CASCADE;
TRUNCATE artist_credit_name CASCADE;
TRUNCATE artist_name CASCADE;
TRUNCATE country CASCADE;
TRUNCATE editor CASCADE;
TRUNCATE label_name CASCADE;
TRUNCATE label CASCADE;
TRUNCATE language CASCADE;
TRUNCATE recording CASCADE;
TRUNCATE release CASCADE;
TRUNCATE release_annotation CASCADE;
TRUNCATE release_gid_redirect CASCADE;
TRUNCATE release_group CASCADE;
TRUNCATE release_group_type CASCADE;
TRUNCATE release_label CASCADE;
TRUNCATE release_name CASCADE;
TRUNCATE release_packaging CASCADE;
TRUNCATE release_status CASCADE;
TRUNCATE track_name CASCADE;
TRUNCATE track CASCADE;
TRUNCATE tracklist CASCADE;
TRUNCATE medium CASCADE;
TRUNCATE script CASCADE;

INSERT INTO artist_name (id, name) VALUES (1, 'Name');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
    VALUES (1, 1, 1, 0, NULL);

INSERT INTO release_name (id, name) VALUES (1, 'Arrival');
INSERT INTO release_name (id, name) VALUES (2, 'Release #2');

INSERT INTO release_status (id, name) VALUES (1, 'Official');
INSERT INTO release_packaging (id, name) VALUES (1, 'Jewel Case');
INSERT INTO country (id, iso_code, name) VALUES (1, 'GB', 'United Kingdom');
INSERT INTO script (id, iso_code, isonumber, name) VALUES (1, 'Ugar', '040', 'Ugaritic');
INSERT INTO language (id, iso_code_3t, iso_code_3b, iso_code_2, name)
    VALUES (1, 'deu', 'ger', 'de', 'German');

INSERT INTO release_group_type (id, name) VALUES (1, 'Album');
INSERT INTO release_group (id, gid, name, artist_credit, type, comment, edits_pending)
    VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 1, 1, 1, 'Comment', 2);

INSERT INTO release (id, gid, name, artist_credit, release_group, status, packaging, country,
        language, script, date_year, date_month, date_day, barcode, comment, edits_pending)
    VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 1, 1, 1, 1, 1, 1, 1, 1,
        2009, 5, 8, '731453398122', 'Comment', 2);

INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (2, '7a906020-72db-11de-8a39-0800200c9a66', 2, 1, 1);

INSERT INTO label_name (id, name) VALUES (1, 'Label');
INSERT INTO label (id, gid, name, sort_name) VALUES (1, '00a23bd0-72db-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO release_label (id, release, label, catalog_number)
    VALUES (1, 1, 1, 'ABC-123'), (2, 1, 1, 'ABC-123-X');

INSERT INTO editor (id, name, password) VALUES (1, 'editor', 'pass');
INSERT INTO annotation (id, editor, text, changelog) VALUES (1, 1, 'Annotation', 'change');
INSERT INTO release_annotation (release, annotation) VALUES (1, 1);

INSERT INTO release_gid_redirect (gid, new_id) VALUES ('71dc55d8-0fc6-41c1-94e0-85ff2404997d', 1);

INSERT INTO artist_name (id, name) VALUES (2, 'Various Artists');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (2, '7a906020-72db-11de-8a39-0800200c9a66', 2, 2);
INSERT INTO artist_credit (id, name, artist_count) VALUES (2, 2, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase) VALUES (2, 2, 2, 1, NULL);

INSERT INTO release_name (id, name) VALUES (3, 'Various Release');
INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (2, '25b6fe30-ff5b-11de-8a39-0800200c9a66', 3, 2);
INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (3, '25b6fe30-ff5b-11de-8a39-0800200c9a66', 3, 2, 2);

INSERT INTO track_name (id, name) VALUES (1, 'Track on recording');
INSERT INTO tracklist (id, track_count) VALUES (1, 1);
INSERT INTO medium (id, tracklist, release, position) VALUES (1, 1, 3, 1);
INSERT INTO recording (id, artist_credit, name, gid)
    VALUES (1, 2, 1, 'b43eb990-ff5b-11de-8a39-0800200c9a66');
INSERT INTO track (id, name, artist_credit, tracklist, position, recording)
    VALUES (1, 1, 1, 1, 1, 1);

-- test search ranking.
INSERT INTO release_name (id, name) VALUES (4, 'Blues on Blonde on Blonde');
INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (3, 'ac9a0149-5bb7-3fec-b6ac-16eaa529a28c', 4, 2);
INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (4, '6ef989ad-0158-4bbf-b446-c863d50cd6b6', 4, 2, 3);

INSERT INTO release_name (id, name) VALUES (5, 'Blonde on Blonde');
INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (4, '329fb554-2a81-3d8a-8e22-ec2c66810019', 5, 2);
INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (5, '538aff00-a009-4515-a064-11a6d5a502ee', 5, 2, 3);

-- test merge strategies
INSERT INTO release_name (id, name)
    VALUES (6, 'The Prologue (disc 1)'), (7, 'The Prologue (disc 2)'),
           (8, 'Subversion EP (disc 1)'), (9, 'Subversion EP (disc 2)');
INSERT INTO release (id, gid, name, release_group, artist_credit)
    VALUES (6, '7a906020-72db-11de-8a39-0800200c9a70', 6, 1, 1),
           (7, '7a906020-72db-11de-8a39-0800200c9a71', 7, 1, 1),
           (8, '7a906020-72db-11de-8a39-0800200c9a72', 8, 1, 1),
           (9, '7a906020-72db-11de-8a39-0800200c9a73', 9, 1, 1);
INSERT INTO tracklist (id, trackcount) VALUES (2, 1), (3, 1), (4, 1), (5, 1);
INSERT INTO recording (id, gid, name, artist_credit)
    VALUES (2, '50a772b0-f0cc-11df-98cf-0800200c9a66', 1, 1),
           (3, '5d9cb570-f0cc-11df-98cf-0800200c9a66', 1, 1),
           (4, '64cac850-f0cc-11df-98cf-0800200c9a66', 1, 1),
           (5, '691ee030-f0cc-11df-98cf-0800200c9a66', 1, 1);
INSERT INTO track (id, name, artist_credit, tracklist, position, recording)
    VALUES (2, 1, 1, 2, 1, 2), (3, 1, 1, 3, 1, 3),
           (4, 1, 1, 5, 1, 4), (5, 1, 1, 5, 1, 5);
INSERT INTO medium (id, release, tracklist, position)
    VALUES (2, 6, 2, 1), (3, 7, 3, 1),
           (4, 8, 4, 1), (5, 8, 5, 1);

ALTER SEQUENCE release_name_id_seq RESTART 10;
ALTER SEQUENCE release_group_id_seq RESTART 5;
ALTER SEQUENCE release_id_seq RESTART 10;

COMMIT;
