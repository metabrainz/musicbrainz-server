SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

INSERT INTO artist (id, gid, name, sort_name)
     VALUES (10, 'e968024d-63d4-4557-b5f6-ba345c329670', 'the rated 1', 'rated 1, the'),
            (11, 'eedc843d-8a59-40d5-8c8e-f58fb2333b22', 'the rated 2', 'rated 2, the');

INSERT INTO editor (id, name, password, ha1)
     VALUES (10, 'rater1', '', ''), (11, 'rater2', '', '');

PREPARE all_aggregate_ratings AS
SELECT id, rating, rating_count
FROM artist_meta
ORDER BY id, rating, rating_count;

SELECT results_eq(
  'all_aggregate_ratings',
  $$
    VALUES -- (id, rating, rating_count)
      (10::integer, NULL::smallint, NULL::integer),
      (11::integer, NULL::smallint, NULL::integer)
  $$
);

-- Add some ratings.
INSERT INTO artist_rating_raw (artist, editor, rating)
     VALUES (10, 10, 81),
            (10, 11, 22),
            (11, 10, 55);

SELECT results_eq(
  'all_aggregate_ratings',
  $$
    VALUES -- (id, rating, rating_count)
      (10::integer, 52::smallint, 2::integer),
      (11::integer, 55::smallint, 1::integer)
  $$
);

-- Change one rating.
UPDATE artist_rating_raw
   SET rating = 83
 WHERE artist = 10 AND editor = 10;

-- artist_rating_raw (artist, editor, rating):
--
-- (10, 10, 83)
-- (10, 11, 22)
-- (11, 10, 55)

SELECT results_eq(
  'all_aggregate_ratings',
  $$
    VALUES -- (id, rating, rating_count)
      (10::integer, 53::smallint, 2::integer),
      (11::integer, 55::smallint, 1::integer)
  $$
);

-- Change one artist.
UPDATE artist_rating_raw
   SET artist = 11
 WHERE artist = 10 AND editor = 11;

-- artist_rating_raw (artist, editor, rating):
--
-- (10, 10, 83)
-- (11, 11, 22)
-- (11, 10, 55)

SELECT results_eq(
  'all_aggregate_ratings',
  $$
    VALUES -- (id, rating, rating_count)
      (10::integer, 83::smallint, 1::integer),
      (11::integer, 39::smallint, 2::integer)
  $$
);

-- Delete one rating.
DELETE FROM artist_rating_raw
      WHERE artist = 10 AND editor = 10;

-- artist_rating_raw (artist, editor, rating):
--
-- (11, 11, 22)
-- (11, 10, 55)

SELECT results_eq(
  'all_aggregate_ratings',
  $$
    VALUES -- (id, rating, rating_count)
      (10::integer, NULL::smallint, NULL::integer),
      (11::integer, 39::smallint, 2::integer)
  $$
);

-- Change one artist + rating.
UPDATE artist_rating_raw
   SET artist = 10, rating = 90
 WHERE artist = 11 AND editor = 11;

-- artist_rating_raw (artist, editor, rating):
--
-- (10, 11, 90)
-- (11, 10, 55)

SELECT results_eq(
  'all_aggregate_ratings',
  $$
    VALUES -- (id, rating, rating_count)
      (10::integer, 90::smallint, 1::integer),
      (11::integer, 55::smallint, 1::integer)
  $$
);

-- Move editor 10's ratings to editor 11, just to see that the aggregate
-- remains the same. (This shouldn't happen in practice.)
UPDATE artist_rating_raw SET editor = 11;

-- artist_rating_raw (artist, editor, rating):
--
-- (10, 11, 90)
-- (11, 11, 55)

SELECT results_eq(
  'all_aggregate_ratings',
  $$
    VALUES -- (id, rating, rating_count)
      (10::integer, 90::smallint, 1::integer),
      (11::integer, 55::smallint, 1::integer)
  $$
);

SELECT finish();
ROLLBACK;
