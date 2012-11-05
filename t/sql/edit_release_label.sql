SET client_min_messages TO 'warning';

INSERT INTO artist_name (id, name) VALUES (1, 'Name');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
    VALUES (1, 1, 1, 0, '');

INSERT INTO label_name (id, name) VALUES (1, 'Label');
INSERT INTO label (id, gid, name, sort_name, comment)
    VALUES (1, 'f2a9a3c0-72e3-11de-8a39-0800200c9a66', 1, 1, 'Label 1'),
           (2, '7214c460-97d7-11de-8a39-0800200c9a66', 1, 1, 'Label 2');

INSERT INTO release_name (id, name) VALUES (1, 'Release #1');
INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 1, 1, 1);

INSERT INTO release_label (id, release, label, catalog_number)
    VALUES (1, 1, 1, 'ABC-123');

ALTER SEQUENCE release_label_id_seq RESTART 2;


