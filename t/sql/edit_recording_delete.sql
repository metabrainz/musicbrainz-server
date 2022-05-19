SET client_min_messages TO 'warning';

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Name', 'Name');
INSERT INTO artist_credit (id, name, artist_count, gid)
    VALUES (1, 'Name', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');
INSERT INTO artist_credit_name (artist_credit, name, artist, position) VALUES (1, 'Name', 1, 1);

INSERT INTO recording (id, name, artist_credit, gid)
    VALUES (1, 'Rondo Acapricio', 1, '36401afe-819e-4207-9777-a6741fb2b43c');
