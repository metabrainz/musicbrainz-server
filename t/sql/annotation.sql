INSERT INTO artist_name (id, name) VALUES (1, 'Artist Name');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '745c079d-374e-4436-9448-da92dedef3ce', 1, 1);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, name, position, artist, join_phrase)
    VALUES (1, 1, 1, 1, '');

INSERT INTO label_name (id, name) VALUES (1, 'Label Name');
INSERT INTO label (id, gid, name, sort_name)
    VALUES (1, '56a40160-8ff2-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO track_name (id, name) VALUES (1, 'Recording Name');
INSERT INTO recording (id, gid, name, artist_credit)
    VALUES (1, 'e4919fa0-8ff2-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO release_name (id, name) VALUES (1, 'Release Name');
INSERT INTO release_name (id, name) VALUES (2, 'Release Group Name');

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, 'ca10b110-8ff3-11de-8a39-0800200c9a66', 2, 1);

INSERT INTO release (id, gid, name, release_group, artist_credit)
    VALUES (1, 'e4919fa0-8ff2-11de-8a39-0800200c9a66', 1, 1, 1);

INSERT INTO work_name (id, name) VALUES (1, 'Work Name');
INSERT INTO work (id, gid, name)
    VALUES (1, 'b0c3aea0-8ff4-11de-8a39-0800200c9a66', 1);

INSERT INTO editor (id, name, password, ha1, email, email_confirm_date) VALUES (1, 'editor', '{CLEARTEXT}pass', '3f3edade87115ce351d63f42d92a1834', '', now());
