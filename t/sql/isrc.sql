SET client_min_messages TO 'warning';

INSERT INTO artist_name (id, name) VALUES (1, 'ABBA');
INSERT INTO artist (id, gid, name, sort_name, comment)
    VALUES (1, '5f9913b0-7219-11de-8a39-0800200c9a66', 1, 1, 'ABBA 1'),
           (2, '5f9913b0-7219-11de-8a39-0800200c9a67', 1, 1, 'ABBA 2');

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1), (2, 1, 2);
INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
    VALUES (1, 0, 1, 1, ''), (2, 0, 2, 1, '');

INSERT INTO track_name (id, name) VALUES (1, 'Dancing Queen'), (2, 'Test');

INSERT INTO recording (id, gid, name, artist_credit) VALUES
    (1, '745c079d-374e-4436-9448-da92dedef3ce', 1, 1),
    (2, '845c079d-374e-4436-9448-da92dedef3ce', 2, 1),
    (3, '7c43d625-c41f-46f4-ace4-6997b34c9b73', 2, 1);

INSERT INTO isrc (id, recording, isrc) VALUES
    (1, 1, 'DEE250800230'),
    (2, 2, 'DEE250800230'),
    (3, 2, 'DEE250800231');


