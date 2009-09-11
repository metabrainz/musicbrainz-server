BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE editor CASCADE;

INSERT INTO editor (id, name, password, email) VALUES
    (1, 'editor1', 'pass', 'editor1@example.com'),
    (2, 'editor2', 'pass', 'editor2@example.com');

COMMIT;
