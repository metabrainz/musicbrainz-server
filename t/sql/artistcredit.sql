INSERT INTO artist_name (id, name) VALUES (1, 'Queen');
INSERT INTO artist_name (id, name) VALUES (2, 'David Bowie');
INSERT INTO artist_name (id, name) VALUES (3, 'Merge');
INSERT INTO artist_name (id, name) VALUES (1000, 'Queen & David Bowie');

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1);

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (2, '5441c29d-3602-4898-b1a1-b77fa23b8e50', 2, 2);

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (3, '5f9913b0-7219-11de-8a39-0800200c9a66', 3, 3);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1000, 2);

INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
    VALUES (1, 0, 1, 1, ' & ');

INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
    VALUES (1, 1, 2, 2, '');

ALTER SEQUENCE artist_name_id_seq RESTART 4;
ALTER SEQUENCE artist_credit_id_seq RESTART 2;
