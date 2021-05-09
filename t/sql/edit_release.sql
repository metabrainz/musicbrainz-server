SET client_min_messages TO 'warning';

INSERT INTO artist (id, gid, name, sort_name, comment) VALUES
    (1, 'a28505a0-739d-11de-8a39-0800200c9a66', 'Artist', 'Artist', 'Artist 1'),
    (2, '1c034cf0-73a5-11de-8a39-0800200c9a66', 'Artist', 'Artist', 'Artist 2');

INSERT INTO artist_credit (id, name, artist_count, gid)
    VALUES (1, 'Artist', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');
INSERT INTO artist_credit_name (artist_credit, name, artist, position, join_phrase)
    VALUES (1, 'Artist', 1, 0, '');

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, 'f83360f0-739d-11de-8a39-0800200c9a66', 'Release Group', 1);

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (2, '9524c7e0-73a4-11de-8a39-0800200c9a66', 'Release Group', 1);

INSERT INTO release (id, gid, name, release_group, artist_credit, comment)
    VALUES (1, 'ec8c4910-739d-11de-8a39-0800200c9a66', 'Release', 1, 1, 'hello');

INSERT INTO area (id, gid, name, type) VALUES
  (221, '8a754a16-0027-3a29-b6d7-2b40ea0481ed', 'United Kingdom', 1);
INSERT INTO country_area (area) VALUES (221);
INSERT INTO iso_3166_1 (area, code) VALUES (221, 'GB');
