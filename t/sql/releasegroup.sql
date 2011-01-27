
SET client_min_messages TO 'warning';



















INSERT INTO artist_name (id, name) VALUES (1, 'Name');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
    VALUES (1, 1, 1, 0, NULL);

INSERT INTO release_name (id, name) VALUES (1, 'Release Group');
INSERT INTO release_name (id, name) VALUES (2, 'Release Name');
INSERT INTO release_name (id, name) VALUES (3, 'To Merge');

INSERT INTO release_group (id, gid, name, artist_credit, type, comment, edits_pending)
    VALUES (1, '7b5d22d0-72d7-11de-8a39-0800200c9a66', 1, 1, 1, 'Comment', 2);

INSERT INTO release_group (id, gid, name, artist_credit, type, comment, edits_pending)
    VALUES (2, '3b4faa80-72d9-11de-8a39-0800200c9a66', 2, 1, 1, 'Comment', 2);

INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (1, '4c767e70-72d8-11de-8a39-0800200c9a66', 2, 1, 1);

INSERT INTO editor (id, name, password) VALUES (1, 'editor', 'pass');
INSERT INTO annotation (id, editor, text, changelog) VALUES (1, 1, 'Annotation', 'change');
INSERT INTO release_group_annotation (release_group, annotation) VALUES (1, 1);

INSERT INTO release_group_gid_redirect (gid, new_id) VALUES ('77637e8c-be66-46ea-87b3-73addc722fc9', 1);

INSERT INTO artist_name (id, name) VALUES (2, 'Various Artists');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (2, '7a906020-72db-11de-8a39-0800200c9a66', 2, 2);
INSERT INTO artist_credit (id, name, artist_count) VALUES (2, 2, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase) VALUES (2, 2, 2, 1, NULL);

INSERT into release_name (id, name) VALUES (4, 'Various Release');
INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (3, '25b6fe30-ff5b-11de-8a39-0800200c9a66', 4, 2);
INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (3, '25b6fe30-ff5b-11de-8a39-0800200c9a66', 4, 2, 3);

INSERT INTO track_name (id, name) VALUES (1, 'Track on recording');
INSERT INTO tracklist (id, track_count) VALUES (1, 1);
INSERT INTO medium (id, tracklist, release, position) VALUES (1, 1, 3, 1);
INSERT INTO recording (id, artist_credit, name, gid)
    VALUES (1, 2, 1, 'b43eb990-ff5b-11de-8a39-0800200c9a66');
INSERT INTO track (id, name, artist_credit, tracklist, position, recording)
    VALUES (1, 1, 1, 1, 1, 1);

ALTER SEQUENCE release_name_id_seq RESTART 5;
ALTER SEQUENCE release_group_id_seq RESTART 4;


