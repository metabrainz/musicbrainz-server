
SET client_min_messages TO 'warning';

INSERT INTO artist_name (id, name) VALUES (1, 'Nintendo');
INSERT INTO artist_name (id, name) VALUES (2, 'Kazuki Muraoka');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '05e536dd-abaa-4e87-b9c0-678eb59c38c8', 1, 1),
           (2, '01087db5-fee3-4b9f-a3db-2eefd9cf79ec', 2, 2);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, position, name, artist) VALUES (1, 1, 1, 1);

INSERT INTO release_name (id, name) VALUES (1, 'Best of Nintendo Music, Volume 1');
INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, 'c610726e-0494-3a82-8439-7672b5f4557a', 1, 1);

INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (1, '90ae08e0-dba1-4d33-8b92-ba824e7881f4', 1, 1, 1);

INSERT INTO tracklist (id, track_count) VALUES (1, 1);
INSERT INTO medium (id, tracklist, release, position, name)
    VALUES (1, 1, 1, 1, '');

INSERT INTO medium_format (id, name) VALUES (1, 'Digital Media');

INSERT INTO track_name (id, name) VALUES (1, 'Metal Gear; Ending');
INSERT INTO recording (id, gid, name, artist_credit)
    VALUES (1, 'f92f82a1-c3ea-405a-b61e-872206d25ba6', 1, 1);
INSERT INTO track (id, recording, position, number, name, artist_credit, tracklist)
    VALUES (1, 1, 1, '1', 1, 1, 1);

ALTER SEQUENCE artist_id_seq RESTART 100;
ALTER SEQUENCE artist_credit_id_seq RESTART 100;
ALTER SEQUENCE artist_name_id_seq RESTART 100;

ALTER SEQUENCE track_id_seq RESTART 100;
ALTER SEQUENCE track_name_id_seq RESTART 100;
ALTER SEQUENCE tracklist_id_seq RESTART 100;
ALTER SEQUENCE recording_id_seq RESTART 100;

