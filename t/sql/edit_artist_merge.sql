
SET client_min_messages TO 'warning';

INSERT INTO artist_name (id, name) VALUES (1, 'Artist');

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (3, 'da34a170-7f7f-11de-8a39-0800200c9a66', 1, 1),
           (4, 'e9f5fc80-7f7f-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO artist_ipi (artist, ipi) VALUES (3, '00151894163');
INSERT INTO artist_ipi (artist, ipi) VALUES (3, '00145958831');
INSERT INTO artist_ipi (artist, ipi) VALUES (4, '00145958831');
INSERT INTO artist_ipi (artist, ipi) VALUES (4, '00151894065');

