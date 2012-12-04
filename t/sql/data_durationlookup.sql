SET client_min_messages TO 'WARNING';

INSERT INTO tracklist_index (tracklist, toc) VALUES (1, '(663400, 258839, 358960, 332613, 296160, 372386)');
INSERT INTO tracklist_index (tracklist, toc) VALUES (2, '(428492, 290053, 454506, 61333, 815305, 472880)');

INSERT INTO artist_name (id, name) VALUES (1, 'Artist');

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
    VALUES (1, 0, 1, 1, '');

INSERT INTO tracklist (id) VALUES (1);
INSERT INTO tracklist (id) VALUES (2);

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

INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (1, 1, 1, 1, 1, 1, 1, 293720);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (2, 1, 2, 2, 2, 2, 1, 369680);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (3, 1, 3, 3, 3, 3, 1, 258839);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (4, 1, 4, 4, 4, 4, 1, 358960);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (5, 1, 5, 5, 5, 5, 1, 332613);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (6, 1, 6, 6, 6, 6, 1, 296160);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (7, 1, 7, 7, 7, 7, 1, 372386);

INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (8, 2, 1, 1, 8, 8, 1, 86186);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (9, 2, 2, 2, 9, 9, 1, 342306);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (10, 2, 3, 3, 10, 10, 1, 290053);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (11, 2, 4, 4, 11, 11, 1, 95933);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (12, 2, 5, 5, 12, 12, 1, 358573);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (13, 2, 6, 6, 13, 13, 1, 61333);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (14, 2, 7, 7, 14, 14, 1, 300626);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (15, 2, 8, 8, 15, 15, 1, 514679);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (16, 2, 9, 9, 16, 16, 1, 472880);

INSERT INTO release_name (id, name) VALUES (1, 'Aerial');

INSERT INTO release_group (id, gid, name, artist_credit) VALUES (1, '7c3218d7-75e0-4e8c-971f-f097b6c308c5', 1, 1);

INSERT INTO release (id, gid, name, artist_credit, release_group, date_year)
    VALUES (1, 'f205627f-b70a-409d-adbe-66289b614e80', 1, 1, 1, 2007),
           (2, '9b3d9383-3d2a-417f-bfbb-56f7c15f075b', 1, 1, 1, 2008);

INSERT INTO medium_format (id, name) VALUES (1, 'Format');
INSERT INTO medium (id, release, position, tracklist, format, name) VALUES (1, 1, 1, 1, 1, 'A Sea of Honey');
INSERT INTO medium (id, release, position, tracklist, format, name) VALUES (2, 1, 2, 2, 1, 'A Sky of Honey');

INSERT INTO medium (id, release, position, tracklist, format, name) VALUES (3, 2, 1, 1, 1, 'A Sea of Honey');
INSERT INTO medium (id, release, position, tracklist, format, name) VALUES (4, 2, 2, 2, 1, 'A Sky of Honey');

ALTER SEQUENCE track_name_id_seq RESTART 17;
ALTER SEQUENCE track_id_seq RESTART 17;
ALTER SEQUENCE recording_id_seq RESTART 17;


