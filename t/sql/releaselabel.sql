SET client_min_messages TO 'warning';

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 'Name', 'Name');

INSERT INTO artist_credit (id, name, artist_count, gid)
    VALUES (1, 'Name', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
    VALUES (1, 1, 'Name', 0, '');

INSERT INTO release_group (id, gid, name, artist_credit, type, comment, edits_pending)
    VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 'Arrival', 1, 1, 'Comment', 2);

INSERT INTO release (id, gid, name, artist_credit, release_group) VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 'Arrival', 1, 1);
INSERT INTO release_unknown_country (release, date_year, date_month, date_day) VALUES (1, 2008, null, null);
;

INSERT INTO release (id, gid, name, artist_credit, release_group) VALUES (2, '7a906020-72db-11de-8a39-0800200c9a66', 'Release #2', 1, 1);
INSERT INTO release_unknown_country (release, date_year, date_month, date_day) VALUES (2, 2009, null, null);
;

INSERT INTO release (id, gid, name, artist_credit, release_group) VALUES (3, 'f23286b0-72dd-11de-8a39-0800200c9a66', 'Arrival', 1, 1);
INSERT INTO release_unknown_country (release, date_year, date_month, date_day) VALUES (3, 2006, null, null);
;

INSERT INTO release (id, gid, name, artist_credit, release_group) VALUES (4, 'f8a056d0-72dd-11de-8a39-0800200c9a66', 'Release #2', 1, 1);
INSERT INTO release_unknown_country (release, date_year, date_month, date_day) VALUES (4, 2007, null, null);
;

INSERT INTO label (id, gid, name) VALUES (1, '00a23bd0-72db-11de-8a39-0800200c9a66', 'Label');

INSERT INTO release_label (id, release, label, catalog_number)
    VALUES (1, 1, 1, 'ABC-123'),
           (2, 1, 1, 'ABC-123-X'),
           (3, 3, 1, '343 960 2'),
           (4, 4, 1, '82796 97772 2');


