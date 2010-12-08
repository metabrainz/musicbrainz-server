BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE artist CASCADE;
TRUNCATE artist_name CASCADE;
TRUNCATE editor CASCADE;
TRUNCATE editor_watch_artist CASCADE;

INSERT INTO artist_name (id, name)
    VALUES (1, 'Spor'), (2, 'Break');

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '9637fb42-6289-445b-9e4f-5d3135d3b138', 1, 1),
           (2, '16062b24-e317-4fcf-a898-81c3ac025fb6', 2, 1);

INSERT INTO editor (id, name, password)
    VALUES (1, 'acid2', 'xxx');

INSERT INTO editor_watch_artist (editor, artist)
    VALUES (1, 1), (1, 2);

COMMIT;
