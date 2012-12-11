INSERT INTO artist_name (id, name) VALUES (1, 'Artist');

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
    VALUES (1, 0, 1, 1, '');

INSERT INTO tracklist (id) VALUES (1);

INSERT INTO track_name (id, name) VALUES (1, 'First Track');
INSERT INTO track_name (id, name) VALUES (2, 'Second Track');
INSERT INTO track_name (id, name) VALUES (3, 'Third Track');

INSERT INTO recording (id, gid, name, artist_credit, length)
    VALUES (1, '54b9d183-7dab-42ba-94a3-7388a66604b8', 1, 1, 293720),
           (2, '659f405b-b4ee-4033-868a-0daa27784b89', 2, 1, 369680),
           (3, 'ae674299-2824-4500-9516-653ac1bc6f80', 3, 1, 258839);

INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (1, 1, 1, 1, 1, 1, 1, 293720);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (2, 1, 2, 2, 2, 2, 1, 369680);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (3, 1, 3, 3, 3, 3, 1, 258839);

ALTER SEQUENCE track_name_id_seq RESTART 4;
ALTER SEQUENCE track_id_seq RESTART 4;
ALTER SEQUENCE recording_id_seq RESTART 4;
