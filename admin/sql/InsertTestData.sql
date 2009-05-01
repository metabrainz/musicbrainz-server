BEGIN;

SET client_min_messages TO 'WARNING';

TRUNCATE artist_type CASCADE;

INSERT INTO artist_type (id, name) VALUES (1, 'Person');
INSERT INTO artist_type (id, name) VALUES (2, 'Group');

TRUNCATE country CASCADE;

INSERT INTO country (id, isocode, name) VALUES (1, 'GB', 'United Kingdom');
INSERT INTO country (id, isocode, name) VALUES (2, 'US', 'United States');

TRUNCATE gender CASCADE;

INSERT INTO gender (id, name) VALUES (1, 'Male');
INSERT INTO gender (id, name) VALUES (2, 'Female');

TRUNCATE artist CASCADE;
TRUNCATE artist_name CASCADE;

INSERT INTO artist_name (id, name, page) VALUES (1, 'Artist 1', 1234);
INSERT INTO artist_name (id, name, page) VALUES (2, 'The 2nd Artist', 1234);
INSERT INTO artist_name (id, name, page) VALUES (3, '2nd Artist, The', 1234);
INSERT INTO artist
    (id, gid, name, sortname, type, gender, country,
     begindate_year, begindate_month, begindate_day,
     enddate_year, enddate_month, enddate_day)
    VALUES
    (1, '745c079d-374e-4436-9448-da92dedef3ce', 1, 1, 1, 1, 1,
     2008, 01, 02, 2009, 03, 04);
INSERT INTO artist (id, gid, name, sortname, type, gender, country) VALUES
    (2, '745c079d-374e-4436-9448-da92dedef3cf', 2, 3, 1, 1, 1);

SET client_min_messages TO 'NOTICE';

COMMIT;