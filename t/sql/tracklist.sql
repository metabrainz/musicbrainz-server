SET client_min_messages TO 'warning';

INSERT INTO artist_name (id, name) VALUES (1, 'Artist');

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
    VALUES (1, 0, 1, 1, '');

INSERT INTO track_name (id, name) VALUES (1, 'King of the Mountain');
INSERT INTO track_name (id, name) VALUES (2, 'π');
INSERT INTO track_name (id, name) VALUES (3, 'Bertie');
INSERT INTO track_name (id, name) VALUES (4, 'Mrs. Bartolozzi');
INSERT INTO track_name (id, name) VALUES (5, 'How to Be Invisible');
INSERT INTO track_name (id, name) VALUES (6, 'Joanni');
INSERT INTO track_name (id, name) VALUES (7, 'A Coral Room');

INSERT INTO track_name (id, name) VALUES (8, 'Prelude');
INSERT INTO track_name (id, name) VALUES (9, 'Prologue');
INSERT INTO track_name (id, name) VALUES (10, 'An Architect''s Dream');
INSERT INTO track_name (id, name) VALUES (11, 'The Painter''s Link');
INSERT INTO track_name (id, name) VALUES (12, 'Sunset');
INSERT INTO track_name (id, name) VALUES (13, 'Aerial Tal');
INSERT INTO track_name (id, name) VALUES (14, 'Somewhere in Between');
INSERT INTO track_name (id, name) VALUES (15, 'Nocturn');
INSERT INTO track_name (id, name) VALUES (16, 'Aerial');

INSERT INTO recording (id, gid, name, artist_credit, length)
    VALUES (1, '54b9d183-7dab-42ba-94a3-7388a66604b8', 1, 1, 293720),
           (2, '659f405b-b4ee-4033-868a-0daa27784b89', 2, 1, 369680),
           (3, 'ae674299-2824-4500-9516-653ac1bc6f80', 3, 1, 258839),
           (4, 'b1d58a57-a0f3-4db8-aa94-868cdc7bc3bb', 4, 1, 358960),
           (5, '44f52946-0c98-47ba-ba60-964774db56f0', 5, 1, 332613),
           (6, '07614140-8bb8-4db9-9dcc-0917c3a8471b', 6, 1, 296160),
           (7, '1eb4f672-5ee3-454f-9a67-db85a4478fea', 7, 1, 372386),
           (8, '91028302-a466-4557-a19b-a26584564daa', 8, 1, 86186),
           (9, '9560a5ac-d980-41fe-be7f-a6cb4a0cd91b', 9, 1, 342306),
           (10, '2ed42694-7b28-433e-9cf0-1e14a25babfe', 10, 1, 290053),
           (11, '3bf4cbea-f963-4d75-bac5-351a29c60575', 11, 1, 95933),
           (12, '33137503-0ebf-4b6b-a7ce-cc71df5865df', 12, 1, 358573),
           (13, '2c89d9f6-fd0e-4e79-a654-828fbcf4656d', 13, 1, 61333),
           (14, '61b13b9d-e839-4ea9-8453-208eaafb75bf', 14, 1, 300626),
           (15, 'd328d709-609c-4b88-90be-95815f041524', 15, 1, 514679),
           (16, '1539ac10-5081-4469-b8f2-c5896132724e', 16, 1, 472880);

INSERT INTO release_name (id, name) VALUES (1, 'Aerial');

INSERT INTO release_group (id, gid, name, artist_credit, type) VALUES (1, '7c3218d7-75e0-4e8c-971f-f097b6c308c5', 1, 1, 1);

INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (1, 'f205627f-b70a-409d-adbe-66289b614e80', 1, 1, 1),
           (2, '9b3d9383-3d2a-417f-bfbb-56f7c15f075b', 1, 1, 1);

INSERT INTO release_unknown_country (release, date_year)
VALUES (1, 2007), (2, 2008);

INSERT INTO medium_format (id, name, has_discids) VALUES (1, 'Format', TRUE);
INSERT INTO medium (id, release, position, format, name) VALUES (1, 1, 1, 1, 'A Sea of Honey');
INSERT INTO medium (id, release, position, format, name) VALUES (2, 1, 2, 1, 'A Sky of Honey');

INSERT INTO medium (id, release, position, format, name) VALUES (3, 2, 1, 1, 'A Sea of Honey');
INSERT INTO medium (id, release, position, format, name) VALUES (4, 2, 2, 1, 'A Sky of Honey');

INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (1, '66c2ebff-86a8-4e12-a9a2-1650fb97d9d8', 1, 1, 1, 1, 1, 1, NULL);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (2, 'b0caa7d1-0d1e-483e-b22b-ec6ab7fada06', 1, 2, 2, 2, 2, 1, 369680);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (3, 'f891acda-39d6-4a7f-a9d1-dd87b7c46a0a', 1, 3, 3, 3, 3, 1, 258839);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (4, '6c04d03c-4995-43be-8530-215ca911dcbf', 1, 4, 4, 4, 4, 1, 358960);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (5, '849dc232-c33a-4611-a6a5-5a0969d63422', 1, 5, 5, 5, 5, 1, 332613);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (6, '72469a76-7c28-4a84-b7da-174c1034cd0a', 1, 6, 6, 6, 6, 1, 296160);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (7, '5d54de57-561d-4ee2-9ced-af4327249d66', 1, 7, 7, 7, 7, 1, 372386);

INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (8, 'c49c5a81-99c7-4b78-bfbc-8dc3d99242d2', 2, 1, 1, 8, 8, 1, 86186);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (9, '1f1f4f87-df59-4024-bcf3-ec2459496556', 2, 2, 2, 9, 9, 1, 342306);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (10, 'ec9872dd-173a-4eff-8f64-f265cc36c910', 2, 3, 3, 10, 10, 1, 290053);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (11, 'c156351f-52fe-48e4-b056-d08a5d9b02a9', 2, 4, 4, 11, 11, 1, 95933);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (12, '3ec7a73f-c880-485c-ba93-17bcdab71212', 2, 5, 5, 12, 12, 1, 358573);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (13, '8fda3eaa-1b5f-4dbc-8f70-b59592ab6ba7', 2, 6, 6, 13, 13, 1, 61333);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (14, 'c9ac9c6f-e56c-43e3-bdb7-717970a2800c', 2, 7, 7, 14, 14, 1, 300626);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (15, 'b4788492-ae09-46f9-80b1-92af9397bff4', 2, 8, 8, 15, 15, 1, 514679);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (16, '74978be6-e8d2-479d-9207-b5708fd3f48b', 2, 9, 9, 16, 16, 1, 472880);

INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (17, '8bfb9e69-c42d-4677-be1c-35deac370812', 3, 1, 1, 1, 1, 1, NULL);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (18, '63dfa68e-4e17-4830-8c10-c0fe12d62bcc', 3, 2, 2, 2, 2, 1, 369680);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (19, 'cd2c1b6b-59cb-403d-9281-c0a54d185755', 3, 3, 3, 3, 3, 1, 258839);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (20, 'b3e6f1fa-09e6-467d-aa58-f598f2ad9215', 3, 4, 4, 4, 4, 1, 358960);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (21, '4ee82e1a-7b32-420d-a138-5c6bb9d3b79d', 3, 5, 5, 5, 5, 1, 332613);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (22, '0056c1e6-e3ac-4b0c-8c22-0986c89e8ac5', 3, 6, 6, 6, 6, 1, 296160);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (23, 'f921c8a9-4731-4083-b2ea-e8735fb89034', 3, 7, 7, 7, 7, 1, 372386);

INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (24, '07e1a081-ecf8-4ac4-92dd-6697c775b341', 4, 1, 1, 8, 8, 1, 86186);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (25, 'ee10482e-d2e5-4204-9e26-7289e5f9f39d', 4, 2, 2, 9, 9, 1, 342306);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (26, '1e394020-16e1-49d6-ac78-d6c8d833b775', 4, 3, 3, 10, 10, 1, 290053);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (27, '05262836-6f29-4807-9b2c-f07b5d5eeb33', 4, 4, 4, 11, 11, 1, 95933);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (28, '33e4113d-97ce-4ad0-9642-3420d0440a5b', 4, 5, 5, 12, 12, 1, 358573);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (29, 'c05600b8-8ff4-4c66-bd57-b6690252e4f3', 4, 6, 6, 13, 13, 1, 61333);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (30, '5cebf694-6346-44be-9724-375c08864a9d', 4, 7, 7, 14, 14, 1, 300626);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (31, '14767038-01d2-4763-911a-10269df14d1b', 4, 8, 8, 15, 15, 1, 514679);
INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length) VALUES (32, '0a989191-d8ec-4147-9915-9ddcf59fea95', 4, 9, 9, 16, 16, 1, 472880);

INSERT INTO cdtoc (id, discid, freedb_id, track_count, leadout_offset, track_offset, degraded)
       VALUES (1, 'BySFY0Ymit0miawEWumIN8Nvx-', '4b094107', 7, 171327,
              '{187, 25585, 46070, 70612, 89517, 143492, 164262}', FALSE),
              (2, 'IeldkVfIh1wep_M8CMuDvA0nQ7Q-', '6309da09', 9, 189343,
              '{150,6614,32287,54041,61236,88129,92729,115276,153877}', FALSE);

INSERT INTO link_type (id, gid, entity_type0, entity_type1, name, link_phrase, reverse_link_phrase, long_link_phrase)
       VALUES (151, '234670ce-5f22-4fd0-921b-ef1662695c5d',
               'artist', 'recording', 'conductor',
               '{additional:additionally} conducted',
               '{additional} conductor',
               '{additional:additionally} conducted');

INSERT INTO link (id, link_type, attribute_count, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, ended)
       VALUES (1, 151, 0, 1971, 2, NULL, 1972, 2, NULL, true);

INSERT INTO l_artist_recording (id, link, entity0, entity1) VALUES (1, 1, 1, 1);
INSERT INTO l_artist_recording (id, link, entity0, entity1) VALUES (2, 1, 1, 2);

ALTER SEQUENCE track_id_seq RESTART 100;
ALTER SEQUENCE track_name_id_seq RESTART 100;
ALTER SEQUENCE medium_id_seq RESTART 100;
ALTER SEQUENCE recording_id_seq RESTART 100;

ALTER SEQUENCE artist_id_seq RESTART 100;
ALTER SEQUENCE artist_name_id_seq RESTART 100;
ALTER SEQUENCE artist_credit_id_seq RESTART 100;

