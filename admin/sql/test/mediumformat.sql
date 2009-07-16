BEGIN;
SET client_min_messages TO 'WARNING';

TRUNCATE medium_format CASCADE;

INSERT INTO medium_format (id, name) VALUES (1, 'CD');
INSERT INTO medium_format (id, name) VALUES (2, 'Vinyl');

COMMIT;
