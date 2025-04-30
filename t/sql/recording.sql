SET client_min_messages TO 'warning';

INSERT INTO editor (id, name, password, ha1, email, email_confirm_date) VALUES (1, 'editor', '{CLEARTEXT}password', '3a115bc4f05ea9856bd4611b75c80bca', 'foo@example.com', now());

INSERT INTO annotation (id, editor, text, changelog) VALUES (1, 1, 'Annotation', 'changelog');
INSERT INTO recording_annotation (recording, annotation) VALUES (1, 1);
INSERT INTO recording_gid_redirect (gid, new_id) VALUES ('0986e67c-6b7a-40b7-b4ba-c9d7583d6426', 1);

INSERT INTO release_group (id, name, type, artist_credit, gid)
       VALUES (22, 'エアリアル', 1, 1, '6169f5bc-b5ff-3348-b806-1b0f2a414217'),
              (23, 'King of the Mountain', 2, 1, 'fbf86737-02a4-304f-8554-6896e8619d77'),
              (24, 'Brit Awards 2006', 1, 1, 'bd09da37-a5c9-37f2-b265-c19686374e0b');

INSERT INTO release_group_secondary_type_join (release_group, secondary_type) VALUES (24, 1);

INSERT INTO release (id, name, release_group, artist_credit, gid)
    VALUES (22, 'エアリアル', 22, 1, '888695fa-8acf-4ddb-8726-23edf32e48c5'),
           (23, 'King of the Mountain', 23, 1, '785a5e34-bf47-40f2-8148-65b1ed631ac5'),
           (24, 'Brit Awards 2006', 24, 1, 'ac6e8393-2694-4e47-a5b3-82dc93477c5f');

INSERT INTO release_unknown_country (release, date_year)
     VALUES (22, 2005);

INSERT INTO medium (id, gid, release, position, format, name)
       VALUES (22, '4ac4d138-ba4f-4792-bba2-6530b6574938', 22, 1, 1, 'A Sea of Honey'),
              (23, '536562ca-12fa-4aff-b3c5-1c35af810148', 23, 1, 1, ''),
              (24, 'f404ca44-9b23-4dd9-b8a0-a4543959a562', 24, 1, 1, '');

INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length)
       VALUES (62, '98d47750-2da0-497c-94aa-9dedc713ca53', 22, 1, 1, 1, 'King of the Mountain', 1, NULL),
              (63, 'f89d2463-8c12-49cb-9c83-229f2a5d4028', 23, 1, 1, 1, 'King of the Mountain', 1, NULL),
              (64, '13103972-499f-4407-b248-3d04c1afcc24', 24, 1, 1, 1, 'King of the Mountain', 1, NULL);

INSERT INTO recording_alias (id, recording, name, type, sort_name) VALUES
    (1, 1, 'Test Recording Alias', 1, 'Test Recording Alias');
