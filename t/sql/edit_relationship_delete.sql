SET client_min_messages TO 'warning';

INSERT INTO artist (id, gid, name, sort_name, comment) VALUES
    (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Name', 'Name', 'Artist 1'),
    (2, '75a40343-ff6e-45d6-a5d2-110388d34858', 'Name', 'Name', 'Artist 2');

INSERT INTO url (id, gid, url) VALUES
    (1, '67ff507e-1239-40a7-9023-53621d701797', 'http://en.wikipedia.org/wiki/Artist1');

INSERT INTO link_type (id, gid, entity_type0, entity_type1, name, link_phrase, reverse_link_phrase, long_link_phrase)
    VALUES (1, '7610b0e9-40c1-48b3-b06c-2c1d30d9dc3e', 'artist', 'artist', 'member', 'foo', 'oof', 'f'),
           (2, '110ef46e-c947-4224-b12a-ed4e0b6a33e1', 'artist', 'url', 'wiki', 'wiki', 'wiki', 'wiki');

INSERT INTO link (id, link_type, attribute_count) VALUES (1, 1, 0), (2, 2, 0);

INSERT INTO l_artist_artist (id, link, entity0, entity1) VALUES (1, 1, 1, 2);

INSERT INTO l_artist_url (id, link, entity0, entity1) VALUES (1, 2, 1, 1);
