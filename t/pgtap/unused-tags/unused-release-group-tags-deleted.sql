SET search_path = 'musicbrainz', 'public';

--------------------------------------------------------------------------------
BEGIN;
SELECT no_plan();

INSERT INTO artist_credit (id, artist_count, name, gid)
  VALUES (1, 1, 'Artist', '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');

INSERT INTO release_group (id, gid, name, artist_credit)
  VALUES (1, '82ac9811-db47-4c05-9792-83cf4208afd0', 'Release group', 1),
         (2, '9baea67a-8d86-422d-b653-b0f6d0a93c7c', 'Release group', 1);

INSERT INTO tag (id, name) VALUES (2, 'Unused tag'), (4, 'Used tag'), (5, 'Shared tag');
INSERT INTO release_group_tag (release_group, tag, count) VALUES
  (1, 2, 1), (1, 4, 1), (1, 5, 1), (2, 5, 1);

-- Delete tag before commit to test AFTER INSERT ON tag trigger
DELETE FROM release_group_tag WHERE tag = 2;

-- Deleting but the re-adding should not garbage collect
DELETE FROM release_group_tag WHERE tag = 4;
INSERT INTO release_group_tag (release_group, tag, count) VALUES (1, 4, 1);

DELETE FROM release_group_tag WHERE tag = 5 AND release_group = 1;

SELECT set_eq(
  'SELECT id FROM tag', '{2, 4, 5}'::INT[],
  'Tag exists before commit'
);

-- Simulate the commit
SET CONSTRAINTS ALL IMMEDIATE;

SELECT set_eq(
  'SELECT id FROM tag', '{4, 5}'::INT[],
  'Tag deleted after commit by AFTER INSERT ON tag'
);

-- Delete tag after commit to test AFTER DELETE ON release_group_tag trigger
DELETE FROM release_group_tag WHERE tag = 5;

SELECT set_eq(
  'SELECT id FROM tag', '{4}'::INT[],
  'Tag deleted after commit by AFTER DELETE ON release_group_tag');

SELECT finish();
ROLLBACK;
