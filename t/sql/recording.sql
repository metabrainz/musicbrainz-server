SET client_min_messages TO 'warning';

INSERT INTO editor (id, name, password) VALUES (1, 'editor', 'password');
INSERT INTO annotation (id, editor, text, changelog) VALUES (1, 1, 'Annotation', 'changelog');
INSERT INTO recording_annotation (recording, annotation) VALUES (1, 1);
INSERT INTO recording_gid_redirect (gid, new_id) VALUES ('0986e67c-6b7a-40b7-b4ba-c9d7583d6426', 1);

INSERT INTO release_group_type (name, id) VALUES ('Compilation', 4);

INSERT INTO release_name (id, name) VALUES (22, 'エアリアル');
INSERT INTO release_name (id, name) VALUES (23, 'King of the Mountain');
INSERT INTO release_name (id, name) VALUES (24, 'Brit Awards 2006');

INSERT INTO release_group (id, name, type, artist_credit, gid)
       VALUES (22, 22, 1, 1, '6169f5bc-b5ff-3348-b806-1b0f2a414217'),
              (23, 23, 2, 1, 'fbf86737-02a4-304f-8554-6896e8619d77'),
              (24, 24, 4, 1, 'bd09da37-a5c9-37f2-b265-c19686374e0b');

INSERT INTO release (id, name, release_group, artist_credit, gid)
    VALUES (22, 22, 22, 1, '888695fa-8acf-4ddb-8726-23edf32e48c5'),
           (23, 23, 23, 1, '785a5e34-bf47-40f2-8148-65b1ed631ac5'),
           (24, 24, 24, 1, 'ac6e8393-2694-4e47-a5b3-82dc93477c5f');

INSERT INTO tracklist (id) VALUES (22), (23), (24);

INSERT INTO medium (id, release, tracklist, position, format, name)
       VALUES (22, 22, 22, 1, 1, 'A Sea of Honey'),
              (23, 23, 23, 1, 1, NULL),
              (24, 24, 24, 1, 1, NULL);

INSERT INTO track (id, tracklist, position, recording, name, artist_credit, length)
       VALUES (22, 22, 1, 1, 1, 1, NULL),
              (23, 23, 1, 1, 1, 1, NULL),
              (24, 24, 1, 1, 1, 1, NULL);

