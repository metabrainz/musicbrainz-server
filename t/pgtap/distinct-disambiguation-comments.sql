BEGIN;
SET search_path = musicbrainz, public;
SELECT no_plan();

--------------------------------------------------------------------------------
SELECT lives_ok(
  $$INSERT INTO artist (gid, name, sort_name) VALUES
      ('876188d4-8f59-4b19-8cff-d7bb5e516a86', 'Break', 'Break')$$,
  'Creating with a default comment is OK'
);

SELECT throws_ok(
  $$INSERT INTO artist (gid, name, sort_name) VALUES
      ('f73e142e-f884-4e80-b992-7004c3fa6bf0', 'Break', 'Break')$$,
  23505, 'duplicate key value violates unique constraint "artist_idx_uniq_name_comment"',
  'Cannot create other entities with a default comments and the same name'
);

SELECT lives_ok(
  $$INSERT INTO artist (gid, name, sort_name, comment) VALUES
      ('f73e142e-f884-4e80-b992-7004c3fa6bf0', 'Break', 'Break', 'Drum & bass')$$,
  'Can create other entities with the same name and a comment'
);

SELECT throws_ok(
  $$INSERT INTO artist (gid, name, sort_name, comment) VALUES
      ('bafd7a02-a690-4b67-93a6-ac465e1884fe', 'Break', 'Break', 'Drum & bass')$$,
  23505, 'duplicate key value violates unique constraint "artist_idx_uniq_name_comment"',
  'Cannot create other entities with the same name and a comment'
);

SELECT lives_ok(
  $$INSERT INTO artist (gid, name, sort_name, comment) VALUES
      ('d9d07146-32f3-4c8a-86ac-910e134fdb2f', 'Pendulum', 'Pendulum', 'Drum & bass')$$,
  'Can create entities with an existing comment with a different name');

--------------------------------------------------------------------------------
SELECT lives_ok(
  $$INSERT INTO label (gid, name, sort_name) VALUES
      ('876188d4-8f59-4b19-8cff-d7bb5e516a86', 'Revolution Records', 'Revolution Records')$$,
  'Creating with a default comment is OK'
);

SELECT throws_ok(
  $$INSERT INTO label (gid, name, sort_name) VALUES
      ('f73e142e-f884-4e80-b992-7004c3fa6bf0', 'Revolution Records', 'Revolution Records')$$,
  23505, 'duplicate key value violates unique constraint "label_idx_uniq_name_comment"',
  'Cannot create other entities with default comments and the same name'
);

SELECT lives_ok(
  $$INSERT INTO label (gid, name, sort_name, comment) VALUES
      ('f73e142e-f884-4e80-b992-7004c3fa6bf0', 'Revolution Records', 'Revolution Records', 'Drum & bass')$$,
  'Can create other entities with the same name and a comment'
);

SELECT throws_ok(
  $$INSERT INTO label (gid, name, sort_name, comment) VALUES
      ('bafd7a02-a690-4b67-93a6-ac465e1884fe', 'Revolution Records', 'Revolution Records', 'Drum & bass')$$,
  23505, 'duplicate key value violates unique constraint "label_idx_uniq_name_comment"',
  'Cannot create other entities with the same name and a comment'
);

SELECT lives_ok(
  $$INSERT INTO label (gid, name, sort_name, comment) VALUES
      ('d9d07146-32f3-4c8a-86ac-910e134fdb2f', 'Shogun Audio', 'Shogun Audio', 'Drum & bass')$$,
  'Can create entities with an existing comment with a different name');

SELECT finish();
ROLLBACK;
