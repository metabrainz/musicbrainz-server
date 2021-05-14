SET client_min_messages TO 'warning';

INSERT INTO artist (id, gid, name, sort_name, comment)
    VALUES (1, '82a72730-792f-11de-8a39-0800200c9a66', 'Tosca', 'Tosca', 'Tosca 1'),
           (2, '92a72730-792f-11de-8a39-0800200c9a66', 'Tosca', 'Tosca', 'Tosca 2');

INSERT INTO artist_credit (id, name, artist_count, gid)
    VALUES (1, 'Tosca', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');
INSERT INTO artist_credit_name (artist_credit, position, name, artist) VALUES (1, 1, 'Tosca', 1);

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, 'a037f860-792f-11de-8a39-0800200c9a66', 'RG', 1);

INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (1, '6a7d1660-792f-11de-8a39-0800200c9a66', 'No Hassle', 1, 1);

INSERT INTO recording (id, gid, name, artist_credit)
    VALUES (1, 'a037f860-792f-11de-8a39-0800200c9a66', 'Track', 1);
