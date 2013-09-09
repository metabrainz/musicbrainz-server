BEGIN;
SET search_path = musicbrainz, public;
SELECT no_plan();

--------------------------------------------------------------------------------
-- Test for artists
INSERT INTO artist (id, gid, name, sort_name)
  VALUES
    (1, 'a2902f82-c7d3-4445-b291-e3ec251d71b7', 'Artist A', 'Artist A'),
    (2, 'bf905de0-a0f3-4417-bdc7-0d6eeb70397a', 'Artist B', 'Artist B');

INSERT INTO artist_alias (id, artist, name, sort_name, locale)
  VALUES (1, 1, 'English Alias 1', 'English Alias 1', 'en_GB'), (2, 1, 'English Alias 2', 'English Alias 2', 'en_GB'),
         (3, 2, 'English Alias 3', 'English Alias 3', 'en_GB'), (4, 2, 'Other Alias', 'Other Alias', NULL);

SELECT is(primary_for_locale, FALSE)
  FROM artist_alias WHERE id IN (1, 2, 3, 4);

UPDATE artist_alias SET primary_for_locale = TRUE WHERE id IN (1, 3);

SELECT set_eq(
  'SELECT id, primary_for_locale FROM artist_alias WHERE id IN (1, 3)',
  'VALUES (1, TRUE), (3, TRUE)',
  'Correctly set primary_for_locale on alias 1 and 3'
);

SELECT set_eq(
  'SELECT id, primary_for_locale FROM artist_alias WHERE id IN (2, 4)',
  'VALUES (2, FALSE), (4, FALSE)',
  'Did not set primary_for_locale on alias 2 or 4'
);

--------------------------------------------------------------------------------
-- Test for labels
INSERT INTO label (id, gid, name, sort_name)
  VALUES
    (1, 'a2902f82-c7d3-4445-b291-e3ec251d71b7', 'Label A', 'Label A'),
    (2, 'bf905de0-a0f3-4417-bdc7-0d6eeb70397a', 'Label B', 'Label B');

INSERT INTO label_alias (id, label, name, sort_name, locale)
  VALUES (1, 1, 'English Alias 1', 'English Alias 1', 'en_GB'), (2, 1, 'English Alias 2', 'English Alias 2', 'en_GB'),
         (3, 2, 'English Alias 3', 'English Alias 3', 'en_GB'), (4, 2, 'Other Alias', 'Other Alias', NULL);

SELECT is(primary_for_locale, FALSE)
  FROM label_alias WHERE id IN (1, 2, 3, 4);

UPDATE label_alias SET primary_for_locale = TRUE WHERE id IN (1, 3);

SELECT set_eq(
  'SELECT id, primary_for_locale FROM label_alias WHERE id IN (1, 3)',
  'VALUES (1, TRUE), (3, TRUE)',
  'Correctly set primary_for_locale on alias 1 and 3'
);

SELECT set_eq(
  'SELECT id, primary_for_locale FROM label_alias WHERE id IN (2, 4)',
  'VALUES (2, FALSE), (4, FALSE)',
  'Did not set primary_for_locale on alias 2 or 4'
);

--------------------------------------------------------------------------------
-- Test for works
INSERT INTO work (id, gid, name)
  VALUES
    (1, 'a2902f82-c7d3-4445-b291-e3ec251d71b7', 'Work A'),
    (2, 'bf905de0-a0f3-4417-bdc7-0d6eeb70397a', 'Work B');

INSERT INTO work_alias (id, work, name, sort_name, locale)
  VALUES (1, 1, 'English Alias 1', 'English Alias 1', 'en_GB'), (2, 1, 'English Alias 2', 'English Alias 2', 'en_GB'),
         (3, 2, 'English Alias 3', 'English Alias 3', 'en_GB'), (4, 2, 'Other Alias', 'Other Alias', NULL);

SELECT is(primary_for_locale, FALSE)
  FROM work_alias WHERE id IN (1, 2, 3, 4);

UPDATE work_alias SET primary_for_locale = TRUE WHERE id IN (1, 3);

SELECT set_eq(
  'SELECT id, primary_for_locale FROM work_alias WHERE id IN (1, 3)',
  'VALUES (1, TRUE), (3, TRUE)',
  'Correctly set primary_for_locale on alias 1 and 3'
);

SELECT set_eq(
  'SELECT id, primary_for_locale FROM work_alias WHERE id IN (2, 4)',
  'VALUES (2, FALSE), (4, FALSE)',
  'Did not set primary_for_locale on alias 2 or 4'
);

SELECT finish();
ROLLBACK;
