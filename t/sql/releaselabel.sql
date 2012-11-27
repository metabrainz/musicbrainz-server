
SET client_min_messages TO 'warning';












INSERT INTO artist_name (id, name) VALUES (1, 'Name');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
    VALUES (1, 1, 1, 0, '');

INSERT INTO release_name (id, name) VALUES (1, 'Arrival');
INSERT INTO release_name (id, name) VALUES (2, 'Release #2');

INSERT INTO release_group (id, gid, name, artist_credit, type, comment, edits_pending)
    VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 1, 1, 1, 'Comment', 2);

INSERT INTO release (id, gid, name, artist_credit, release_group, date_year)
    VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 1, 1, 1, 2008);

INSERT INTO release (id, gid, name, artist_credit, release_group, date_year)
    VALUES (2, '7a906020-72db-11de-8a39-0800200c9a66', 2, 1, 1, 2009);

INSERT INTO release (id, gid, name, artist_credit, release_group, date_year)
    VALUES (3, 'f23286b0-72dd-11de-8a39-0800200c9a66', 1, 1, 1, 2006);

INSERT INTO release (id, gid, name, artist_credit, release_group, date_year)
    VALUES (4, 'f8a056d0-72dd-11de-8a39-0800200c9a66', 2, 1, 1, 2007);

INSERT INTO label_name (id, name) VALUES (1, 'Label');
INSERT INTO label (id, gid, name, sort_name) VALUES (1, '00a23bd0-72db-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO release_label (id, release, label, catalog_number)
    VALUES (1, 1, 1, 'ABC-123'),
           (2, 1, 1, 'ABC-123-X'),
           (3, 3, 1, '343 960 2'),
           (4, 4, 1, '82796 97772 2');


