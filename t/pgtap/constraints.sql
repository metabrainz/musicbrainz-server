SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

--------------------------------------------------------------------------------
-- Comments
SELECT throws_ok(
  'INSERT INTO artist (id, gid, name, sort_name, comment)
   VALUES (10, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', ''James Blake'', ''James Blake'', ''A comment '')');
SELECT throws_ok(
  'INSERT INTO artist (id, gid, name, sort_name, comment)
   VALUES (10, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', ''James Blake'', ''James Blake'', '' A comment'')');

-- Name & sortname
SELECT throws_ok(
  'INSERT INTO artist (id, gid, name, sort_name, comment)
   VALUES (10, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', '' James Blake'', ''James Blake'', ''A comment'')');
SELECT throws_ok(
  'INSERT INTO artist (id, gid, name, sort_name, comment)
   VALUES (10, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', ''James Blake'', '' James Blake'', ''A comment'')');
SELECT throws_ok(
  'INSERT INTO artist (id, gid, name, sort_name, comment)
   VALUES (10, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', ''James Blake '', ''James Blake'', ''A comment'')');
SELECT throws_ok(
  'INSERT INTO artist (id, gid, name, sort_name, comment)
   VALUES (10, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', ''James Blake'', ''James Blake '', ''A comment'')');

-- Everything okay
SELECT lives_ok(
  'INSERT INTO artist (id, gid, name, sort_name, comment)
   VALUES (10, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', ''James Blake'', ''James Blake'', ''A comment'')');

--------------------------------------------------------------------------------
-- Comments
SELECT throws_ok(
  'INSERT INTO label (id, gid, name, comment)
   VALUES (10, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', ''Revolution Recordings'', ''A comment '')');
SELECT throws_ok(
  'INSERT INTO label (id, gid, name, comment)
   VALUES (10, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', ''Revolution Recordings'', '' A comment'')');

-- Name & sortname
SELECT throws_ok(
  'INSERT INTO label (id, gid, name, comment)
   VALUES (10, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', '' Revolution Recordings'', ''A comment'')');
SELECT throws_ok(
  'INSERT INTO label (id, gid, name, comment)
   VALUES (10, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', '' Revolution Recordings'', ''A comment'')');
SELECT throws_ok(
  'INSERT INTO label (id, gid, name, comment)
   VALUES (10, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', ''Revolution Recordings '', ''A comment'')');
SELECT throws_ok(
  'INSERT INTO label (id, gid, name, comment)
   VALUES (10, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', ''Revolution Recordings '', ''A comment'')');

-- Everything okay
SELECT lives_ok(
  'INSERT INTO label (id, gid, name, comment)
   VALUES (10, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', ''Revolution Recordings'', ''A comment'')');

--------------------------------------------------------------------------------
INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 'James Blake', 1);

-- Comments
SELECT throws_ok(
  'INSERT INTO release_group (id, artist_credit, gid, name, comment)
   VALUES (1, 1, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', ''Jurassic 5 LP'', ''A comment '')');
SELECT throws_ok(
  'INSERT INTO release_group (id, artist_credit, gid, name, comment)
   VALUES (1, 1, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', ''Jurassic 5 LP'', '' A comment'')');

-- Names
SELECT throws_ok(
  'INSERT INTO release_group (id, artist_credit, gid, name, comment)
   VALUES (1, 1, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', '' Jurassic 5 LP'', ''A comment'')');
SELECT throws_ok(
  'INSERT INTO release_group (id, artist_credit, gid, name, comment)
   VALUES (1, 1, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', ''Jurassic 5 LP '', ''A comment'')');

-- Everything okay
SELECT lives_ok(
  'INSERT INTO release_group (id, artist_credit, gid, name, comment)
   VALUES (1, 1, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', ''Jurassic 5 LP'', ''A comment'')');

--------------------------------------------------------------------------------
-- Comments
SELECT throws_ok(
  'INSERT INTO release (id, gid, name, release_group, artist_credit, comment)
   VALUES (1, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', ''Jurassic 5 LP'', 1, 1, ''A comment '')');
SELECT throws_ok(
  'INSERT INTO release (id, gid, name, release_group, artist_credit, comment)
   VALUES (1, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', ''Jurassic 5 LP'', 1, 1, '' A comment'')');

-- Names
SELECT throws_ok(
  'INSERT INTO release (id, gid, name, release_group, artist_credit, comment)
   VALUES (1, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', '' Jurassic 5 LP'', 1, 1, ''A comment'')');
SELECT throws_ok(
  'INSERT INTO release (id, gid, name, release_group, artist_credit, comment)
   VALUES (1, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', ''Jurassic 5 LP '', 1, 1, ''A comment'')');

-- Everything okay
SELECT lives_ok(
  'INSERT INTO release (id, gid, name, release_group, artist_credit, comment)
   VALUES (1, ''1fb3106e-00de-44fe-8511-aa949eb6fe0c'', ''Jurassic 5 LP'', 1, 1, ''A comment'')');

--------------------------------------------------------------------------------

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
  VALUES (1, NULL, ''FOO '')');
SELECT throws_ok(
 'INSERT INTO release_label (release, label, catalog_number)
  VALUES (1, 1, '' FOO'')');

--------------------------------------------------------------------------------
-- Comments
SELECT throws_ok(
  'INSERT INTO recording (id, artist_credit, name, gid, comment)
   VALUES (1, 1, ''Limit To Your Love'', ''7f92cb36-3505-41d5-a8c0-b73c5cca0661'', '' Recording Comment'')');
SELECT throws_ok(
  'INSERT INTO recording (id, artist_credit, name, gid, comment)
   VALUES (1, 1, ''Limit To Your Love'', ''7f92cb36-3505-41d5-a8c0-b73c5cca0661'', ''Recording Comment '')');

-- Names
SELECT throws_ok(
  'INSERT INTO recording (id, artist_credit, name, gid, comment)
   VALUES (1, 1, '' Limit To Your Love'', ''7f92cb36-3505-41d5-a8c0-b73c5cca0661'', ''Recording Comment'')');
SELECT throws_ok(
  'INSERT INTO recording (id, artist_credit, name, gid, comment)
   VALUES (1, 1, ''Limit To Your Love '', ''7f92cb36-3505-41d5-a8c0-b73c5cca0661'', ''Recording Comment'')');

-- Everything okay
SELECT lives_ok(
  'INSERT INTO recording (id, artist_credit, name, gid, comment)
   VALUES (1, 1, ''Limit To Your Love'', ''7f92cb36-3505-41d5-a8c0-b73c5cca0661'', ''Recording Comment'')');

--------------------------------------------------------------------------------
-- Numbers
SELECT throws_ok(
  'INSERT INTO track (id, gid, medium, name, position, number, artist_credit, recording)
   VALUES (1, ''82dd4327-03a2-4b91-aeac-cc2f5bb2ffb1'', 1, ''Limit To Your Love'', 1, ''1 '', 1, 1)');
SELECT throws_ok(
  'INSERT INTO track (id, gid, medium, name, position, number, artist_credit, recording)
   VALUES (1, ''82dd4327-03a2-4b91-aeac-cc2f5bb2ffb1'', 1, ''Limit To Your Love'', 1, '' 1'', 1, 1)');

-- Names
SELECT throws_ok(
  'INSERT INTO track (id, gid, medium, name, position, number, artist_credit, recording)
   VALUES (1, ''82dd4327-03a2-4b91-aeac-cc2f5bb2ffb1'', 1, '' Limit To Your Love'', 1, ''1'', 1, 1)');
SELECT throws_ok(
  'INSERT INTO track (id, gid, medium, name, position, number, artist_credit, recording)
   VALUES (1, ''82dd4327-03a2-4b91-aeac-cc2f5bb2ffb1'', 1, ''Limit To Your Love '', 1, ''1'', 1, 1)');

-- Everything okay
SELECT lives_ok(
  'INSERT INTO track (id, gid, medium, name, position, number, artist_credit, recording)
   VALUES (1, ''82dd4327-03a2-4b91-aeac-cc2f5bb2ffb1'', 1, ''Limit To Your Love'', 1, ''1'', 1, 1)');

--------------------------------------------------------------------------------
SELECT lives_ok(
  'INSERT INTO url (id, url, gid)
   VALUES (1, ''http://musicbrainz.org'', ''9386b511-829b-47ca-80f6-0cdc3c31d8b9'')');

--------------------------------------------------------------------------------
-- Comments
SELECT throws_ok(
  'INSERT INTO work (id, name, gid, comment)
   VALUES (1, ''Limit To Your Love'', ''7f92cb36-3505-41d5-a8c0-b73c5cca0661'', '' Work Comment'')');
SELECT throws_ok(
  'INSERT INTO work (id, name, gid, comment)
   VALUES (1, ''Limit To Your Love'', ''7f92cb36-3505-41d5-a8c0-b73c5cca0661'', ''Work Comment '')');

-- Names
SELECT throws_ok(
  'INSERT INTO work (id, name, gid, comment)
   VALUES (1, '' Limit To Your Love'', ''7f92cb36-3505-41d5-a8c0-b73c5cca0661'', ''Work Comment'')');
SELECT throws_ok(
  'INSERT INTO work (id, name, gid, comment)
   VALUES (1, ''Limit To Your Love '', ''7f92cb36-3505-41d5-a8c0-b73c5cca0661'', ''Work Comment'')');

-- Everything okay
SELECT lives_ok(
  'INSERT INTO work (id, name, gid, comment)
   VALUES (1, ''Limit To Your Love'', ''7f92cb36-3505-41d5-a8c0-b73c5cca0661'', ''Work Comment'')');

SELECT finish();
ROLLBACK;
