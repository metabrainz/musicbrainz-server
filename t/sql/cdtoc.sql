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
INSERT INTO medium (id, release, track_count, position) VALUES (1, 1, 0, 1),  (2, 2, 0, 1);

INSERT INTO cdtoc (id, discid, freedb_id, track_count, leadout_offset, track_offset) VALUES
    (1, 'tLGBAiCflG8ZI6lFcOt87vXjEcI-', '5908ea07', 7, 171327,
     ARRAY[150,22179,49905,69318,96240,121186,143398]);
INSERT INTO medium_cdtoc (id, medium, cdtoc) VALUES
    (1, 1, 1), (2, 2, 1);

INSERT INTO track_name (id, name) VALUES (1, 'The same track over and over');
INSERT INTO recording (id, gid, name, artist_credit, length) VALUES (1, '54b9d183-7dab-42ba-94a3-7388a66604b8', 1, 1, NULL);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (1, '66c2ebff-86a8-4e12-a9a2-1650fb97d9d8', 1, 1, 1, 1, 1, 1, NULL);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (2, 'b0caa7d1-0d1e-483e-b22b-ec6ab7fada06', 1, 2, 2, 1, 1, 1, NULL);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (3, 'f891acda-39d6-4a7f-a9d1-dd87b7c46a0a', 1, 3, 3, 1, 1, 1, NULL);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (4, '6c04d03c-4995-43be-8530-215ca911dcbf', 1, 4, 4, 1, 1, 1, NULL);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (5, '849dc232-c33a-4611-a6a5-5a0969d63422', 1, 5, 5, 1, 1, 1, NULL);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (6, '72469a76-7c28-4a84-b7da-174c1034cd0a', 1, 6, 6, 1, 1, 1, NULL);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (7, '5d54de57-561d-4ee2-9ced-af4327249d66', 1, 7, 7, 1, 1, 1, NULL);

INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (8, 'c05b1c9a-e768-4c8d-b2b6-c687060c8f1e', 2, 1, 1, 1, 1, 1, NULL);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (9, 'dcfefa46-e689-4877-b535-d617cdb7616c', 2, 2, 2, 1, 1, 1, NULL);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (10, '94364964-9557-4a7c-8373-c4796a5905cb', 2, 3, 3, 1, 1, 1, NULL);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (11, '3fa99306-2c99-4173-bb3e-e86e83f1f64e', 2, 4, 4, 1, 1, 1, NULL);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (12, '29d6a6af-98e2-4b86-a7bb-5f997a82170a', 2, 5, 5, 1, 1, 1, NULL);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (13, 'c6d69534-f122-451f-8220-346ef1f0c7cd', 2, 6, 6, 1, 1, 1, NULL);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (14, '2f48725e-a465-4a27-b758-dfc438ce4160', 2, 7, 7, 1, 1, 1, NULL);

ALTER SEQUENCE cdtoc_id_seq RESTART 2;
ALTER SEQUENCE medium_cdtoc_id_seq RESTART 3;
