SET client_min_messages TO 'WARNING';

INSERT INTO artist_type (id, name) VALUES (1, 'Person');
INSERT INTO artist_type (id, name) VALUES (2, 'Group');
INSERT INTO artist_type (id, name) VALUES (3, 'Special MusicBrainz Artist');

INSERT INTO artist_name (id, name) VALUES (1, 'Various Artists');
INSERT INTO artist_name (id, name) VALUES (2, 'Deleted Artist');

INSERT INTO artist (id, gid, name, sort_name, type) VALUES
    (1, '89ad4ac3-39f7-470e-963a-56509c546377', 1, 1, 3);

INSERT INTO artist (id, gid, name, sort_name, type) VALUES
    (2, 'c06aa285-520e-40c0-b776-83d2c9e8a6d1', 2, 2, 3);

INSERT INTO label_type (id, name) VALUES (2, 'Special MusicBrainz Label');
INSERT INTO label_name (id, name) VALUES (1, 'Deleted Label');
INSERT INTO label (id, gid, name, sort_name, type) VALUES
    (1, 'f43e252d-9ebf-4e8e-bba8-36d080756cc1', 1, 1, 2);

SET client_min_messages TO 'NOTICE';

