INSERT INTO artist_name (id, name) VALUES (1, 'Name');
INSERT INTO artist_name (id, name) VALUES (2, 'Empty Artist');
INSERT INTO artist_name (id, name) VALUES (3, 'Alias 1');
INSERT INTO artist_name (id, name) VALUES (4, 'Alias 2');

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1);

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (2, '73371ea0-7217-11de-8a39-0800200c9a66', 2, 2);

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (3, '686cdcc0-7218-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO artist_alias (id, artist, name) VALUES (1, 1, 3);
INSERT INTO artist_alias (id, artist, name, locale) VALUES (2, 1, 4, 'en_GB');
INSERT INTO artist_alias (id, artist, name) VALUES (3, 3, 4);

ALTER SEQUENCE artist_name_id_seq RESTART 5;
ALTER SEQUENCE artist_alias_id_seq RESTART 4;
