SET client_min_messages TO 'warning';

INSERT INTO area_type (id, name) VALUES (1, 'Country');
INSERT INTO area (id, gid, name, sort_name, type) VALUES
  (221, '8a754a16-0027-3a29-b6d7-2b40ea0481ed', 'United Kingdom', 'United Kingdom', 1),
  (222, '489ce91b-6658-3307-9877-795b68554c98', 'United States', 'United States', 1);
INSERT INTO country_area (area) VALUES (221), (222);
INSERT INTO iso_3166_1 (area, code) VALUES (221, 'GB'), (222, 'US');

INSERT INTO gender (id, name) VALUES (1, 'Male'), (2, 'Female');

INSERT INTO artist_name (id, name) VALUES
    (1, 'Test Artist'),
    (2, 'Artist, Test'),
    (3, 'Empty Artist'),
    (4, 'Test Alias');

INSERT INTO artist_type (id, name) VALUES (1, 'Person');
INSERT INTO artist
    (id, gid, name, sort_name, type, gender, area,
     begin_area, end_area,
     begin_date_year, begin_date_month, begin_date_day,
     end_date_year, end_date_month, end_date_day, comment,
     last_updated)
    VALUES
    (3, '745c079d-374e-4436-9448-da92dedef3ce', 1, 2, 1, 1, 221, 221, 221,
     2008, 01, 02, 2009, 03, 04, 'Yet Another Test Artist',
     '2009-07-09');

UPDATE artist_meta SET rating=70, rating_count=4 WHERE id = 3;

INSERT INTO artist (id, gid, name, sort_name) VALUES
    (4, '60e5d080-c964-11de-8a39-0800200c9a66', 3, 3);

INSERT INTO artist_alias
    (id, name, sort_name, artist, edits_pending, begin_date_year, begin_date_month, begin_date_day,
     end_date_year, end_date_month, end_date_day)
    VALUES (1, 4, 4, 3, 2, 2000, 1, 1, 2005, 5, 6);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase) VALUES (1, 1, 3, 1, '');

INSERT INTO release_name (id, name)
    VALUES (1, 'Test RG 1'),
           (2, 'Test RG 2'),
           (3, 'Test Release');

INSERT INTO release_group (id, gid, name, artist_credit, type) VALUES
    (1, 'ecc33260-454c-11de-8a39-0800200c9a66', 1, 1, 1),
    (2, '7348f3a0-454e-11de-8a39-0800200c9a66', 2, 1, 1);

INSERT INTO release (id, gid, name, artist_credit, release_group) VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 3, 1, 1);
INSERT INTO release_unknown_country (release, date_year, date_month, date_day) VALUES (1, 2009, 5, 8);
;

-- A full editor
INSERT INTO editor (id, name, password, privs, email, website, bio, email_confirm_date, member_since, last_login_date, edits_accepted, edits_rejected, auto_edits_accepted, edits_failed, ha1) VALUES (1, 'new_editor', '{CLEARTEXT}password', 0, 'test@editor.org', 'http://musicbrainz.org', 'biography', '2005-10-20', '1989-07-23', now(), 12, 2, 59, 9, 'e1dd8fee8ee728b0ddc8027d3a3db478');

INSERT INTO editor (id, name, password, ha1) VALUES (2, 'alice', '{CLEARTEXT}password', '343cbae85500be826a413b9b6b242669');

-- Alice has private ratings.
INSERT INTO editor_preference (editor, name, value) VALUES (2, 'public_ratings', '0');

INSERT INTO annotation (id, editor, text) VALUES
    (1, 1, 'Test annotation 1' || chr(10) || chr(10) || 'More annotation');

INSERT INTO artist_annotation (artist, annotation) VALUES (3, 1);

INSERT INTO track_name (id, name) VALUES (1, 'Test Recording');
INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (1, '123c079d-374e-4436-9448-da92dedef3ce', 1, 1, 123456);

ALTER SEQUENCE artist_id_seq RESTART 5;
ALTER SEQUENCE artist_name_id_seq RESTART 5;

INSERT INTO work_type (id, name) VALUES (1, 'Composition');
INSERT INTO work_type (id, name) VALUES (2, 'Symphony');
INSERT INTO work_name (id, name) VALUES (1, 'Test Work');
INSERT INTO work (id, gid, name, type) VALUES
    (1, '745c079d-374e-4436-9448-da92dedef3ce', 1, 1);
INSERT INTO iswc (work, iswc) VALUES (1, 'T-000.000.001-0');

INSERT INTO link_attribute_type (id, root, gid, name)
    VALUES (1, 1, '36990974-4f29-4ea1-b562-3838fa9b8832', 'additional');
INSERT INTO link_attribute_type (id, root, gid, name)
    VALUES (2, 2, '108d76bd-95eb-4099-aed6-447e4ec78553', 'instrument');
INSERT INTO link_attribute_type (id, parent, root, gid, name)
    VALUES (3, 2, 2, '4f7bb10f-396c-466a-8221-8e93f5e454f9', 'String Instruments');
INSERT INTO link_attribute_type (id, parent, root, gid, name)
    VALUES (4, 3, 2, 'c3273296-91ba-453d-94e4-2fb6e958568e', 'Guitar');

INSERT INTO link_type (id, gid, entity_type0, entity_type1, name, link_phrase, reverse_link_phrase, long_link_phrase)
    VALUES (1, '7610b0e9-40c1-48b3-b06c-2c1d30d9dc3e', 'artist', 'recording', 'instrument',
            'performed {additional} {instrument} on',
            'has {additional} {instrument} performed by',
            'performer');

INSERT INTO link_type (id, gid, entity_type0, entity_type1, name, link_phrase, reverse_link_phrase, long_link_phrase)
    VALUES (2, 'a610b0e9-40c1-48b3-b06c-2c1d30d9dc3e', 'artist', 'work', 'instrument',
            'performed {additional} {instrument} on',
            'has {additional} {instrument} performed by',
            'performer');

INSERT INTO link_type_attribute_type (link_type, attribute_type, min, max)
    VALUES (1, 1, 0, 1);

INSERT INTO link_type_attribute_type (link_type, attribute_type, min, max)
    VALUES (1, 2, 1, NULL);

INSERT INTO link (id, link_type, attribute_count) VALUES (1, 1, 1);
INSERT INTO link (id, link_type, attribute_count) VALUES (2, 1, 2);
INSERT INTO link (id, link_type, attribute_count) VALUES (3, 2, 0);


INSERT INTO link_attribute (link, attribute_type) VALUES (1, 4);
INSERT INTO link_attribute (link, attribute_type) VALUES (2, 1);
INSERT INTO link_attribute (link, attribute_type) VALUES (2, 3);



INSERT INTO l_artist_recording (id, link, entity0, entity1) VALUES (1, 1, 3, 1);
INSERT INTO l_artist_work (id, link, entity0, entity1) VALUES (1, 2, 3, 1);

INSERT INTO tag (id, name) VALUES (1, 'musical'), (2, 'not-used');
INSERT INTO artist_tag (tag, artist, count) VALUES (1, 3, 2);

ALTER SEQUENCE artist_alias_id_seq RESTART 2;
ALTER SEQUENCE annotation_id_seq RESTART 2;
ALTER SEQUENCE tag_id_seq RESTART 3;


