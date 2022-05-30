SET client_min_messages TO 'warning';

INSERT INTO artist (id, gid, name, sort_name) VALUES
    (3, '945c079d-374e-4436-9448-da92dedef3cf', 'Artist 1', 'Artist 1'),
    (4, '75a40343-ff6e-45d6-a5d2-110388d34858', 'Artist 2', 'Artist 2'),
    (5, '15a40343-ff6e-45d6-a5d2-110388d34858', 'Artist 3', 'Artist 3');

INSERT INTO artist_credit (id, name, artist_count, gid)
    VALUES (1, 'Artist 1', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');
INSERT INTO artist_credit_name (artist_credit, position, artist, join_phrase, name)
    VALUES (1, 0, 3, '', 'Artist 1');

INSERT INTO event (id, gid, name, type)
    VALUES (1, 'ea8415d8-46d1-44aa-8230-5faebd48578b', 'Kool Koncert', 1);

INSERT INTO link (id, link_type, attribute_count) VALUES (1, 103, 1);
INSERT INTO link (id, link_type, attribute_count) VALUES (2, 104, 0);
INSERT INTO link (id, link_type, attribute_count) VALUES (3, 798, 1);
INSERT INTO link (id, link_type, attribute_count) VALUES (4, 77, 0);
INSERT INTO link_attribute (link, attribute_type) VALUES (1, 1);
INSERT INTO link_attribute (link, attribute_type) VALUES (3, 830);
INSERT INTO link_attribute_text_value (link, attribute_type, text_value) VALUES (3, 830, 'tv1');

INSERT INTO l_artist_artist (id, link, entity0, entity1) VALUES (1, 1, 3, 4);
INSERT INTO l_artist_artist (id, link, entity0, entity1) VALUES (2, 2, 3, 4);
INSERT INTO l_artist_event (id, link, entity0, entity1) VALUES (1, 3, 3, 1);

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 'Arrival', 1);

INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (1, '7a906020-72db-11de-8a39-0800200c9a66', 'Arrival', 1, 1),
           (2, '7a906020-72db-11de-8a39-0800200c9a67', 'Arrival', 1, 1);

INSERT INTO url (id, gid, url)
     VALUES (263685, 'ee45a093-1114-4481-b3cc-8cd22cad20d8', 'https://www.amazon.com/gp/product/B00005CDNG');

INSERT INTO l_release_url (id, link, entity0, entity1) VALUES (1, 4, 2, 263685);

UPDATE release_meta SET amazon_asin = 'B00005CDNG' WHERE id = 2;
