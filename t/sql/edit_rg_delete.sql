
SET client_min_messages TO 'warning';









INSERT INTO artist_name (id, name) VALUES (1, 'Name');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
    VALUES (1, 1, 1, 0, '');

INSERT INTO release_name (id, name) VALUES (1, 'Release Name');
INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, '018acbc0-803c-11de-8a39-0800200c9a66', 1, 1);

ALTER SEQUENCE artist_credit_id_seq RESTART 2;
ALTER SEQUENCE artist_name_id_seq RESTART 2;
ALTER SEQUENCE release_name_id_seq RESTART 2;


