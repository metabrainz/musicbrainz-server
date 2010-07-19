BEGIN;
SET client_min_messages TO 'WARNING';

TRUNCATE artist_credit CASCADE;
TRUNCATE recording CASCADE;

TRUNCATE artist_type CASCADE;
INSERT INTO artist_type (id, name) VALUES (1, 'Person');
INSERT INTO artist_type (id, name) VALUES (2, 'Group');

TRUNCATE artist_name CASCADE;
INSERT INTO artist_name (id, name) VALUES (1, 'Test Artist');
INSERT INTO artist_name (id, name) VALUES (2, 'Artist, Test');
INSERT INTO artist_name (id, name) VALUES (3, 'Minimal Artist');

TRUNCATE country CASCADE;
INSERT INTO country (id, isocode, name) VALUES (1, 'GB', 'United Kingdom');
INSERT INTO country (id, isocode, name) VALUES (2, 'US', 'United States');

TRUNCATE gender CASCADE;
INSERT INTO gender (id, name) VALUES (1, 'Male');
INSERT INTO gender (id, name) VALUES (2, 'Female');

TRUNCATE artist CASCADE;
INSERT INTO artist
    (id, gid, name, sortname, type, gender, country,
     begindate_year, begindate_month, begindate_day,
     enddate_year, enddate_month, enddate_day, comment)
    VALUES
    (1, '745c079d-374e-4436-9448-da92dedef3ce', 1, 2, 1, 1, 1,
     2008, 01, 02, 2009, 03, 04, 'Yet Another Test Artist');

INSERT INTO artist (id, gid, name, sortname, quality)
       VALUES (2, '945c079d-374e-4436-9448-da92dedef3cf', 3, 3, 0);

UPDATE artist_meta SET rating=70, ratingcount=4, lastupdate='2009-07-09 20:40:30' WHERE id=1;

ALTER SEQUENCE artist_name_id_seq RESTART 3;

TRUNCATE annotation CASCADE;
TRUNCATE artist_annotation CASCADE;
TRUNCATE editor CASCADE;

INSERT INTO editor (id, name, password) VALUES (1, 'editor', 'pass');

INSERT INTO annotation (id, editor, text) VALUES (1, 1, 'Test annotation 1');
INSERT INTO annotation (id, editor, text) VALUES (2, 1, 'Test annotation 2');

INSERT INTO artist_annotation (artist, annotation) VALUES (1, 1);
INSERT INTO artist_annotation (artist, annotation) VALUES (2, 2);

TRUNCATE artist_gid_redirect CASCADE;
INSERT INTO artist_gid_redirect VALUES ('a4ef1d08-962e-4dd6-ae14-e42a6a97fc11', 1);

ALTER SEQUENCE artist_name_id_seq RESTART 4;
ALTER SEQUENCE artist_id_seq RESTART 3;

COMMIT;
