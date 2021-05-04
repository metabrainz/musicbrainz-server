INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 'Name', 'Name');

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 'Name', 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
    VALUES (1, 1, 'Name', 0, '');

INSERT INTO area (id, gid, name, type) VALUES
  (221, '8a754a16-0027-3a29-b6d7-2b40ea0481ed', 'United Kingdom', 1);
INSERT INTO country_area (area) VALUES (221);
INSERT INTO iso_3166_1 (area, code) VALUES (221, 'GB');

INSERT INTO release_group (id, gid, name, artist_credit, type, comment, edits_pending)
    VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 'Arrival', 1, 1, 'Comment', 2);

INSERT INTO release (id, gid, name, artist_credit, release_group, status, packaging, language, script, barcode, comment, edits_pending) VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 'Arrival', 1, 1, 1, 1, 145, 3, '731453398122', 'Comment', 2);
INSERT INTO release_country (release, country, date_year, date_month, date_day) VALUES (1, 221, 2009, 5, 8);
;

INSERT INTO release (id, gid, name, artist_credit, release_group) VALUES (2, '7a906020-72db-11de-8a39-0800200c9a66', 'Release #2', 1, 1);
;

INSERT INTO label (id, gid, name) VALUES (1, '00a23bd0-72db-11de-8a39-0800200c9a66', 'Label');

INSERT INTO release_label (id, release, label, catalog_number)
    VALUES (1, 1, 1, 'ABC-123'), (2, 1, 1, 'ABC-123-X');

INSERT INTO editor (id, name, password, privs, email, website, bio, email_confirm_date, member_since, last_login_date, ha1) VALUES (1, 'editor', '{CLEARTEXT}pass', 0, 'test@editor.org', 'http://musicbrainz.org', 'biography', '2005-10-20', '1989-07-23', now(), '3f3edade87115ce351d63f42d92a1834');
INSERT INTO annotation (id, editor, text, changelog) VALUES (1, 1, 'Annotation', 'change');
INSERT INTO release_annotation (release, annotation) VALUES (1, 1);

INSERT INTO release_gid_redirect (gid, new_id) VALUES ('71dc55d8-0fc6-41c1-94e0-85ff2404997d', 1);

INSERT INTO artist (id, gid, name, sort_name, comment)
    VALUES (2, '7a906020-72db-11de-8a39-0800200c9a66', 'Various Artists', 'Various Artists', ''),
           (3, '1a906020-72db-11de-8a39-0800200c9a66', 'Various Artists', 'Various Artists', 'Various Artists 2');
INSERT INTO artist_credit (id, name, artist_count) VALUES (2, 'Various Artists', 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase) VALUES (2, 2, 'Various Artists', 1, '');

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (2, '25b6fe30-ff5b-11de-8a39-0800200c9a66', 'Various Release', 2);
INSERT INTO release (id, gid, name, artist_credit, release_group) VALUES (3, '25b6fe30-ff5b-11de-8a39-0800200c9a66', 'Various Release', 2, 2);
;

INSERT INTO medium (id, track_count, release, position) VALUES (1, 1, 3, 1);
INSERT INTO recording (id, artist_credit, name, gid)
    VALUES (1, 2, 'Track on recording', 'b43eb990-ff5b-11de-8a39-0800200c9a66');
INSERT INTO track (id, gid, name, artist_credit, medium, position, number, recording)
    VALUES (1, '30f0fccd-602d-4fab-8d44-06536e596966', 'Track on recording', 1, 1, 1, 1, 1),
           (100, 'f9864eea-5455-4a8e-ad29-e0652cfe1452', 'Track on recording', 1, 1, 2, 2, 1);

-- test search ranking.
INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (3, 'ac9a0149-5bb7-3fec-b6ac-16eaa529a28c', 'Blues on Blonde on Blonde', 2);
INSERT INTO release (id, gid, name, artist_credit, release_group) VALUES (4, '6ef989ad-0158-4bbf-b446-c863d50cd6b6', 'Blues on Blonde on Blonde', 2, 3);
;

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (4, '329fb554-2a81-3d8a-8e22-ec2c66810019', 'Blonde on Blonde', 2);
INSERT INTO release (id, gid, name, artist_credit, release_group) VALUES (5, '538aff00-a009-4515-a064-11a6d5a502ee', 'Blonde on Blonde', 2, 3);
;

-- test merge strategies
INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (100, '7a14d050-759c-41c0-b7a0-71424d1b177a', 'Pregap?', 1),
           (101, '3a14d050-759c-41c0-b7a0-71424d1b177a', 'Empty Medium Merge', 2);
INSERT INTO release (id, gid, name, release_group, artist_credit)
    VALUES (6, '7a906020-72db-11de-8a39-0800200c9a70', 'The Prologue (disc 1)', 1, 1),
           (7, '7a906020-72db-11de-8a39-0800200c9a71', 'The Prologue (disc 2)', 1, 1),
           (8, '7a906020-72db-11de-8a39-0800200c9a72', 'Subversion EP (disc 1)', 1, 1),
           (9, '7a906020-72db-11de-8a39-0800200c9a73', 'Subversion EP (disc 2)', 1, 1),
           (100, '6b89a7f7-ac01-4b57-ab0a-381b10523b34', 'Pregap', 100, 1),
           (110, '94a44113-f3e7-4bf1-8d68-0d71922ac346', 'No pregap', 100, 1),
           (101, '3b89a7f7-ac01-4b57-ab0a-381b10523b34', 'One Empty Medium', 101, 2),
           (111, '34a44113-f3e7-4bf1-8d68-0d71922ac346', 'No Empty Mediums', 101, 2);
INSERT INTO recording (id, gid, name, artist_credit)
    VALUES (2, '50a772b0-f0cc-11df-98cf-0800200c9a66', 'Track on recording', 1),
           (3, '5d9cb570-f0cc-11df-98cf-0800200c9a66', 'Track on recording', 1),
           (4, '64cac850-f0cc-11df-98cf-0800200c9a66', 'Track on recording', 1),
           (5, '691ee030-f0cc-11df-98cf-0800200c9a66', 'Track on recording', 1);
INSERT INTO medium (id, release, track_count, position)
    VALUES (2, 6, 0, 1), (3, 7, 0, 1),
           (4, 8, 0, 1), (5, 9, 0, 1),
           (60, 100, 1, 1), (70, 110, 1, 1),
           (80, 101, 0, 1), (81, 101, 0, 2),
           (90, 111, 0, 1), (91, 111, 0, 2);
INSERT INTO track (id, gid, name, artist_credit, medium, position, number, recording)
    VALUES (2, 'd6de1f70-4a29-4cce-a35b-aa2b56265583', 'Track on recording', 1, 2, 1, 1, 2),
           (3, '929e5fb9-cfe7-4764-b3f6-80e056f0c1da', 'Track on recording', 1, 3, 1, 1, 3),
           (4, '7e489434-e293-44e9-9254-8dec56a0c0c6', 'Track on recording', 1, 4, 1, 1, 4),
           (5, 'a833f5c7-dd13-40ba-bb5b-dc4e35d2bb90', 'Track on recording', 1, 5, 1, 1, 5),
           (60, 'fb6e4cd4-fa17-434f-b6ce-d1622e6f3b82', 'Pregap', 1, 60, 0, '', 2),
           (70, '0f4846f2-f96b-4fc3-b979-5fce32f193e5', 'Not pregap', 1, 70, 1, '1', 2),
           (81, 'ab6e4cd4-fa17-434f-b6ce-d1622e6f3b82', 'A Track', 2, 81, 1, '1', 2),
           (90, 'bb6e4cd4-fa17-434f-b6ce-d1622e6f3b82', 'A Track', 2, 90, 1, '1', 2),
           (91, 'cb6e4cd4-fa17-434f-b6ce-d1622e6f3b82', 'Another Track', 2, 91, 1, '1', 2);

-- Test for searching by track artist
INSERT INTO artist_credit (id, name, artist_count) VALUES (3, 'Various Artists', 2);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
    VALUES (3, 2, 'Various Artists', 1, ''),
           (3, 3, 'Various Artists', 2, '');

-- Both releases contain tracks by artist 3
-- Release 10 is by artist 1 & 3. Release 11 is by artist 1
-- Therefore release 11 is the only VA release for artist 3
INSERT INTO release (id, gid, name, release_group, artist_credit) VALUES (10, '7b906020-72db-11de-8a39-0800200c9a70', 'The Prologue (disc 1)', 4, 3), (11, '7c906020-72db-11de-8a39-0800200c9a71', 'The Prologue (disc 2)', 4, 2);
;

INSERT INTO medium (id, release, track_count, position)
    VALUES (6, 10, 1, 1), (7, 11, 1, 1);
INSERT INTO track (id, gid, name, artist_credit, medium, position, number, recording)
    VALUES (6, '83b608d5-29e2-4aad-87f2-55a5b1a6b139', 'Track on recording', 3, 6, 1, 1, 2),
           (7, 'b98ad21e-b1fb-4036-912e-3737636d270c', 'Track on recording', 3, 7, 1, 1, 2);

-- release_meta
UPDATE release_meta SET cover_art_presence = 'present' WHERE id in (7, 8);
UPDATE release_meta SET cover_art_presence = 'darkened' WHERE id = 9;
