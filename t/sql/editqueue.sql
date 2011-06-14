
SET client_min_messages TO 'WARNING';





INSERT INTO editor (id, name, password) VALUES
    (1, 'editor1', 'pass'),
    (2, 'editor2', 'pass'),
    (3, 'editor3', 'pass'),
    (4, 'editor4', 'pass');

SELECT setval('label_id_seq', 99);

INSERT INTO artist_name (id, name) VALUES (1, 'Artist 1'), (2, 'Artist 2');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (3, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1),
           (4, '5441c29d-3602-4898-b1a1-b77fa23b8e50', 2, 2);

