
SET client_min_messages TO 'warning';

INSERT INTO language (id, iso_code_2t, iso_code_2b, iso_code_1, iso_code_3, name)
    VALUES (1, 'deu', 'ger', 'de', 'deu', 'German');
INSERT INTO script (id, iso_code, iso_number, name) VALUES (1, 'Ugar', '040', 'Ugaritic');
INSERT INTO country (id, iso_code, name) VALUES (1, 'GB', 'United Kingdom');

INSERT INTO artist_name (id, name) VALUES (2, 'Other Artist');
INSERT INTO artist (id, name, sort_name, gid) VALUES (2, 2, 2, '9f5ad190-caee-11de-8a39-0800200c9a66');
INSERT INTO tracklist (id) VALUES (3);
INSERT INTO track (id, tracklist, position, recording, name, artist_credit, length) VALUES (17, 3, 1, 1, 1, 1, 293720);
INSERT INTO medium_format (id, name) VALUES (2, 'Musical Box');
INSERT INTO release_packaging (id, name) VALUES (2, 'Digipak');
INSERT INTO release_status (id, name) VALUES (2, 'Promotion');

ALTER SEQUENCE artist_name_id_seq RESTART 3;
ALTER SEQUENCE medium_id_seq RESTART 5;
ALTER SEQUENCE tracklist_id_seq RESTART 4;
ALTER SEQUENCE track_id_seq RESTART 18;


