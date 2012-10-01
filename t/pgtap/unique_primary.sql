BEGIN;
SET search_path = musicbrainz, public;
SELECT no_plan();

--------------------------------------------------------------------------------
-- Test for artists
INSERT INTO artist_name (id, name)
  VALUES
    (1, 'Artist A'), (2, 'Artist B'),
    (3, 'English Alias 1'), (4, 'English Alias 2'), (5, 'English Alias 3'),
    (6, 'Other Alias');

INSERT INTO artist (id, gid, name, sort_name)
  VALUES
    (1, 'a2902f82-c7d3-4445-b291-e3ec251d71b7', 1, 1),
    (2, 'bf905de0-a0f3-4417-bdc7-0d6eeb70397a', 2, 2);

INSERT INTO artist_alias (id, artist, name, sort_name, locale)
  VALUES (1, 1, 3, 3, 'en_GB'), (2, 1, 4, 4, 'en_GB'),
         (3, 2, 5, 5, 'en_GB'), (4, 2, 6, 6, NULL);

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
INSERT INTO label_name (id, name)
  VALUES
    (1, 'Label A'), (2, 'Label B'),
    (3, 'English Alias 1'), (4, 'English Alias 2'), (5, 'English Alias 3'),
    (6, 'Other Alias');

INSERT INTO label (id, gid, name, sort_name)
  VALUES
    (1, 'a2902f82-c7d3-4445-b291-e3ec251d71b7', 1, 1),
    (2, 'bf905de0-a0f3-4417-bdc7-0d6eeb70397a', 2, 2);

INSERT INTO label_alias (id, label, name, sort_name, locale)
  VALUES (1, 1, 3, 3, 'en_GB'), (2, 1, 4, 4, 'en_GB'),
         (3, 2, 5, 5, 'en_GB'), (4, 2, 6, 6, NULL);

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
INSERT INTO work_name (id, name)
  VALUES
    (1, 'Work A'), (2, 'Work B'),
    (3, 'English Alias 1'), (4, 'English Alias 2'), (5, 'English Alias 3'),
    (6, 'Other Alias');

INSERT INTO work (id, gid, name)
  VALUES
    (1, 'a2902f82-c7d3-4445-b291-e3ec251d71b7', 1),
    (2, 'bf905de0-a0f3-4417-bdc7-0d6eeb70397a', 2);

INSERT INTO work_alias (id, work, name, sort_name, locale)
  VALUES (1, 1, 3, 3, 'en_GB'), (2, 1, 4, 4, 'en_GB'),
         (3, 2, 5, 5, 'en_GB'), (4, 2, 6, 6, NULL);

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
