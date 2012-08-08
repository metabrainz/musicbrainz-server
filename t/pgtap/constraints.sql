SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

--------------------------------------------------------------------------------
-- Check that release_label requires whitespace-controlled text

INSERT INTO artist_name (id, name) VALUES (1, 'A');
INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO release_name (id, name) VALUES (1, 'R');

INSERT INTO release_group (id, gid, name, artist_credit)
VALUES (1, 'e39cd5cc-49a3-42e1-8058-bc0d5fc75117', 1, 1);
INSERT INTO release (id, gid, name, artist_credit, release_group)
VALUES (1, 'e39cd5cc-49a3-42e1-8058-bc0d5fc75117', 1, 1, 1);

SELECT lives_ok(
 'INSERT INTO release_label (release, label, catalog_number)
  VALUES (1, NULL, ''FOO'')');
SELECT throws_ok(
 'INSERT INTO release_label (release, label, catalog_number)
  VALUES (1, NULL, ''FOO  123'')');
SELECT throws_ok(
 'INSERT INTO release_label (release, label, catalog_number)
  VALUES (1, NULL, ''FOO '')');
SELECT throws_ok(
 'INSERT INTO release_label (release, label, catalog_number)
  VALUES (1, NULL, '' FOO'')');

SELECT finish();
ROLLBACK;
