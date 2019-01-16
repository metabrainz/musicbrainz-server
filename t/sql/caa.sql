INSERT INTO editor (id, name, password, privs, email, website, bio, email_confirm_date, member_since, last_login_date, ha1) VALUES (10, 'caa_editor', '{CLEARTEXT}password', 0, 'test@editor.org', 'http://musicbrainz.org', 'biography', '2005-10-20', '1989-07-23', now(), 'a0f97d2b669b73949f14743e885a8a4b');

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Artist', 'Artist');

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 'Artist', 1);
INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
    VALUES (1, 0, 1, 'Artist', '');

INSERT INTO release_group (id, gid, name, artist_credit)
  VALUES (1, '54b9d183-7dab-42ba-94a3-7388a66604b8', 'Release', 1);
INSERT INTO release (id, gid, name, artist_credit, release_group)
  VALUES (1, '14b9d183-7dab-42ba-94a3-7388a66604b8', 'Release', 1, 1);

INSERT INTO edit (id, editor, type, status, expire_time) VALUES (1, 10, 316, 2, now());
INSERT INTO edit_data (edit, data) VALUES (1, '{}');
INSERT INTO cover_art_archive.cover_art (id, release, mime_type, edit, ordering) VALUES (12345, 1, 'image/jpeg', 1, 1);
INSERT INTO cover_art_archive.cover_art_type (id, type_id) VALUES (12345, 1);
