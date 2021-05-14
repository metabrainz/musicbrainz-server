INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Queen', 'Queen');

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (2, '5441c29d-3602-4898-b1a1-b77fa23b8e50', 'David Bowie', 'David Bowie');

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (3, '5f9913b0-7219-11de-8a39-0800200c9a66', 'Merge', 'Merge');

INSERT INTO artist_credit (id, name, artist_count, gid)
VALUES (1, 'Queen & David Bowie', 2, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7'),
       (2, 'Queen & Bowie', 2, 'c44109ce-57d7-3691-84c8-37926e3d41d2');

INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
VALUES (1, 0, 1, 'Queen', ' & '),
       (1, 1, 2, 'David Bowie', ''),
       (2, 0, 1, 'Queen', ' & '),
       (2, 1, 2, 'Bowie', '');
