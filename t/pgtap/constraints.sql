SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

--------------------------------------------------------------------------------
SELECT throws_ok('INSERT INTO artist_name (id, name) VALUES (1, ''James  Blake'')');
SELECT throws_ok('INSERT INTO artist_name (id, name) VALUES (1, '' James Blake'')');
SELECT throws_ok('INSERT INTO artist_name (id, name) VALUES (1, ''James Blake '')');
SELECT lives_ok ('INSERT INTO artist_name (id, name) VALUES (1, ''James Blake'')');

--------------------------------------------------------------------------------
SELECT throws_ok(
  'INSERT INTO artist (id, gid, name, sort_name, comment)
   VALUES (10, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', 1, 1, ''A  comment'')');
SELECT throws_ok(
  'INSERT INTO artist (id, gid, name, sort_name, comment)
   VALUES (10, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', 1, 1, ''A comment '')');
SELECT throws_ok(
  'INSERT INTO artist (id, gid, name, sort_name, comment)
   VALUES (10, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', 1, 1, '' A comment'')');
SELECT lives_ok(
  'INSERT INTO artist (id, gid, name, sort_name, comment)
   VALUES (10, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', 1, 1, ''A comment'')');

--------------------------------------------------------------------------------
SELECT throws_ok('INSERT INTO label_name (id, name) VALUES (1, ''Revolution  Recordings'')');
SELECT throws_ok('INSERT INTO label_name (id, name) VALUES (1, '' Revolution Recordings'')');
SELECT throws_ok('INSERT INTO label_name (id, name) VALUES (1, ''Revolution Recordings '')');
SELECT lives_ok ('INSERT INTO label_name (id, name) VALUES (1, ''Revolution Recordings'')');

--------------------------------------------------------------------------------
SELECT throws_ok(
  'INSERT INTO label (id, gid, name, sort_name, comment)
   VALUES (10, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', 1, 1, ''A  comment'')');
SELECT throws_ok(
  'INSERT INTO label (id, gid, name, sort_name, comment)
   VALUES (10, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', 1, 1, ''A comment '')');
SELECT throws_ok(
  'INSERT INTO label (id, gid, name, sort_name, comment)
   VALUES (10, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', 1, 1, '' A comment'')');
SELECT lives_ok(
  'INSERT INTO label (id, gid, name, sort_name, comment)
   VALUES (10, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', 1, 1, ''A comment'')');

--------------------------------------------------------------------------------
SELECT throws_ok('INSERT INTO release_name (id, name) VALUES (1, ''Jurassic 5  LP'')');
SELECT throws_ok('INSERT INTO release_name (id, name) VALUES (1, '' Jurassic 5 LP'')');
SELECT throws_ok('INSERT INTO release_name (id, name) VALUES (1, ''Jurassic 5 LP '')');
SELECT lives_ok ('INSERT INTO release_name (id, name) VALUES (1, ''Jurassic 5 LP'')');

--------------------------------------------------------------------------------
INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);

SELECT throws_ok(
  'INSERT INTO release_group (id, artist_credit, gid, name, comment)
   VALUES (1, 1, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', 1, ''A  comment'')');
SELECT throws_ok(
  'INSERT INTO release_group (id, artist_credit, gid, name, comment)
   VALUES (1, 1, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', 1, ''A comment '')');
SELECT throws_ok(
  'INSERT INTO release_group (id, artist_credit, gid, name, comment)
   VALUES (1, 1, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', 1, '' A comment'')');
SELECT lives_ok(
  'INSERT INTO release_group (id, artist_credit, gid, name, comment)
   VALUES (1, 1, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', 1, ''A comment'')');

--------------------------------------------------------------------------------
SELECT throws_ok(
  'INSERT INTO release (id, gid, name, release_group, artist_credit, comment)
   VALUES (1, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', 1, 1, 1, ''A  comment'')');
SELECT throws_ok(
  'INSERT INTO release (id, gid, name, release_group, artist_credit, comment)
   VALUES (1, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', 1, 1, 1, ''A comment '')');
SELECT throws_ok(
  'INSERT INTO release (id, gid, name, release_group, artist_credit, comment)
   VALUES (1, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', 1, 1, 1, '' A comment'')');
SELECT lives_ok(
  'INSERT INTO release (id, gid, name, release_group, artist_credit, comment)
   VALUES (1, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', 1, 1, 1, ''A comment'')');

--------------------------------------------------------------------------------

SELECT throws_ok(
  'INSERT INTO medium (id, name, release, track_count, position)
   VALUES (1, ''Disc  1'', 1, 0, 1)');
SELECT throws_ok(
  'INSERT INTO medium (id, name, release, track_count, position)
   VALUES (1, ''Disc 1 '', 1, 0, 1)');
SELECT throws_ok(
  'INSERT INTO medium (id, name, release, track_count, position)
   VALUES (1, '' Disc 1'', 1, 0, 1)');
SELECT lives_ok(
  'INSERT INTO medium (id, name, release, track_count, position)
   VALUES (1, ''Disc 1'', 1, 0, 1)');

--------------------------------------------------------------------------------
SELECT lives_ok(
 'INSERT INTO release_label (release, label, catalog_number)
  VALUES (1, NULL, ''FOO'')');
SELECT throws_ok(
 'INSERT INTO release_label (release, label, catalog_number)
  VALUES (1, 1, ''FOO  123'')');
SELECT throws_ok(
 'INSERT INTO release_label (release, label, catalog_number)
  VALUES (1, NULL, ''FOO '')');
SELECT throws_ok(
 'INSERT INTO release_label (release, label, catalog_number)
  VALUES (1, 1, '' FOO'')');

--------------------------------------------------------------------------------
SELECT throws_ok('INSERT INTO track_name (id, name) VALUES (1, ''Limit To Your  Love'')');
SELECT throws_ok('INSERT INTO track_name (id, name) VALUES (1, '' Limit To Your Love'')');
SELECT throws_ok('INSERT INTO track_name (id, name) VALUES (1, ''Limit To Your Love '')');
SELECT lives_ok ('INSERT INTO track_name (id, name) VALUES (1, ''Limit To Your Love'')');

--------------------------------------------------------------------------------
SELECT throws_ok(
  'INSERT INTO recording (id, artist_credit, name, gid, comment)
   VALUES (1, 1, 1, ''7f92cb36-3505-41d5-a8c0-b73c5cca0661'', ''Recording  Comment'')');
SELECT throws_ok(
  'INSERT INTO recording (id, artist_credit, name, gid, comment)
   VALUES (1, 1, 1, ''7f92cb36-3505-41d5-a8c0-b73c5cca0661'', '' Recording Comment'')');
SELECT throws_ok(
  'INSERT INTO recording (id, artist_credit, name, gid, comment)
   VALUES (1, 1, 1, ''7f92cb36-3505-41d5-a8c0-b73c5cca0661'', ''Recording Comment '')');
SELECT lives_ok(
  'INSERT INTO recording (id, artist_credit, name, gid, comment)
   VALUES (1, 1, 1, ''7f92cb36-3505-41d5-a8c0-b73c5cca0661'', ''Recording Comment'')');

--------------------------------------------------------------------------------
SELECT throws_ok(
  'INSERT INTO track (id, gid, medium, name, position, number, artist_credit, recording)
   VALUES (1, ''82dd4327-03a2-4b91-aeac-cc2f5bb2ffb1'', 1, 1, 1, ''1 '', 1, 1)');
SELECT throws_ok(
  'INSERT INTO track (id, gid, medium, name, position, number, artist_credit, recording)
   VALUES (1, ''82dd4327-03a2-4b91-aeac-cc2f5bb2ffb1'', 1, 1, 1, '' 1'', 1, 1)');
SELECT lives_ok(
  'INSERT INTO track (id, gid, medium, name, position, number, artist_credit, recording)
   VALUES (1, ''82dd4327-03a2-4b91-aeac-cc2f5bb2ffb1'', 1, 1, 1, ''1'', 1, 1)');

--------------------------------------------------------------------------------
SELECT lives_ok(
  'INSERT INTO url (id, url, gid)
   VALUES (1, ''http://musicbrainz.org'', ''9386b511-829b-47ca-80f6-0cdc3c31d8b9'')');

--------------------------------------------------------------------------------
SELECT throws_ok('INSERT INTO work_name (id, name) VALUES (1, ''Limit To Your  Love'')');
SELECT throws_ok('INSERT INTO work_name (id, name) VALUES (1, '' Limit To Your Love'')');
SELECT throws_ok('INSERT INTO work_name (id, name) VALUES (1, ''Limit To Your Love '')');
SELECT lives_ok ('INSERT INTO work_name (id, name) VALUES (1, ''Limit To Your Love'')');

--------------------------------------------------------------------------------
SELECT throws_ok(
  'INSERT INTO work (id, name, gid, comment)
   VALUES (1, 1, ''7f92cb36-3505-41d5-a8c0-b73c5cca0661'', ''Work  Comment'')');
SELECT throws_ok(
  'INSERT INTO work (id, name, gid, comment)
   VALUES (1, 1, ''7f92cb36-3505-41d5-a8c0-b73c5cca0661'', '' Work Comment'')');
SELECT throws_ok(
  'INSERT INTO work (id, name, gid, comment)
   VALUES (1, 1, ''7f92cb36-3505-41d5-a8c0-b73c5cca0661'', ''Work Comment '')');
SELECT lives_ok(
  'INSERT INTO work (id, name, gid, comment)
   VALUES (1, 1, ''7f92cb36-3505-41d5-a8c0-b73c5cca0661'', ''Work Comment'')');

SELECT finish();
ROLLBACK;
