
SET client_min_messages TO 'warning';








INSERT INTO artist_name (id, name) VALUES (1, 'Artist');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '32552f80-755f-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, name, artist, position, join_phrase)
    VALUES (1, 1, 1, 0, '');

INSERT INTO track_name (id, name) VALUES (1, 'Traits (remix)');
INSERT INTO recording (id, gid, name, artist_credit) VALUES (1, '581556f0-755f-11de-8a39-0800200c9a66', 1, 1);

ALTER SEQUENCE track_name_id_seq RESTART 2;


