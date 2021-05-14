SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

--------------------------------------------------------------------------------
-- Test setup. See below for tests.

INSERT INTO artist (gid, id, name, sort_name) VALUES ('678d88b2-87b0-403b-b63d-5da7465aecc3', 388, 'Led Zeppelin', 'Led Zeppelin');
INSERT INTO artist_credit (id, artist_count, name, ref_count, gid) VALUES (388, 1, 'Led Zeppelin', 9450, '94b69d88-4662-335d-a9a5-43d8aae6bf20');
INSERT INTO artist_credit_name (artist, artist_credit, join_phrase, name, position) VALUES (388, 388, '', 'Led Zeppelin', 0);
INSERT INTO release_group (id, gid, name, artist_credit) VALUES (1, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'blah', 388);
INSERT INTO release (id, gid, name, artist_credit, release_group) VALUES (1, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'blah', 388, 1);
INSERT INTO medium (id, release, position) VALUES (1, 1, 1), (2, 1, 2);

-- Ensure that medium updates work

SELECT lives_ok(
  'WITH new_positions (medium, position) AS (VALUES (1, 2), (2, 1))
   UPDATE medium set release = 1, position = new_positions.position
   FROM new_positions where medium.id = new_positions.medium;');

SELECT throws_ok(
  'WITH new_positions (medium, position) AS (VALUES (1, 1), (2, 1))
   UPDATE medium set release = 1, position = new_positions.position
   FROM new_positions where medium.id = new_positions.medium;');

SELECT finish();
ROLLBACK;
