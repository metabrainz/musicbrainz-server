INSERT INTO artist (id, gid, name, sort_name)
    VALUES (5, '945c079d-374e-4436-9448-da92dedef3cf', 'Bob & Tom', 'Bob & Tom'),
           (6, '5441c29d-3602-4898-b1a1-b77fa23b8e50', 'Bob', 'Bob'),
           (7, '5f9913b0-7219-11de-8a39-0800200c9a66', 'Tom', 'Tom');

INSERT INTO artist_credit (id, name, artist_count, gid)
    VALUES (1, 'Bob & Tom', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');
INSERT INTO artist_credit_name (artist_credit, position, artist, join_phrase, name)
    VALUES (1, 0, 5, '', 'Bob & Tom');

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Release', 1);
INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Release', 1, 1);
INSERT INTO recording (id, gid, name, artist_credit)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Track', 1);

INSERT INTO medium (id, release, position, format) VALUES (1, 1, 1, 1);
INSERT INTO track (id, gid, name, artist_credit, recording, medium, position, number)
    VALUES (1, '164f2789-f13a-43d6-8136-ca6804932e39', 'Track', 1, 1, 1, 1, 1);
