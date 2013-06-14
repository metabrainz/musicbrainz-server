
SET client_min_messages TO 'WARNING';

INSERT INTO artist_type (id, name) VALUES (1, 'Person');
INSERT INTO artist_type (id, name) VALUES (2, 'Group');

INSERT INTO artist_name (id, name) VALUES (1, 'Test Artist');
INSERT INTO artist_name (id, name) VALUES (2, 'Artist, Test');
INSERT INTO artist_name (id, name) VALUES (3, 'Minimal Artist');

INSERT INTO area_type (id, name) VALUES (1, 'Country');
INSERT INTO area (id, gid, name, sort_name, type) VALUES
  (221, '8a754a16-0027-3a29-b6d7-2b40ea0481ed', 'United Kingdom', 'United Kingdom', 1),
  (222, '489ce91b-6658-3307-9877-795b68554c98', 'United States', 'United States', 1);
INSERT INTO country_area (area) VALUES (221), (222);
INSERT INTO iso_3166_1 (area, code) VALUES (221, 'GB'), (222, 'US');

INSERT INTO gender (id, name) VALUES (1, 'Male');
INSERT INTO gender (id, name) VALUES (2, 'Female');

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

INSERT INTO artist (id, gid, name, sort_name)
       VALUES (4, '945c079d-374e-4436-9448-da92dedef3cf', 3, 3);

UPDATE artist_meta SET rating=70, rating_count=4 WHERE id=3;

INSERT INTO annotation (id, editor, text) VALUES (1, 1, 'Test annotation 1');
INSERT INTO annotation (id, editor, text) VALUES (2, 1, 'Test annotation 2');

INSERT INTO artist_annotation (artist, annotation) VALUES (3, 1);
INSERT INTO artist_annotation (artist, annotation) VALUES (4, 2);

INSERT INTO artist_gid_redirect VALUES ('a4ef1d08-962e-4dd6-ae14-e42a6a97fc11', 3);

ALTER SEQUENCE artist_name_id_seq RESTART 4;
ALTER SEQUENCE artist_id_seq RESTART 5;
ALTER SEQUENCE annotation_id_seq RESTART 3;

