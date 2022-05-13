INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '745c079d-374e-4436-9448-da92dedef3ce', 'Artist Name', 'Artist Name');

INSERT INTO artist_credit (id, name, artist_count, gid)
    VALUES (1, 'Artist Name', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');
INSERT INTO artist_credit_name (artist_credit, name, position, artist, join_phrase)
    VALUES (1, 'Artist Name', 1, 1, '');

INSERT INTO label (id, gid, name)
    VALUES (1, '56a40160-8ff2-11de-8a39-0800200c9a66', 'Label Name');

INSERT INTO recording (id, gid, name, artist_credit)
    VALUES (1, 'e4919fa0-8ff2-11de-8a39-0800200c9a66', 'Recording Name', 1);

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, 'ca10b110-8ff3-11de-8a39-0800200c9a66', 'Release Group Name', 1);

INSERT INTO release (id, gid, name, release_group, artist_credit)
    VALUES (1, 'e4919fa0-8ff2-11de-8a39-0800200c9a66', 'Release Name', 1, 1);

INSERT INTO work (id, gid, name)
    VALUES (1, 'b0c3aea0-8ff4-11de-8a39-0800200c9a66', 'Work Name');

INSERT INTO editor (id, name, password, ha1, email, email_confirm_date) VALUES (1, 'editor', '{CLEARTEXT}pass', '3f3edade87115ce351d63f42d92a1834', '', now());
