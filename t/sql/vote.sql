BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE editor CASCADE;

INSERT INTO editor (id, name, password) VALUES
    (1, 'editor1', 'pass'), (2, 'editor2', 'pass');

COMMIT;
