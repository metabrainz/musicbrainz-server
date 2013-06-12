SET client_min_messages TO 'warning';

INSERT INTO artist_name (id, name) VALUES (1, 'Name');

INSERT INTO artist (id, gid, name, sort_name, comment) VALUES
    (1, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1, 'Artist 1'),
    (2, '75a40343-ff6e-45d6-a5d2-110388d34858', 1, 1, 'Artist 2');

INSERT INTO link_type (id, gid, entity_type0, entity_type1, name, link_phrase, reverse_link_phrase, long_link_phrase)
    VALUES (1, '7610b0e9-40c1-48b3-b06c-2c1d30d9dc3e', 'artist', 'artist', 'member',
            'foo', 'oof', 'f');

INSERT INTO link (id, link_type, attribute_count) VALUES (1, 1, 0);

INSERT INTO l_artist_artist (id, link, entity0, entity1) VALUES (1, 1, 1, 2);


