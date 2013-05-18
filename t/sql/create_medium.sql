SET client_min_messages TO 'warning';

INSERT INTO artist_name (id, name) VALUES (1, 'Tosca');
INSERT INTO artist (id, gid, name, sort_name, comment)
    VALUES (1, '82a72730-792f-11de-8a39-0800200c9a66', 1, 1, 'Tosca 1'),
           (2, '92a72730-792f-11de-8a39-0800200c9a66', 1, 1, 'Tosca 2');

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, position, name, artist) VALUES (1, 1, 1, 1);

INSERT INTO release_name (id, name) VALUES (1, 'No Hassle');
INSERT INTO release_name (id, name) VALUES (2, 'RG');

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, 'a037f860-792f-11de-8a39-0800200c9a66', 2, 1);

INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (1, '6a7d1660-792f-11de-8a39-0800200c9a66', 1, 1, 1);

INSERT INTO medium_format (id, name) VALUES (1, 'CD');

INSERT INTO track_name (id, name) VALUES (1, 'Track');
INSERT INTO recording (id, gid, name, artist_credit)
    VALUES (1, 'a037f860-792f-11de-8a39-0800200c9a66', 1, 1);

SELECT setval('artist_credit_id_seq', (SELECT MAX(id) FROM artist));
SELECT setval('artist_id_seq', (SELECT MAX(id) FROM artist));
SELECT setval('artist_name_id_seq', (SELECT MAX(id) FROM artist));
SELECT setval('recording_id_seq', (SELECT MAX(id) FROM recording));
SELECT setval('track_name_id_seq', (SELECT MAX(id) FROM track_name));
