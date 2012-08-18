
SET client_min_messages TO 'warning';

INSERT INTO artist_name (id, name) VALUES (1, 'Name');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
    VALUES (1, 1, 1, 0, NULL);

INSERT INTO release_name (id, name) VALUES (1, 'Arrival');

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 1, 1, 1),
           (2, 'a34c079d-374e-4436-9448-da92dedef3ce', 1, 1, 1),
           (3, 'b34c079d-374e-4436-9448-da92dedef3ce', 1, 1, 1),
           (4, 'c34c079d-374e-4436-9448-da92dedef3ce', 1, 1, 1);

-- Trigger on release creates a release_coverart and release_meta row, so update
UPDATE release_coverart
    SET last_updated=now(), cover_art_url='http://ecx.images-amazon.com/images/I/41KMH1VE7XL.jpg'
    WHERE id=2;

UPDATE release_meta SET date_added=now(), cover_art_presence='present' WHERE id=4;
UPDATE release_meta SET date_added=now(), cover_art_presence='absent' WHERE id=2;

INSERT INTO editor (id, name, password) VALUES (1, 'editor1', 'pass'), (2, 'editor2', 'pass'), (3, 'editor3', 'pass');
INSERT INTO editor_collection (id, gid, editor, name, public) VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3cd', 1, 'collection1', FALSE), (2, 'f34c079d-374e-4436-9448-da92dedef3cb', 2, 'collection2', TRUE);

INSERT INTO editor_collection_release (collection, release)
    VALUES (1, 1), (1, 3), (2, 2), (2, 4);

INSERT INTO edit (id, editor, type, data, status, expire_time) VALUES (1, 1, 316, '', 2, now());
INSERT INTO cover_art_archive.art_type (id, name) VALUES (1, 'Front');
INSERT INTO cover_art_archive.cover_art VALUES (1, 4, '', 1, 1, now());
INSERT INTO cover_art_archive.cover_art_type VALUES (1, 1)

