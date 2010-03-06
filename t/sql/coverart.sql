BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE artist CASCADE;
TRUNCATE artist_credit CASCADE;
TRUNCATE artist_credit_name CASCADE;
TRUNCATE artist_name CASCADE;
TRUNCATE release CASCADE;
TRUNCATE release_group CASCADE;
TRUNCATE release_name CASCADE;
TRUNCATE url CASCADE;
TRUNCATE l_release_url CASCADE;
TRUNCATE link_type CASCADE;

INSERT INTO artist_name (id, name) VALUES (1, 'Artist');
INSERT INTO artist (id, gid, name, sortname)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO artist_credit (id, name, artistcount) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, joinphrase)
    VALUES (1, 1, 1, 0, NULL);

INSERT INTO release_name (id, name) VALUES (1, 'Release #1');
INSERT INTO release_name (id, name) VALUES (2, 'Release #2');

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 1, 1, 1);

INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (2, '7a906020-72db-11de-8a39-0800200c9a66', 2, 1, 1);

INSERT INTO url (id, gid, url)
    VALUES (1, 'd77b3930-2925-11df-8a39-0800200c9a66',
               'http://www.archive.org/download/CoverArtsForVariousAlbum/karenkong-mulakan.jpg'),
           (2, '9413b5e0-2926-11df-8a39-0800200c9a66',
               'http://www.amazon.com/gp/product/B000W23HCY');

INSERT INTO link_type (id, gid, name, linkphrase, rlinkphrase, shortlinkphrase)
    VALUES (1, '6538e340-2925-11df-8a39-0800200c9a66', 'cover art link', 'has coverart at', 'provides coverart for', 'coverart'),
           (2, '6d47b930-2925-11df-8a39-0800200c9a66', 'amazon asin', 'has amazon asin', 'is an amazon asin for', 'asin');

INSERT INTO link (id, link_type) VALUES (1, 1), (2, 2);

INSERT INTO l_release_url (link, entity0, entity1)
    VALUES (1, 1, 1), (2, 2, 2);

COMMIT;
