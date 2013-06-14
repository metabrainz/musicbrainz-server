
SET client_min_messages TO 'warning';

INSERT INTO artist_name (id, name) VALUES (1, 'Artist Name');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (2, '745c079d-374e-4436-9448-da92dedef3ce', 1, 1);

INSERT INTO gender (id, name) VALUES (1, 'Male');
INSERT INTO artist_type (id, name) VALUES (1, 'Group');

INSERT INTO area_type (id, name) VALUES (1, 'Country');
INSERT INTO area (id, gid, name, sort_name, type) VALUES
  (221, '8a754a16-0027-3a29-b6d7-2b40ea0481ed', 'United Kingdom', 'United Kingdom', 1);
INSERT INTO country_area (area) VALUES (221);
INSERT INTO iso_3166_1 (area, code) VALUES (221, 'GB');

ALTER SEQUENCE artist_name_id_seq RESTART 100;
ALTER SEQUENCE artist_id_seq RESTART 3;

