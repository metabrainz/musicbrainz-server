BEGIN;
SET client_min_messages TO 'WARNING';

TRUNCATE country CASCADE;

INSERT INTO country (id, iso_code, name) VALUES (1, 'GB', 'United Kingdom');
INSERT INTO country (id, iso_code, name) VALUES (2, 'US', 'United States');

COMMIT;
