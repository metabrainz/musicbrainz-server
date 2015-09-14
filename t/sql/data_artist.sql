SET client_min_messages TO 'WARNING';

INSERT INTO area_type (id, name) VALUES (1, 'Country');
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

INSERT INTO artist (id, gid, name, sort_name) VALUES
    (4, '945c079d-374e-4436-9448-da92dedef3cf', 'Minimal Artist', 'Minimal Artist'),
    (5, 'dc19b13a-5ca5-44f5-8f0e-0c37a8ab1958', 'Annotated Artist A', 'Annotated Artist A'),
    (6, 'ca4c2228-227c-4904-932a-dff442c091ea', 'Annotated Artist B', 'Annotated Artist B');

UPDATE artist_meta SET rating=70, rating_count=4 WHERE id=3;

INSERT INTO annotation (id, editor, text) VALUES (1, 1, 'Test annotation 1');
INSERT INTO annotation (id, editor, text) VALUES (2, 1, 'Test annotation 2');
INSERT INTO annotation (id, editor, text) VALUES (3, 1, 'Duplicate annotation');
INSERT INTO annotation (id, editor, text) VALUES (4, 1, 'Duplicate annotation');

INSERT INTO artist_annotation (artist, annotation) VALUES (3, 1), (4, 2), (5, 3), (6, 4);

INSERT INTO artist_gid_redirect VALUES ('a4ef1d08-962e-4dd6-ae14-e42a6a97fc11', 3);
