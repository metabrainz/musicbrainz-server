SET client_min_messages TO 'warning';

-- Artists

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (3400, 'af4c43d3-c0e0-421e-ac64-000329af0435', 'Witold Lutosławski', 'Lutosławski, Witold'),
           (3401, 'dea28aa9-1086-4ffa-8739-0ccc759de1ce', 'Berliner Philharmoniker', 'Berliner Philharmoniker'),
           (3402, '802cd1ab-d87f-4418-915f-ff716defb87d', 'Sinfonia Varsovia', 'Sinfonia Varsovia'),
           (3403, '24f1766e-9635-4d58-a4d4-9413f9f98a4c', 'Johann Sebastian Bach', 'Bach, Johann Sebastian');

INSERT INTO artist_credit (id, name, artist_count)
    VALUES (3400, 'Witold Lutosławski', 1),
           (3401, 'Berliner Philharmoniker, Witold Lutosławski', 2),
           (3402, 'Sinfonia Varsovia, Witold Lutosławski', 2);

INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
    VALUES (3400, 0, 3400, 'Witold Lutosławski', ''),
           (3401, 0, 3401, 'Berliner Philharmoniker', ', '),
           (3401, 1, 3400, 'Witold Lutosławski', ''),
           (3402, 0, 3402, 'Sinfonia Varsovia', ', '),
           (3402, 1, 3400, 'Witold Lutosławski', '');
-- RGs

INSERT INTO release_group (id, gid, name, artist_credit, type)
    VALUES (3400, 'bee95816-da7d-3902-9038-3e8f9b3ebe9f', 'Concerto for Orchestra / Symphony no. 3', 3400, 1),
           (3401, '6dfcff0b-9434-48b9-bf14-ed674dd626f5', 'Piano Concerto / Symphony no. 2', 3401, 1),
           (3402, '98b72608-a824-40c5-b5df-81cf981faf7e', 'Symphonies / Concertos / Choral and Vocal Works', 3400, 1),
           (3403, '33d71de2-d3c6-4906-908e-df59d70b283d', 'Lutosławski', 3400, 1),
           (3404, 'fc9b775a-6c06-3828-b6a4-220b65cfef60', 'String Quartet', 3400, NULL),
           (3405, '5a52075e-f5eb-3de5-8236-aa21cc05cb1e', 'Jeux vénetiens', 3400, 2);

INSERT INTO release_group_secondary_type_join (release_group, secondary_type)
    VALUES (3403, 6), (3405, 6);

-- Recordings

INSERT INTO recording (id, gid, name, artist_credit)
    VALUES (3400, 'ce82bfa1-733a-494a-aaa0-fc5de79bd54f', 'Interludium', 3402),
           (3401, 'd9c7a74e-3c08-48b1-be2f-5d9a144f2c08', 'Symphony no. 3', 3401),
           (3402, 'd9c7a74e-3c08-48b1-be2f-5d9a144f2c01', 'Brandenburg Concerto no. 5', 3401),
           (3403, 'd9c7a74e-3c08-48b1-be2f-5d9a144f2c02', 'Brandenburg Concerto no. 5', 3402);

-- Works

INSERT INTO work (id, gid, name, type)
    VALUES (3400, 'a0cd8685-0626-49e2-8722-aa8c726287db', 'Interlude', NULL),
           (3401, '4d89910c-14ae-4d23-b7d4-9cbe111981b6', 'Symphony no. 3', 16),
           (3402, '4ef6d273-4534-4b37-97f1-3e01d76b2fe5', 'Symphony no. 4', 16),
           (3403, 'fcedfaf3-63ad-4ea2-949a-b16cdc2cd019', 'Mini Overture', 12),
           (3404, 'dbb7157a-5dc3-41c4-aacc-4e3d4705e132', 'Brandenburgisches Konzert Nr. 5 D-Dur, BWV 1050', 4);

-- Relationships

INSERT INTO link (id, link_type, attribute_count)
    VALUES (3400, 278, 0), (3401, 278, 0), (3402, 278, 0), (3403, 278, 0), -- performance
           (3404, 151, 0), (3405, 151, 0), (3406, 151, 0), (3407, 151, 0), -- conductor
           (3408, 150, 0), (3409, 150, 0), (3410, 150, 0), (3411, 150, 0), -- orchestra
           (3412, 168, 0), (3413, 168, 0), (3414, 168, 0), (3415, 168, 0), (3416, 168, 0); -- composer

INSERT INTO l_artist_recording (id, link, entity0, entity1)
    VALUES (3400, 3404, 3400, 3400), (3401, 3405, 3400, 3401), (3402, 3406, 3400, 3402), (3403, 3407, 3400, 3403), -- conductor
           (3404, 3408, 3402, 3400), (3405, 3409, 3401, 3401), (3406, 3410, 3401, 3402), (3407, 3411, 3402, 3403); --orchestra

INSERT INTO l_artist_work (id, link, entity0, entity1)
    VALUES (3400, 3412, 3400, 3400), (3401, 3413, 3400, 3401), (3402, 3414, 3400, 3402), (3403, 3415, 3400, 3403), (3404, 3416, 3403, 3404);

INSERT INTO l_recording_work (id, link, entity0, entity1)
    VALUES (3400, 3400, 3400, 3400), (3401, 3401, 3401, 3401), (3402, 3402, 3402, 3404), (3403, 3403, 3403, 3404);
