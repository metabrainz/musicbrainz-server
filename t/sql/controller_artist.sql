SET client_min_messages TO 'warning';

INSERT INTO area (id, gid, name, type) VALUES
  (221, '8a754a16-0027-3a29-b6d7-2b40ea0481ed', 'United Kingdom', 1),
  (222, '489ce91b-6658-3307-9877-795b68554c98', 'United States', 1);
INSERT INTO country_area (area) VALUES (221), (222);
INSERT INTO iso_3166_1 (area, code) VALUES (221, 'GB'), (222, 'US');

INSERT INTO artist
    (id, gid, name, sort_name, type, gender, area,
     begin_area, end_area,
     begin_date_year, begin_date_month, begin_date_day,
     end_date_year, end_date_month, end_date_day, comment,
     last_updated)
    VALUES
    (3, '745c079d-374e-4436-9448-da92dedef3ce', 'Test Artist', 'Artist, Test', 1, 1, 221, 221, 221,
     2008, 01, 02, 2009, 03, 04, 'Yet Another Test Artist',
     '2009-07-09');

UPDATE artist_meta SET rating=70, rating_count=4 WHERE id=3;

INSERT INTO artist (id, gid, name, sort_name) VALUES
    (4, '60e5d080-c964-11de-8a39-0800200c9a66', 'Empty Artist', 'Empty Artist'),
    (5, '089302a3-dda1-4bdf-b996-c2e941b5c41f', 'Seekrit Identity', 'Seekrit Identity');

INSERT INTO artist_alias
    (id, name, sort_name, artist, type, edits_pending, begin_date_year, begin_date_month, begin_date_day,
     end_date_year, end_date_month, end_date_day)
    VALUES (1, 'Test Alias', 'Test Alias', 3, 1, 2, 2000, 1, 1, 2005, 5, 6);

INSERT INTO artist_credit (id, name, artist_count, gid) VALUES (1, 'Test Artist', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');
INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase) VALUES (1, 1, 3, 'Test Artist', '');

INSERT INTO release_group (id, gid, name, artist_credit, type) VALUES
    (1, 'ecc33260-454c-11de-8a39-0800200c9a66', 'Test RG 1', 1, 1),
    (2, '7348f3a0-454e-11de-8a39-0800200c9a66', 'Test RG 2', 1, 1);

INSERT INTO release (id, gid, name, artist_credit, release_group) VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 'Test Release', 1, 1);
INSERT INTO release_unknown_country (release, date_year, date_month, date_day) VALUES (1, 2009, 5, 8);

-- A full editor
INSERT INTO editor (id, name, password, privs, email, website, bio, email_confirm_date, member_since, last_login_date, ha1) VALUES (1, 'new_editor', '{CLEARTEXT}password', 0, 'test@editor.org', 'http://musicbrainz.org', 'biography', '2005-10-20', '1989-07-23', now(), 'e1dd8fee8ee728b0ddc8027d3a3db478');

INSERT INTO editor (id, name, password, ha1) VALUES (2, 'alice', '{CLEARTEXT}password', '343cbae85500be826a413b9b6b242669');

-- Alice has private ratings.
INSERT INTO editor_preference (editor, name, value) VALUES (2, 'public_ratings', '0');

INSERT INTO annotation (id, editor, text) VALUES
    (1, 1, 'Test annotation 1' || chr(10) || chr(10) || 'More annotation');

INSERT INTO artist_annotation (artist, annotation) VALUES (3, 1);

INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (1, '123c079d-374e-4436-9448-da92dedef3ce', 'Test Recording', 1, 123456);

ALTER SEQUENCE artist_id_seq RESTART 5;

INSERT INTO work (id, gid, name, type) VALUES
    (1, '745c079d-374e-4436-9448-da92dedef3ce', 'Test Work', 1);
INSERT INTO iswc (work, iswc) VALUES (1, 'T-000.000.001-0');

INSERT INTO link (id, link_type, attribute_count) VALUES (1, 148, 1);
INSERT INTO link (id, link_type, attribute_count) VALUES (2, 148, 2);
INSERT INTO link (id, link_type, attribute_count) VALUES (3, 282, 0);
INSERT INTO link (id, link_type, attribute_count) VALUES (4, 108, 0);

INSERT INTO link_attribute (link, attribute_type) VALUES (1, 229);
INSERT INTO link_attribute (link, attribute_type) VALUES (2, 1);
INSERT INTO link_attribute (link, attribute_type) VALUES (2, 302);

INSERT INTO l_artist_artist (id, link, entity0, entity1) VALUES (1, 4, 3, 5);

INSERT INTO l_artist_recording (id, link, entity0, entity1) VALUES (1, 1, 3, 1);
INSERT INTO l_artist_work (id, link, entity0, entity1) VALUES (1, 2, 3, 1);

INSERT INTO tag (id, name) VALUES (1, 'musical'), (2, 'not-used');
INSERT INTO artist_tag (tag, artist, count) VALUES (1, 3, 2);
