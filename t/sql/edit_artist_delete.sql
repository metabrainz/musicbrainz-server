
SET client_min_messages TO 'warning';

INSERT INTO artist_name (id, name) VALUES (1, 'Name');

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (3, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1);

INSERT INTO track_name (id, name) VALUES (1, 'Rondo Acapricio');
INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, name, artist, position) VALUES (1, 1, 3, 1);
INSERT INTO recording (id, name, artist_credit, gid)
    VALUES (1, 1, 1, '945c079d-374e-4436-9448-da92dedef3cf');

INSERT INTO artist_ipi (artist, ipi) VALUES (3, '00151894163');
INSERT INTO artist_ipi (artist, ipi) VALUES (3, '00145958831');

INSERT INTO artist_isni (artist, isni) VALUES (3, '1422458635730476');
INSERT INTO artist_isni (artist, isni) VALUES (3, '0000000106750994');




