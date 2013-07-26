SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

--------------------------------------------------------------------------------
-- Test setup. See below for tests.
INSERT INTO artist_name (id, name) VALUES (1, 'blah');
INSERT INTO artist (id, gid, name, sort_name)
VALUES (1, 'a4f27229-557b-4b32-be83-06a309903314', 1, 1);

INSERT INTO area (id, gid, name, sort_name)
VALUES (1, '8939baa6-d3ce-4355-8a6c-bb8345e44d45', 'A', 'A');

SELECT is( 'SELECT ended FROM artist WHERE id = 1', false);

UPDATE artist SET end_area = 1 WHERE id = 1;

SELECT is( 'SELECT ended FROM artist WHERE id = 1', true);

UPDATE artist SET end_area = null WHERE id = 1;

SELECT is( 'SELECT ended FROM artist WHERE id = 1', true);

UPDATE artist SET ended = null WHERE id = 1;

SELECT is( 'SELECT ended FROM artist WHERE id = 1', false);

SELECT finish();
ROLLBACK;

