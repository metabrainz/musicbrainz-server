SET client_min_messages TO 'warning';

INSERT INTO artist_name (id, name) VALUES (1, 'Artist');
INSERT INTO artist (id, gid, name, sort_name, comment) VALUES
    (1, 'a28505a0-739d-11de-8a39-0800200c9a66', 1, 1, 'Artist 1'),
    (2, '1c034cf0-73a5-11de-8a39-0800200c9a66', 1, 1, 'Artist 2');

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, name, artist, position, join_phrase)
    VALUES (1, 1, 1, 0, '');

INSERT INTO release_name (id, name) VALUES (1, 'Release');
INSERT INTO release_name (id, name) VALUES (2, 'Release Group');

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, 'f83360f0-739d-11de-8a39-0800200c9a66', 2, 1);

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (2, '9524c7e0-73a4-11de-8a39-0800200c9a66', 2, 1);

INSERT INTO release (id, gid, name, release_group, artist_credit)
    VALUES (1, 'ec8c4910-739d-11de-8a39-0800200c9a66', 1, 1, 1);

INSERT INTO release_packaging (id, name) VALUES (1, 'Jewel Case');
INSERT INTO script (id, iso_code, iso_number, name) VALUES (1, 'Ugar', '040', 'Ugaritic');
INSERT INTO language (id, iso_code_2t, iso_code_2b, iso_code_1, iso_code_3, name)
    VALUES (1, 'deu', 'ger', 'de', 'deu', 'German');

INSERT INTO area_type (id, name) VALUES (1, 'Country');
INSERT INTO area (id, gid, name, sort_name, type) VALUES
  (221, '8a754a16-0027-3a29-b6d7-2b40ea0481ed', 'United Kingdom', 'United Kingdom', 1);
INSERT INTO country_area (area) VALUES (221);
INSERT INTO iso_3166_1 (area, code) VALUES (221, 'GB');

ALTER SEQUENCE artist_credit_id_seq RESTART 2;
ALTER SEQUENCE artist_name_id_seq RESTART 2;
ALTER SEQUENCE release_name_id_seq RESTART 3;


