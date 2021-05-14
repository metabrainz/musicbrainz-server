INSERT INTO editor (id, name, password, ha1, email, email_confirm_date)
VALUES (1, 'editor', '{CLEARTEXT}pass', '3f3edade87115ce351d63f42d92a1834', 'editor@example.com', now());

INSERT INTO artist (id, gid, name, sort_name)
VALUES (1, 'c4c692f3-6e92-43cd-aad0-5d149e07960a', 'Artist', 'Artist');

INSERT INTO artist_credit (id, name, artist_count, gid)
VALUES (1, 'Artist', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');

INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
VALUES (1, 1, 'Artist', 0, '');

INSERT INTO release_group (id, gid, name, artist_credit)
VALUES (1, '269325ac-e112-489b-a01d-8fbf13b6ea50', 'Release Group', 1);

INSERT INTO release (id, gid, name, artist_credit, release_group)
VALUES
    (1, '642661e5-407a-4ec5-826b-f8209d861f38', 'Release 1', 1, 1),
    (2, 'adcbe6cc-067f-43a0-98be-770acecc50a5', 'Release 2', 1, 1);

INSERT INTO medium (id, release, position, track_count)
VALUES (1, 1, 1, 0), (2, 2, 1, 0);
