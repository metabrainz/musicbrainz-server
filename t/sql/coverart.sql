SET client_min_messages TO 'warning';

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (101, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 'Artist', 'Artist');

INSERT INTO artist_credit (id, name, artist_count, gid)
    VALUES (101, 'Artist', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
    VALUES (101, 101, 'Artist', 0, '');

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 'Release #1', 101);

INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 'Release #1', 101, 1);

INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (2, '7a906020-72db-11de-8a39-0800200c9a66', 'Release #2', 101, 1);

INSERT INTO url (id, gid, url)
    VALUES (1, 'd77b3930-2925-11df-8a39-0800200c9a66',
               'http://www.archive.org/download/CoverArtsForVariousAlbum/karenkong-mulakan.jpg'),
           (2, '9413b5e0-2926-11df-8a39-0800200c9a66',
               'http://www.amazon.com/gp/product/B000W23HCY');

UPDATE link_type SET is_deprecated = FALSE WHERE id = 78;
INSERT INTO link (id, link_type) VALUES (1, 78), (2, 77);
UPDATE link_type SET is_deprecated = TRUE WHERE id = 78;

INSERT INTO l_release_url (link, entity0, entity1)
    VALUES (1, 1, 1), (2, 2, 2);
