SET client_min_messages TO 'warning';

INSERT INTO artist (id, gid, name, sort_name, begin_date_year, begin_date_month, begin_date_day, type)
VALUES (7, '4b585938-f271-45e2-b19a-91c634b5e396', 'Kate Bush', 'Bush, Kate', 1958, 7, 30, 1);

INSERT INTO artist_credit (id, name, artist_count, gid)
VALUES (1, 'Kate Bush', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');

INSERT INTO artist_credit_name (artist_credit, position, artist, name)
VALUES (1, 0, 7, 'Kate Bush');

INSERT INTO recording (id, gid, name, artist_credit, length)
VALUES (1, '54b9d183-7dab-42ba-94a3-7388a66604b8', 'King of the Mountain', 1, 293720),
       (2, '659f405b-b4ee-4033-868a-0daa27784b89', 'π', 1, 369680);

INSERT INTO release_group (id, gid, name, artist_credit, type)
VALUES (1, '7c3218d7-75e0-4e8c-971f-f097b6c308c5', 'Aerial', 1, 1);

INSERT INTO release (id, gid, name, artist_credit, release_group)
VALUES (1, 'f205627f-b70a-409d-adbe-66289b614e80', 'Aerial', 1, 1),
       (2, '9b3d9383-3d2a-417f-bfbb-56f7c15f075b', 'Aerial', 1, 1);

INSERT INTO medium (id, release, position, format, name)
VALUES (1, 1, 1, NULL, 'A Sea of Honey'),
       (2, 2, 1, NULL, 'A Sky of Honey');

INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length)
VALUES (1, '66c2ebff-86a8-4e12-a9a2-1650fb97d9d8', 1, 1, '1', 1, 'King of the Mountain', 1, NULL),
       (2, 'b0caa7d1-0d1e-483e-b22b-ec6ab7fada06', 1, 2, '2', 2, 'π', 1, NULL),
       (3, 'f891acda-39d6-4a7f-a9d1-dd87b7c46a0a', 2, 1, '1', 2, 'π', 1, NULL),
       (4, '6c04d03c-4995-43be-8530-215ca911dcbf', 2, 2, '2', 1, 'King of the Mountain', 1, NULL);
