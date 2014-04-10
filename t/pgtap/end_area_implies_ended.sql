SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

--------------------------------------------------------------------------------
-- Test setup. See below for tests.
INSERT INTO artist (id, gid, name, sort_name)
VALUES (10, 'a4f27229-557b-4b32-be83-06a309903314', 'blah', 'blah');

INSERT INTO area (id, gid, name)
VALUES (1, '8939baa6-d3ce-4355-8a6c-bb8345e44d45', 'A');

SELECT is( (SELECT ended FROM artist WHERE id = 10), false);

UPDATE artist SET end_area = 1 WHERE id = 10;

SELECT is( (SELECT ended FROM artist WHERE id = 10), true);

UPDATE artist SET end_area = null WHERE id = 10;

SELECT is( (SELECT ended FROM artist WHERE id = 10), true);

UPDATE artist SET ended = false WHERE id = 10;

SELECT is( (SELECT ended FROM artist WHERE id = 10), false);

SELECT finish();
ROLLBACK;

