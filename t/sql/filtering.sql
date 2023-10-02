SET client_min_messages TO 'warning';

-- Artists

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (3400, 'af4c43d3-c0e0-421e-ac64-000329af0435', 'Witold Lutosławski', 'Lutosławski, Witold'),
           (3401, 'dea28aa9-1086-4ffa-8739-0ccc759de1ce', 'Berliner Philharmoniker', 'Berliner Philharmoniker'),
           (3402, '802cd1ab-d87f-4418-915f-ff716defb87d', 'Sinfonia Varsovia', 'Sinfonia Varsovia'),
           (3403, '24f1766e-9635-4d58-a4d4-9413f9f98a4c', 'Johann Sebastian Bach', 'Bach, Johann Sebastian');

INSERT INTO artist_credit (id, name, artist_count, gid)
    VALUES (3400, 'Witold Lutosławski', 1, 'd18b35f1-b9e2-39cf-a060-9e2f64aafc9c'),
           (3401, 'Berliner Philharmoniker, Witold Lutosławski', 2, 'de9a2647-55e0-3d4a-a250-397175181e3f'),
           (3402, 'Sinfonia Varsovia, Witold Lutosławski', 2, '09b2430c-3473-35de-b296-acc2aa3da00a');

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

-- Releases (and countries, labels)

INSERT INTO release (id, gid, name, artist_credit, status, release_group)
    VALUES (3400, 'bee95816-da7d-3902-9038-3e8f9b3ebe9a', 'Concerto for Orchestra / Symphony no. 3', 3400, 1, 3400),
           (3401, '6dfcff0b-9434-48b9-bf14-ed674dd626fa', 'Piano Concerto / Symphony no. 2', 3401, 1, 3401),
           (3402, '98b72608-a824-40c5-b5df-81cf981faf7a', 'Symphonies / Concertos / Choral and Vocal Works', 3400, 1, 3402),
           (3403, '33d71de2-d3c6-4906-908e-df59d70b283a', 'Lutosławski', 3400, 1, 3403),
           (3404, 'fc9b775a-6c06-3828-b6a4-220b65cfef6a', 'String Quartet', 3400, NULL, 3404),
           (3405, '5a52075e-f5eb-3de5-8236-aa21cc05cb1a', 'Jeux vénetiens', 3400, 5, 3405);

INSERT INTO label (id, gid, name)
    VALUES (3400, 'ed65f6e2-5454-45a7-8607-e1106d209734', 'Erato'),
           (3401, '5a584032-dcef-41bb-9f8b-19540116fb1c', 'Deutsche Grammophon'),
           (3402, '615fa478-3901-42b8-80bc-bf58b1ff0e03', 'Naxos'),
           (3403, '157afde4-4bf5-4039-8ad2-5a15acc85176', '[no label]');

INSERT INTO release_label (release, label, catalog_number)
    VALUES (3400, 3400, '4509-91711-2'),
           (3401, 3401, '0289 479 4518'),
           (3402, 3402, '8.501066'),
           (3403, 3403, NULL),
           (3404, 3401, NULL),
           (3405, 3403, '[none]');

INSERT INTO area (id, gid, name, type)
    VALUES (221, '8a754a16-0027-3a29-b6d7-2b40ea0481ed', 'United Kingdom', 1),
           (222, '489ce91b-6658-3307-9877-795b68554c98', 'United States', 1);

INSERT INTO country_area (area) VALUES (221), (222);

INSERT INTO release_country (release, country, date_year, date_month, date_day)
    VALUES (3400, 221, 1993, NULL, NULL),
           (3401, 221, 2010, 12, 12),
           (3405, 222, NULL, NULL, NULL);

INSERT INTO release_unknown_country (release, date_year, date_month, date_day)
    VALUES (3402, 1993, NULL, NULL),
           (3403, 2010, NULL, NULL),
           (3404, 2010, NULL, NULL);

-- Events

INSERT INTO event (id, gid, name, type, setlist)
    VALUES (3400, 'c681f4a3-26db-49e6-80a2-0dbc0a758161', 'Berliner Philharmoniker plays Schnittke and Shostakovich', 1, ''),
           (3401, '96d6b7d0-90ed-449e-91d3-a05fd4d54b06', '[concert]', 1, '* [e42cce08-f3f1-4e9b-8bfe-11670ad22d52|Asteroid 4179: Toutatis] (Kaija Saariaho) (world premiere)\r* [439c1605-bf74-4e0c-b2d9-6f4f89619ec6|The Planets, op. 32] (Gustav Holst)'),
           (3402, '5411fa48-5756-45f7-aadb-5aa3e5bd5954', '[concert]', 1, '* [1637948a-63f8-4cf5-bbb3-8faae3964b13|Seht die Sonne] (Magnus Lindberg) (world premiere)'),
           (3403, '033c9bf9-eef9-409b-9bff-c8d2dea671f5', 'Uncertain', NULL, '');


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
           (3408, 150, 0), (3409, 150, 0), (3410, 150, 0), (3411, 150, 0), -- orchestra (recording)
           (3412, 168, 0), (3413, 168, 0), (3414, 168, 0), (3415, 168, 0), (3416, 168, 0), -- composer
           (3417, 807, 0), (3418, 807, 0), (3419, 807, 0), (3420, 807, 0); -- orchestra (event)

INSERT INTO l_artist_event (id, link, entity0, entity1)
    VALUES (3400, 3417, 3401, 3400), (3401, 3418, 3401, 3401), (3402, 3419, 3401, 3402), (3403, 3420, 3401, 3403);

INSERT INTO l_artist_recording (id, link, entity0, entity1)
    VALUES (3400, 3404, 3400, 3400), (3401, 3405, 3400, 3401), (3402, 3406, 3400, 3402), (3403, 3407, 3400, 3403), -- conductor
           (3404, 3408, 3402, 3400), (3405, 3409, 3401, 3401), (3406, 3410, 3401, 3402), (3407, 3411, 3402, 3403); --orchestra

INSERT INTO l_artist_work (id, link, entity0, entity1)
    VALUES (3400, 3412, 3400, 3400), (3401, 3413, 3400, 3401), (3402, 3414, 3400, 3402), (3403, 3415, 3400, 3403), (3404, 3416, 3403, 3404);

INSERT INTO l_recording_work (id, link, entity0, entity1)
    VALUES (3400, 3400, 3400, 3400), (3401, 3401, 3401, 3401), (3402, 3402, 3402, 3404), (3403, 3403, 3403, 3404);
