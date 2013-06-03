
SET client_min_messages TO 'WARNING';

INSERT INTO artist_name (id, name) VALUES (1, 'Artist 1');
INSERT INTO artist_name (id, name) VALUES (2, 'Artist 2');

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (3, 'e2a083a9-9942-4d6e-b4d2-8397320b95f7', 1, 1),
           (4, '2fed031c-0e89-406e-b9f0-3d192637907a', 2, 2);

INSERT INTO tag (id, name) VALUES
    (1, 'musical'),
    (2, 'rock'),
    (3, 'jazz'),
    (4, 'world music');

INSERT INTO artist_tag (tag, artist, count) VALUES
    (1, 3, 1),
    (2, 3, 3),
    (1, 4, 5),
    (2, 4, 3),
    (3, 4, 2),
    (4, 4, 1);

ALTER SEQUENCE tag_id_seq RESTART 200;


