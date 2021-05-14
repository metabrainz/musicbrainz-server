SET client_min_messages TO 'warning';

INSERT INTO artist (id, gid, name, sort_name, comment)
    VALUES (3, 'da34a170-7f7f-11de-8a39-0800200c9a66', 'Old Artist', 'Old Artist', 'Artist 3'),
           (4, 'e9f5fc80-7f7f-11de-8a39-0800200c9a66', 'New Artist', 'New Artist', 'Artist 4'),
           (5, 'a7829255-ade4-4611-ac3f-07192d21a947', 'Another Old Artist', 'Another Old Artist', 'Artist 5');

INSERT INTO artist_ipi (artist, ipi) VALUES (3, '00151894163');
INSERT INTO artist_ipi (artist, ipi) VALUES (3, '00145958831');
INSERT INTO artist_ipi (artist, ipi) VALUES (4, '00145958831');
INSERT INTO artist_ipi (artist, ipi) VALUES (4, '00151894065');

INSERT INTO artist_isni (artist, isni) VALUES (3, '1422458635730476');
INSERT INTO artist_isni (artist, isni) VALUES (3, '0000000106750994');
INSERT INTO artist_isni (artist, isni) VALUES (3, '1422458635730477');
INSERT INTO artist_isni (artist, isni) VALUES (3, '0000000106750995');

INSERT INTO artist_credit (id, name, artist_count, gid)
    VALUES (101, 'Old Artist', 1, '4f5d90c2-808e-3d8e-bf3c-e1ec4ce0f702');
INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase) VALUES (101, 1, 3, 'Old Artist', '');

INSERT INTO recording (id, gid, name, artist_credit, length)
    VALUES (1, '123c079d-374e-4436-9448-da92dedef3ce', 'Test Recording', 101, 123456);

INSERT INTO link (id, link_type, attribute_count) VALUES (1, 156, 0);

INSERT INTO l_artist_recording (id, link, entity0, entity1) VALUES (1, 1, 3, 1);
