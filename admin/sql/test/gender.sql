BEGIN;
SET client_min_messages TO 'WARNING';

TRUNCATE gender CASCADE;

INSERT INTO gender (id, name) VALUES (1, 'Male');
INSERT INTO gender (id, name) VALUES (2, 'Female');

COMMIT;
