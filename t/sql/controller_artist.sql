BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE annotation CASCADE;
TRUNCATE artist CASCADE;
TRUNCATE artist_alias CASCADE;
TRUNCATE artist_annotation CASCADE;
TRUNCATE artist_credit CASCADE;
TRUNCATE artist_credit_name CASCADE;
TRUNCATE artist_name CASCADE;
TRUNCATE artist_type CASCADE;
TRUNCATE country CASCADE;
TRUNCATE editor CASCADE;
TRUNCATE gender CASCADE;
TRUNCATE recording CASCADE;
TRUNCATE release CASCADE;
TRUNCATE release_group CASCADE;
TRUNCATE release_group_type CASCADE;
TRUNCATE release_name CASCADE;
TRUNCATE tag CASCADE;
TRUNCATE track_name CASCADE;
TRUNCATE work CASCADE;
TRUNCATE work_type CASCADE;
TRUNCATE work_name CASCADE;

INSERT INTO country (id, isocode, name) VALUES
    (1, 'GB', 'United Kingdom'),
    (2, 'US', 'United States');

INSERT INTO gender (id, name) VALUES (1, 'Male'), (2, 'Female');

INSERT INTO artist_name (id, name) VALUES
    (1, 'Test Artist'),
    (2, 'Artist, Test'),
    (3, 'Empty Artist'),
    (4, 'Test Alias');

INSERT INTO artist_type (id, name) VALUES (1, 'Person');
INSERT INTO artist
    (id, gid, name, sortname, type, gender, country,
     begindate_year, begindate_month, begindate_day,
     enddate_year, enddate_month, enddate_day, comment)
    VALUES
    (3, '745c079d-374e-4436-9448-da92dedef3ce', 1, 2, 1, 1, 1,
     2008, 01, 02, 2009, 03, 04, 'Yet Another Test Artist');

UPDATE artist_meta SET rating=70, ratingcount=4, lastupdate='2009-07-09 20:40:30' WHERE id = 3;

INSERT INTO artist (id, gid, name, sortname) VALUES
    (4, '60e5d080-c964-11de-8a39-0800200c9a66', 3, 3);

INSERT INTO artist_alias (id, name, artist, editpending)
    VALUES (1, 4, 3, 2);

INSERT INTO artist_credit (id, artistcount) VALUES (1, 1);
INSERT INTO artist_credit_name (artist_credit, position, artist, name, joinphrase) VALUES (1, 1, 3, 1, NULL);

INSERT INTO release_group_type (id, name) VALUES (1, 'Album');

INSERT INTO release_name (id, name)
    VALUES (1, 'Test RG 1'),
           (2, 'Test RG 2'),
           (3, 'Test Release');

INSERT INTO release_group (id, gid, name, artist_credit, type) VALUES
    (1, 'ecc33260-454c-11de-8a39-0800200c9a66', 1, 1, 1),
    (2, '7348f3a0-454e-11de-8a39-0800200c9a66', 2, 1, 1);

INSERT INTO release (id, gid, name, artist_credit, release_group, date_year,
                     date_month, date_day) VALUES
    (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 3, 1, 1, 2009, 5, 8);

INSERT INTO editor (id, name, password) VALUES (1, 'new_editor', 'password');

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
INSERT INTO work (id, gid, name, artist_credit, type, iswc) VALUES
    (1, '745c079d-374e-4436-9448-da92dedef3ce', 1, 1, 1, 'T-000.000.001-0');


TRUNCATE TABLE link_attribute_type CASCADE;

INSERT INTO link_attribute_type (id, root, gid, name)
    VALUES (1, 1, '36990974-4f29-4ea1-b562-3838fa9b8832', 'additional');
INSERT INTO link_attribute_type (id, root, gid, name)
    VALUES (2, 2, '108d76bd-95eb-4099-aed6-447e4ec78553', 'instrument');
INSERT INTO link_attribute_type (id, parent, root, gid, name)
    VALUES (3, 2, 2, '4f7bb10f-396c-466a-8221-8e93f5e454f9', 'String Instruments');
INSERT INTO link_attribute_type (id, parent, root, gid, name)
    VALUES (4, 3, 2, 'c3273296-91ba-453d-94e4-2fb6e958568e', 'Guitar');

TRUNCATE TABLE link_type CASCADE;

INSERT INTO link_type (id, gid, entitytype0, entitytype1, name, linkphrase, rlinkphrase, shortlinkphrase)
    VALUES (1, '7610b0e9-40c1-48b3-b06c-2c1d30d9dc3e', 'artist', 'recording', 'instrument',
            'performed {additional} {instrument} on',
            'has {additional} {instrument} performed by',
            'performer');

TRUNCATE TABLE link_type_attribute_type CASCADE;

INSERT INTO link_type_attribute_type (link_type, attribute_type, min, max)
    VALUES (1, 1, 0, 1);
INSERT INTO link_type_attribute_type (link_type, attribute_type, min, max)
    VALUES (1, 2, 1, NULL);

TRUNCATE TABLE link CASCADE;

INSERT INTO link (id, link_type, attributecount) VALUES (1, 1, 1);
INSERT INTO link (id, link_type, attributecount) VALUES (2, 1, 2);

TRUNCATE TABLE link_attribute CASCADE;

INSERT INTO link_attribute (link, attribute_type) VALUES (1, 4);
INSERT INTO link_attribute (link, attribute_type) VALUES (2, 1);
INSERT INTO link_attribute (link, attribute_type) VALUES (2, 3);

TRUNCATE TABLE l_artist_recording CASCADE;

INSERT INTO l_artist_recording (id, link, entity0, entity1) VALUES (1, 1, 3, 1);

INSERT INTO tag (id, name) VALUES (1, 'musical'), (2, 'not-used');
INSERT INTO artist_tag (tag, artist, count) VALUES (1, 3, 2);

ALTER SEQUENCE artist_alias_id_seq RESTART 2;
ALTER SEQUENCE annotation_id_seq RESTART 2;
ALTER SEQUENCE tag_id_seq RESTART 3;

COMMIT;