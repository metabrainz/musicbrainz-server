INSERT INTO artist_name (id, name)
    VALUES (1, 'Bob & Tom'), (2, 'Bob'), (3, 'Tom');

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (5, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1),
           (6, '5441c29d-3602-4898-b1a1-b77fa23b8e50', 2, 2),
           (7, '5f9913b0-7219-11de-8a39-0800200c9a66', 3, 3);

INSERT INTO artist_credit (id, artist_count, name) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, position, artist, join_phrase, name)
    VALUES (1, 0, 5, '', 1);

INSERT INTO release_name (id, name) VALUES (1, 'Release');
INSERT INTO track_name (id, name) VALUES (1, 'Track');

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1);
INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1, 1);
INSERT INTO recording (id, gid, name, artist_credit)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1);
INSERT INTO tracklist (id) VALUES (1);
INSERT INTO track (id, name, artist_credit, recording, tracklist, position, number)
    VALUES (1, 1, 1, 1, 1, 1, 1);

ALTER SEQUENCE artist_name_id_seq RESTART 4;
ALTER SEQUENCE artist_credit_id_seq RESTART 8;
