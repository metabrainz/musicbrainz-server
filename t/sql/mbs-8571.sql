INSERT INTO editor (id, name, password, ha1, email, email_confirm_date)
VALUES (1, 'editor', '{CLEARTEXT}pass', '3f3edade87115ce351d63f42d92a1834', 'editor@example.com', now());

INSERT INTO artist (id, gid, name, sort_name)
VALUES (1, '1132c63d-150f-4929-8893-f57ed3907f9d', 'Artist', 'Artist');

INSERT INTO artist_credit (id, name, artist_count, gid)
    VALUES (1, 'Artist', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');

INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
VALUES (1, 1, 'Artist', 0, '');

INSERT INTO release_group (id, gid, name, artist_credit)
VALUES (1, '97836dfb-ef11-4a85-a41f-fa2e6ae41bc3', 'Release Group', 1);

INSERT INTO release (id, gid, name, artist_credit, release_group)
VALUES
    (1, 'b2d3f2a4-d708-4897-b1cf-e3ae0214b070', 'Release 1', 1, 1),
    (2, '5d3e11d3-2944-4a83-bbe7-e054ea94902f', 'Release 2', 1, 1);

INSERT INTO medium (id, release, position, track_count)
VALUES (1, 1, 1, 0), (2, 2, 1, 0), (3, 2, 2, 0);
