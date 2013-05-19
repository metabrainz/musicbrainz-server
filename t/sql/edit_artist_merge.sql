
SET client_min_messages TO 'warning';

INSERT INTO artist_name (id, name) VALUES (1, 'Artist');

INSERT INTO artist (id, gid, name, sort_name, comment)
    VALUES (3, 'da34a170-7f7f-11de-8a39-0800200c9a66', 1, 1, 'Artist 3'),
           (4, 'e9f5fc80-7f7f-11de-8a39-0800200c9a66', 1, 1, 'Artist 4');

INSERT INTO artist_ipi (artist, ipi) VALUES (3, '00151894163');
INSERT INTO artist_ipi (artist, ipi) VALUES (3, '00145958831');
INSERT INTO artist_ipi (artist, ipi) VALUES (4, '00145958831');
INSERT INTO artist_ipi (artist, ipi) VALUES (4, '00151894065');

INSERT INTO artist_isni (artist, isni) VALUES (3, '1422458635730476');
INSERT INTO artist_isni (artist, isni) VALUES (3, '0000000106750994');
INSERT INTO artist_isni (artist, isni) VALUES (3, '1422458635730477');
INSERT INTO artist_isni (artist, isni) VALUES (3, '0000000106750995');
