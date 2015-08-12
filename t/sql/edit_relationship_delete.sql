SET client_min_messages TO 'warning';

INSERT INTO artist (id, gid, name, sort_name, comment) VALUES
    (3, '945c079d-374e-4436-9448-da92dedef3cf', 'Name', 'Name', 'Artist 1'),
    (4, '75a40343-ff6e-45d6-a5d2-110388d34858', 'Name', 'Name', 'Artist 2');

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 'Artist 1', 1);

INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
    VALUES (1, 3, 'Artist 1', 0, '');

INSERT INTO url (id, gid, url) VALUES
    (1, '67ff507e-1239-40a7-9023-53621d701797', 'http://en.wikipedia.org/wiki/Artist1'),
    (2, 'a803cfdd-b08f-4f51-893c-0784bb74a497', 'http://en.wikipedia.org/wiki/Release1');

INSERT INTO link_type (id, gid, entity_type0, entity_type1, name, link_phrase, reverse_link_phrase, long_link_phrase)
    VALUES (1, '7610b0e9-40c1-48b3-b06c-2c1d30d9dc3e', 'artist', 'artist', 'member', 'foo', 'oof', 'f'),
           (2, '110ef46e-c947-4224-b12a-ed4e0b6a33e1', 'artist', 'url', 'wiki', 'wiki', 'wiki', 'wiki'),
           (3, '5750a8f5-6ec6-403d-9e4d-14ea4dec9633', 'release', 'url', 'wiki', 'wiki', 'wiki', 'wiki');

INSERT INTO link (id, link_type, attribute_count) VALUES (1, 1, 0), (2, 2, 0), (3, 3, 0);

INSERT INTO l_artist_artist (id, link, entity0, entity1) VALUES (1, 1, 3, 4);

INSERT INTO l_artist_url (id, link, entity0, entity1) VALUES (1, 2, 3, 1);

INSERT INTO release_group (id, gid, name, artist_credit, type, comment, edits_pending)
    VALUES (1, '1466a797-4481-4699-be0f-468e1f009669', 'Release Group 1', 1, 1, '', 0);

INSERT INTO release (id, gid, name, artist_credit, release_group, status, packaging, language, script, barcode, comment, edits_pending)
    VALUES (1, '80181f27-52f6-4dbd-a48b-83d64872e793', 'Release 1', 1, 1, NULL, NULL, NULL, NULL, '', '', 0);

INSERT INTO l_release_url (id, link, entity0, entity1) VALUES (1, 3, 1, 2);
