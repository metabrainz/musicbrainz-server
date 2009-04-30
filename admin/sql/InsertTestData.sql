BEGIN;

TRUNCATE artist_type;

INSERT INTO artist_type (id, name) VALUES (1, 'Person');
INSERT INTO artist_type (id, name) VALUES (2, 'Group');

TRUNCATE country;

INSERT INTO country (id, isocode, name) VALUES (1, 'GB', 'United Kingdom');
INSERT INTO country (id, isocode, name) VALUES (2, 'US', 'United States');

TRUNCATE gender;

INSERT INTO gender (id, name) VALUES (1, 'Male');
INSERT INTO gender (id, name) VALUES (2, 'Female');

COMMIT;