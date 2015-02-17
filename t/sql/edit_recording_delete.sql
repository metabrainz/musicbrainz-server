SET client_min_messages TO 'warning';

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Name', 'Name');
INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 'Name', 1);
INSERT INTO artist_credit_name (artist_credit, name, artist, position) VALUES (1, 'Name', 1, 1);

INSERT INTO recording (id, name, artist_credit, gid)
    VALUES (1, 'Rondo Acapricio', 1, '945c079d-374e-4436-9448-da92dedef3cf');
