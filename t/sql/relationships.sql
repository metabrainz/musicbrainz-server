SET client_min_messages TO 'warning';

INSERT INTO link (id, link_type, attribute_count) VALUES (1, 148, 1),
                                                         (2, 148, 2),
                                                         (3, 743, 1),
                                                         (4, 148, 1);

INSERT INTO link_attribute (link, attribute_type) VALUES (1, 229),
                                                         (2, 1),
                                                         (2, 302),
                                                         (3, 788),
                                                         (4, 229);

INSERT INTO link_attribute_text_value (link, attribute_type, text_value)
    VALUES (3, 788, 'oh look a number');

INSERT INTO link_attribute_credit (link, attribute_type, credited_as)
    VALUES (4, 229, 'crazy guitar');

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'e2a083a9-9942-4d6e-b4d2-8397320b95f7', 'Artist 1', 'Artist 1'),
           (2, '2fed031c-0e89-406e-b9f0-3d192637907a', 'Artist 2', 'Artist 2');

INSERT INTO artist_credit (id, name, artist_count, gid)
    VALUES (1, 'Artist 1', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');
INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
    VALUES (1, 0, 1, 'Artist 1', '');

INSERT INTO recording (id, gid, name, artist_credit)
    VALUES (1, '99caac80-72e4-11de-8a39-0800200c9a66', 'Track 1', 1),
           (2, 'a12bb640-72e4-11de-8a39-0800200c9a66', 'Track 2', 1);

INSERT INTO l_artist_recording (id, link, entity0, entity1) VALUES (1, 1, 1, 1);
INSERT INTO l_artist_recording (id, link, entity0, entity1, edits_pending) VALUES (2, 1, 2, 1, 1);
INSERT INTO l_artist_recording (id, link, entity0, entity1) VALUES (3, 2, 1, 2);
