SET client_min_messages TO 'warning';

INSERT INTO artist_name (id, name) VALUES (1, 'ABBA');
INSERT INTO artist (id, gid, name, sort_name, comment)
    VALUES (1, '5f9913b0-7219-11de-8a39-0800200c9a66', 1, 1, ''),
           (2, '5f9913b0-7219-11de-8a39-0800200c9a67', 1, 1, 'The other ABBA');

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1), (2, 1, 1);
INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
    VALUES (1, 0, 1, 1, ''), (2, 0, 2, 1, '');

INSERT INTO track_name (id, name) VALUES (1, 'Dancing Queen'), (2, 'Test');

INSERT INTO recording (id, gid, name, artist_credit) VALUES
    (1, '745c079d-374e-4436-9448-da92dedef3ce', 1, 1),
    (2, '845c079d-374e-4436-9448-da92dedef3ce', 2, 1),
    (3, '7c43d625-c41f-46f4-ace4-6997b34c9b73', 2, 1);

INSERT INTO clientversion (id, version) VALUES (1, 'mb_client/1.0');
INSERT INTO puid (id, puid, version) VALUES
    (1, 'b9c8f51f-cc9a-48fa-a415-4c91fcca80f0', 1),
    (2, '134478d1-306e-41a1-8b37-ff525e53c8be', 1),
    (3, 'be42c064-91ba-4e0d-8841-085fb9ab8b17', 1),
    (4, '5226b265-0ba5-4679-98e4-427e72b5b8cf', 1);

INSERT INTO recording_puid (id, recording, puid) VALUES
    (1, 1, 1), (2, 1, 2), (3, 2, 2), (4, 2, 3), (5, 3, 4), (6, 3, 2);


ALTER SEQUENCE recording_puid_id_seq RESTART 7;
