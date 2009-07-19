BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE annotation CASCADE;
TRUNCATE artist CASCADE;
TRUNCATE artist_credit CASCADE;
TRUNCATE artist_credit_name CASCADE;
TRUNCATE artist_name CASCADE;
TRUNCATE editor CASCADE;
TRUNCATE release CASCADE;
TRUNCATE release_group CASCADE;
TRUNCATE release_group_annotation CASCADE;
TRUNCATE release_group_gid_redirect CASCADE;
TRUNCATE release_name CASCADE;

INSERT INTO artist_name (id, name) VALUES (1, 'Name');
INSERT INTO artist (id, gid, name, sortname)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO artist_credit (id, artistcount) VALUES (1, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, joinphrase)
    VALUES (1, 1, 1, 0, NULL);

INSERT INTO release_name (id, name) VALUES (1, 'Release Group');
INSERT INTO release_name (id, name) VALUES (2, 'Release Name');
INSERT INTO release_name (id, name) VALUES (3, 'To Merge');

INSERT INTO release_group (id, gid, name, artist_credit, type, comment, editpending)
    VALUES (1, '7b5d22d0-72d7-11de-8a39-0800200c9a66', 1, 1, 1, 'Comment', 2);

INSERT INTO release_group (id, gid, name, artist_credit, type, comment, editpending)
    VALUES (2, '3b4faa80-72d9-11de-8a39-0800200c9a66', 2, 1, 1, 'Comment', 2);

INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (1, '4c767e70-72d8-11de-8a39-0800200c9a66', 2, 1, 1);

INSERT INTO editor (id, name, password) VALUES (1, 'editor', 'pass');
INSERT INTO annotation (id, editor, text, changelog) VALUES (1, 1, 'Annotation', 'change');
INSERT INTO release_group_annotation (release_group, annotation) VALUES (1, 1);

INSERT INTO release_group_gid_redirect (gid, newid) VALUES ('77637e8c-be66-46ea-87b3-73addc722fc9', 1);

ALTER SEQUENCE release_name_id_seq RESTART 4;
ALTER SEQUENCE release_group_id_seq RESTART 3;

COMMIT;
