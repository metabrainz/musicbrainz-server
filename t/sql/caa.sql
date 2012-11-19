INSERT INTO
    editor ( id, name, password, privs, email, website, bio,
             email_confirm_date, member_since, last_login_date, edits_accepted, edits_rejected,
             auto_edits_accepted, edits_failed)
    VALUES ( 10, 'caa_editor', 'password', 0, 'test@editor.org', 'http://musicbrainz.org',
             'biography', '2005-10-20', '1989-07-23', '2009-01-01', 12, 2, 59, 9 );

INSERT INTO artist_name (id, name) VALUES (1, 'Artist');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
    VALUES (1, 0, 1, 1, '');

INSERT INTO release_name (id, name) VALUES (1, 'Release');
INSERT INTO release_group (id, gid, name, artist_credit)
  VALUES (1, '54b9d183-7dab-42ba-94a3-7388a66604b8', 1, 1);
INSERT INTO release (id, gid, name, artist_credit, release_group)
  VALUES (1, '14b9d183-7dab-42ba-94a3-7388a66604b8', 1, 1, 1);

INSERT INTO edit (id, editor, type, data, status, expire_time) VALUES (1, 10, 316, '', 2, now());
INSERT INTO cover_art_archive.cover_art (id, release, edit, ordering) VALUES (12345, 1, 1, 1);

ALTER SEQUENCE edit_id_seq RESTART 2;
