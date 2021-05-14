SET client_min_messages TO 'warning';

INSERT INTO artist (id, gid, name, sort_name, comment)
    VALUES (1, '5f9913b0-7219-11de-8a39-0800200c9a66', 'ABBA', 'ABBA', 'ABBA 1'),
           (2, '5f9913b0-7219-11de-8a39-0800200c9a67', 'ABBA', 'ABBA', 'ABBA 2');

INSERT INTO artist_credit (id, name, artist_count, gid)
    VALUES (1, 'ABBA', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7'),
           (2, 'ABBA', 2, 'c44109ce-57d7-3691-84c8-37926e3d41d2');
INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
    VALUES (1, 0, 1, 'ABBA', ''), (2, 0, 2, 'ABBA', '');

INSERT INTO recording (id, gid, name, artist_credit) VALUES
    (1, '745c079d-374e-4436-9448-da92dedef3ce', 'Dancing Queen', 1),
    (2, '845c079d-374e-4436-9448-da92dedef3ce', 'Test', 1),
    (3, '7c43d625-c41f-46f4-ace4-6997b34c9b73', 'Test', 1);

INSERT INTO isrc (id, recording, isrc) VALUES
    (1, 1, 'DEE250800230'),
    (2, 2, 'DEE250800230'),
    (3, 2, 'DEE250800231');


