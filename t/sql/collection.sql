BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE artist CASCADE;
TRUNCATE artist_credit CASCADE;
TRUNCATE artist_credit_name CASCADE;
TRUNCATE artist_name CASCADE;

TRUNCATE release CASCADE;
TRUNCATE release_group CASCADE;
TRUNCATE release_name CASCADE;

TRUNCATE editor CASCADE;
TRUNCATE list CASCADE;
TRUNCATE list_release CASCADE;

INSERT INTO artist_name (id, name) VALUES (1, 'Name');
INSERT INTO artist (id, gid, name, sortname)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO artist_credit (id, name, artistcount) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, joinphrase)
    VALUES (1, 1, 1, 0, NULL);

INSERT INTO release_name (id, name) VALUES (1, 'Arrival');

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 1, 1, 1),
           (2, 'a34c079d-374e-4436-9448-da92dedef3ce', 1, 1, 1),
           (3, 'b34c079d-374e-4436-9448-da92dedef3ce', 1, 1, 1),
           (4, 'c34c079d-374e-4436-9448-da92dedef3ce', 1, 1, 1);

INSERT INTO editor (id, name, password) VALUES (1, 'editor1', 'pass'), (2, 'editor2', 'pass');
INSERT INTO list (id, gid, editor, name, public) VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3cd', 1, 'collection1', FALSE), (2, 'f34c079d-374e-4436-9448-da92dedef3cb', 2, 'collection2', TRUE);

INSERT INTO list_release (list, release)
    VALUES (1, 1), (1, 3), (2, 2), (2, 4);

COMMIT;
