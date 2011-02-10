
SET client_min_messages TO 'warning';














INSERT INTO artist_name (id, name) VALUES (1, 'Artist');
INSERT INTO artist (id, gid, name, sort_name) VALUES
    (1, 'a28505a0-739d-11de-8a39-0800200c9a66', 1, 1),
    (2, '1c034cf0-73a5-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, name, artist, position, join_phrase)
    VALUES (1, 1, 1, 0, NULL);

INSERT INTO release_name (id, name) VALUES (1, 'Release');
INSERT INTO release_name (id, name) VALUES (2, 'Release Group');

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, 'f83360f0-739d-11de-8a39-0800200c9a66', 2, 1);

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (2, '9524c7e0-73a4-11de-8a39-0800200c9a66', 2, 1);

INSERT INTO release (id, gid, name, release_group, artist_credit)
    VALUES (1, 'ec8c4910-739d-11de-8a39-0800200c9a66', 1, 1, 1);

INSERT INTO release_packaging (id, name) VALUES (1, 'Jewel Case');
INSERT INTO country (id, iso_code, name) VALUES (1, 'GB', 'United Kingdom');
INSERT INTO script (id, iso_code, iso_number, name) VALUES (1, 'Ugar', '040', 'Ugaritic');
INSERT INTO language (id, iso_code_3t, iso_code_3b, iso_code_2, name)
    VALUES (1, 'deu', 'ger', 'de', 'German');

ALTER SEQUENCE artist_credit_id_seq RESTART 2;
ALTER SEQUENCE artist_name_id_seq RESTART 2;
ALTER SEQUENCE release_name_id_seq RESTART 3;


