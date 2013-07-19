SET client_min_messages TO 'warning';

INSERT INTO editor (id, name, password, privs, email, website, bio, member_since, email_confirm_date, last_login_date, edits_accepted, edits_rejected, auto_edits_accepted, edits_failed, ha1) VALUES (1, 'new_editor', '{CLEARTEXT}password', 1+8+32, 'test@email.com', 'http://test.website', 'biography', '1989-07-23', '2005-10-20', now(), 12, 2, 59, 9, 'e1dd8fee8ee728b0ddc8027d3a3db478'), (2, 'Alice', '{CLEARTEXT}secret1', 0, 'alice@example.com', 'http://example.com', 'second biography', '2007-07-23', '2007-10-20', '2009-12-05', 11, 3, 41, 8, '473045b48884c866cae27da3e4b5d618'), (3, 'kuno', '{CLEARTEXT}byld', 0, 'kuno@example.com', 'http://frob.nl', 'donation check test user', '2010-03-25', '2010-03-25', '2010-03-25', 0, 0, 0, 0, '7519d5878645b8944a03555ea66f1ac3');

INSERT INTO edit (id, editor, type, status, data, expire_time)
    VALUES (2, 1, 123, 1, '{ "key": "value" }', NOW());

INSERT INTO edit (id, editor, type, status, data, expire_time)
    VALUES (3, 2, 123, 1, '{ "key": "value" }', NOW());

INSERT INTO edit (id, editor, type, status, data, expire_time)
    VALUES (4, 1, 123, 1, '{ "key": "value" }', NOW());

INSERT INTO edit (id, editor, type, status, data, expire_time)
    VALUES (5, 2, 123, 2, '{ "key": "value" }', NOW());

INSERT INTO edit (id, editor, type, status, data, expire_time)
    VALUES (6, 3, 123, 1, '{ "key": "value" }', NOW());

INSERT INTO artist_name (id, name) VALUES (1, 'artist');
INSERT INTO artist (id, gid, name, sort_name, comment)
    VALUES (1, '145c079d-374e-4436-9448-da92dedef3cf', 1, 1, 'Artist 1'),
           (2, '245c079d-374e-4436-9448-da92dedef3cf', 1, 1, 'Artist 2'),
           (3, '345c079d-374e-4436-9448-da92dedef3cf', 1, 1, 'Artist 3'),
           (4, '445c079d-374e-4436-9448-da92dedef3cf', 1, 1, 'Artist 4');

INSERT INTO label_name (id, name) VALUES (1, 'label');
INSERT INTO label (id, gid, name, sort_name)
    VALUES (1, '145c079d-374e-4436-9448-da92dedef3cf', 1, 1);

INSERT INTO edit_artist (edit, artist) VALUES (1, 1);
INSERT INTO edit_artist (edit, artist) VALUES (4, 1);
INSERT INTO edit_artist (edit, artist) VALUES (4, 2);
INSERT INTO edit_label (edit, label) VALUES (2, 1);

INSERT INTO language (frequency, iso_code_1, iso_code_2t, name, id, iso_code_2b, iso_code_3) VALUES (2, 'de', 'deu', 'German', 145, 'ger', 'deu');

INSERT INTO release_packaging (id, name) VALUES (1, 'Jewel Case');

INSERT INTO artist_ipi (artist, ipi) VALUES (3, '00151894163');
INSERT INTO artist_isni (artist, isni) VALUES (3, '1422458635730476');
INSERT INTO label_ipi (label, ipi) VALUES (1, '00151894166');
INSERT INTO label_isni (label, isni) VALUES (1, '0000000106750994');

INSERT INTO editor (id, name, password, privs, email, website, bio, email_confirm_date, member_since, last_login_date, edits_accepted, edits_rejected, auto_edits_accepted, edits_failed, ha1) VALUES (10, 'caa_editor', '{CLEARTEXT}password', 0, 'test@editor.org', 'http://musicbrainz.org', 'biography', '2005-10-20', '1989-07-23', now(), 12, 2, 59, 9, 'a0f97d2b669b73949f14743e885a8a4b');

INSERT INTO artist_name (id, name) VALUES (155, 'Artist');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (155, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1);

INSERT INTO artist_credit (id, name, artist_count) VALUES (155, 155, 1);
INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
    VALUES (155, 0, 155, 155, '');

INSERT INTO release_name (id, name) VALUES (155, 'Release');
INSERT INTO release_group (id, gid, name, artist_credit)
  VALUES (155, '54b9d183-7dab-42ba-94a3-7388a66604b8', 155, 155);
INSERT INTO release (id, gid, name, artist_credit, release_group)
  VALUES (155, '14b9d183-7dab-42ba-94a3-7388a66604b8', 155, 155, 155);

INSERT INTO edit (id, editor, type, data, status, expire_time) VALUES (130, 10, 316, '', 2, now());
INSERT INTO cover_art_archive.cover_art (id, release, mime_type, edit, ordering) VALUES (12345, 155, 'image/jpeg', 130, 1);

SELECT setval('edit_id_seq', (SELECT max(id) FROM edit));
