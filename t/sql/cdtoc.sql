INSERT INTO artist_name (id, name) VALUES (1, 'Kate Bush');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '5f9913b0-7219-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, position, artist, name)
    VALUES (1, 0, 1, 1);

INSERT INTO release_name (id, name) VALUES (1, 'Aerial');
INSERT INTO release_group (id, gid, name, artist_credit) VALUES
    (1, '3ca028a0-3c88-43cc-943d-d9ce1bade7a7', 1, 1);
INSERT INTO release (id, gid, name, release_group, artist_credit) VALUES
    (1, '8c2a1f4e-e11a-4261-a0f4-d1039ef94745', 1, 1, 1),
    (2, '37b58375-019f-4ffb-8360-9c4b11d087b8', 1, 1, 1);
INSERT INTO tracklist (id, track_count) VALUES (1, 0);
INSERT INTO medium (id, release, tracklist, position) VALUES (1, 1, 1, 1),  (2, 2, 1, 1);

INSERT INTO cdtoc (id, discid, freedb_id, track_count, leadout_offset, track_offset) VALUES
    (1, 'tLGBAiCflG8ZI6lFcOt87vXjEcI-', '5908ea07', 7, 171327,
     ARRAY[150,22179,49905,69318,96240,121186,143398]);
INSERT INTO medium_cdtoc (id, medium, cdtoc) VALUES
    (1, 1, 1), (2, 2, 1);

ALTER SEQUENCE cdtoc_id_seq RESTART 2;
ALTER SEQUENCE medium_cdtoc_id_seq RESTART 3;
