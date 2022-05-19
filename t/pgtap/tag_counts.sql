SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

ALTER TABLE tag DISABLE TRIGGER delete_unused_tag;

INSERT INTO tag (id, name, ref_count)
     VALUES (1, 'rock', 0), (2, 'pop', 0), (3, 'bad', 0), (4, 'rock & roll', 0);

INSERT INTO artist (id, gid, name, sort_name)
     VALUES (10, '2b7721f6-c25d-4db5-9ebb-ebc6d3c48d0a', 'the tagged', 'tagged, the'),
            (11, '540d5370-d8a0-4d5d-96b7-216fd8217ae8', 'the genred', 'genred, the');

INSERT INTO editor (id, name, password, ha1)
     VALUES (10, 'tagger1', '', ''), (11, 'tagger2', '', '');

INSERT INTO artist_tag_raw (artist, editor, tag, is_upvote)
     VALUES (10, 10, 3, 't'),
            (10, 11, 3, 'f'),
            (11, 10, 1, 'f'),
            (11, 10, 2, 't'),
            (11, 11, 2, 't');

PREPARE all_tags AS
SELECT id, name::TEXT, ref_count
FROM tag
ORDER BY id, name;

PREPARE all_aggregate_artist_tags AS
SELECT artist, tag, count
FROM artist_tag
ORDER BY artist, tag;

SELECT results_eq(
  'all_tags',
  $$
    VALUES -- (id, name, ref_count)
      (1::integer, 'rock', 1::integer),
      (2::integer, 'pop', 2::integer),
      (3::integer, 'bad', 2::integer),
      (4::integer, 'rock & roll', 0::integer)
  $$
);

SELECT results_eq(
  'all_aggregate_artist_tags',
  $$
    VALUES -- (artist, tag, count)
      (10::integer, 3::integer, 0::integer),
      (11::integer, 1::integer, -1::integer),
      (11::integer, 2::integer, 2::integer)
  $$
);

-- Change only the vote (downvote -> upvote).
UPDATE artist_tag_raw
   SET is_upvote = 't'
 WHERE artist = 10 AND editor = 11 AND tag = 3;

-- artist_tag_raw (artist, editor, tag, is_upvote):
--
-- (10, 10, 3, 't')
-- (10, 11, 3, 't')
-- (11, 10, 1, 'f')
-- (11, 10, 2, 't')
-- (11, 11, 2, 't')

SELECT results_eq(
  'all_tags',
  $$
    VALUES -- (id, name, ref_count)
      (1::integer, 'rock', 1::integer),
      (2::integer, 'pop', 2::integer),
      (3::integer, 'bad', 2::integer),
      (4::integer, 'rock & roll', 0::integer)
  $$
);

SELECT results_eq(
  'all_aggregate_artist_tags',
  $$
    VALUES -- (artist, tag, count)
      (10::integer, 3::integer, 2::integer),
      (11::integer, 1::integer, -1::integer),
      (11::integer, 2::integer, 2::integer)
  $$
);

-- upvote -> downvote
UPDATE artist_tag_raw
   SET is_upvote = 'f'
 WHERE artist = 11 AND editor = 10 AND tag = 2;

-- artist_tag_raw (artist, editor, tag, is_upvote):
--
-- (10, 10, 3, 't')
-- (10, 11, 3, 't')
-- (11, 10, 1, 'f')
-- (11, 10, 2, 'f')
-- (11, 11, 2, 't')

SELECT results_eq(
  'all_tags',
  $$
    VALUES -- (id, name, ref_count)
      (1::integer, 'rock', 1::integer),
      (2::integer, 'pop', 2::integer),
      (3::integer, 'bad', 2::integer),
      (4::integer, 'rock & roll', 0::integer)
  $$
);

SELECT results_eq(
  'all_aggregate_artist_tags',
  $$
    VALUES -- (artist, tag, count)
      (10::integer, 3::integer, 2::integer),
      (11::integer, 1::integer, -1::integer),
      (11::integer, 2::integer, 0::integer)
  $$
);

-- rock -> rock & roll
UPDATE artist_tag_raw
   SET tag = 4
 WHERE artist = 11 AND editor = 10 AND tag = 1;

-- artist_tag_raw (artist, editor, tag, is_upvote):
--
-- (10, 10, 3, 't')
-- (10, 11, 3, 't')
-- (11, 10, 2, 'f')
-- (11, 10, 4, 'f')
-- (11, 11, 2, 't')

SELECT results_eq(
  'all_tags',
  $$
    VALUES -- (id, name, ref_count)
      (1::integer, 'rock', 0::integer),
      (2::integer, 'pop', 2::integer),
      (3::integer, 'bad', 2::integer),
      (4::integer, 'rock & roll', 1::integer)
  $$
);

SELECT results_eq(
  'all_aggregate_artist_tags',
  $$
    VALUES -- (artist, tag, count)
      (10::integer, 3::integer, 2::integer),
      (11::integer, 2::integer, 0::integer),
      (11::integer, 4::integer, -1::integer)
  $$
);

-- pop -> rock & roll
UPDATE artist_tag_raw
   SET tag = 4
 WHERE artist = 11 AND editor = 11 AND tag = 2;

-- artist_tag_raw (artist, editor, tag, is_upvote):
--
-- (10, 10, 3, 't')
-- (10, 11, 3, 't')
-- (11, 10, 2, 'f')
-- (11, 10, 4, 'f')
-- (11, 11, 4, 't')

SELECT results_eq(
  'all_tags',
  $$
    VALUES -- (id, name, ref_count)
      (1::integer, 'rock', 0::integer),
      (2::integer, 'pop', 1::integer),
      (3::integer, 'bad', 2::integer),
      (4::integer, 'rock & roll', 2::integer)
  $$
);

SELECT results_eq(
  'all_aggregate_artist_tags',
  $$
    VALUES -- (artist, tag, count)
      (10::integer, 3::integer, 2::integer),
      (11::integer, 2::integer, -1::integer),
      (11::integer, 4::integer, 0::integer)
  $$
);

-- artist 11 -> artist 10
UPDATE artist_tag_raw
   SET artist = 10
 WHERE artist = 11 AND editor = 10 AND tag = 2;

-- artist_tag_raw (artist, editor, tag, is_upvote):
--
-- (10, 10, 2, 'f')
-- (10, 10, 3, 't')
-- (10, 11, 3, 't')
-- (11, 10, 4, 'f')
-- (11, 11, 4, 't')

SELECT results_eq(
  'all_tags',
  $$
    VALUES -- (id, name, ref_count)
      (1::integer, 'rock', 0::integer),
      (2::integer, 'pop', 1::integer),
      (3::integer, 'bad', 2::integer),
      (4::integer, 'rock & roll', 2::integer)
  $$
);

SELECT results_eq(
  'all_aggregate_artist_tags',
  $$
    VALUES -- (artist, tag, count)
      (10::integer, 2::integer, -1::integer),
      (10::integer, 3::integer, 2::integer),
      (11::integer, 4::integer, 0::integer)
  $$
);

-- Update artist, tag, and is_upvote all at once.
UPDATE artist_tag_raw
   SET artist = 11, tag = 1, is_upvote = 'f'
 WHERE artist = 10 AND editor = 11 AND tag = 3;

-- artist_tag_raw (artist, editor, tag, is_upvote):
--
-- (10, 10, 2, 'f')
-- (10, 10, 3, 't')
-- (11, 10, 4, 'f')
-- (11, 11, 1, 'f')
-- (11, 11, 4, 't')

SELECT results_eq(
  'all_tags',
  $$
    VALUES -- (id, name, ref_count)
      (1::integer, 'rock', 1::integer),
      (2::integer, 'pop', 1::integer),
      (3::integer, 'bad', 1::integer),
      (4::integer, 'rock & roll', 2::integer)
  $$
);

SELECT results_eq(
  'all_aggregate_artist_tags',
  $$
    VALUES -- (artist, tag, count)
      (10::integer, 2::integer, -1::integer),
      (10::integer, 3::integer, 1::integer),
      (11::integer, 1::integer, -1::integer),
      (11::integer, 4::integer, 0::integer)
  $$
);

-- Delete editor 11's tags.
DELETE FROM artist_tag_raw WHERE editor = 11;

-- artist_tag_raw (artist, editor, tag, is_upvote):
--
-- (10, 10, 2, 'f')
-- (10, 10, 3, 't')
-- (11, 10, 4, 'f')

SELECT results_eq(
  'all_tags',
  $$
    VALUES -- (id, name, ref_count)
      (1::integer, 'rock', 0::integer),
      (2::integer, 'pop', 1::integer),
      (3::integer, 'bad', 1::integer),
      (4::integer, 'rock & roll', 1::integer)
  $$
);

SELECT results_eq(
  'all_aggregate_artist_tags',
  $$
    VALUES -- (artist, tag, count)
      (10::integer, 2::integer, -1::integer),
      (10::integer, 3::integer, 1::integer),
      (11::integer, 4::integer, -1::integer)
  $$
);

-- Move editor 10's tags to editor 11, just to see that the counts remain the
-- same. (This shouldn't happen in practice.)
UPDATE artist_tag_raw SET editor = 11;

-- artist_tag_raw (artist, editor, tag, is_upvote):
--
-- (10, 11, 2, 'f')
-- (10, 11, 3, 't')
-- (11, 11, 4, 'f')

SELECT results_eq(
  'all_tags',
  $$
    VALUES -- (id, name, ref_count)
      (1::integer, 'rock', 0::integer),
      (2::integer, 'pop', 1::integer),
      (3::integer, 'bad', 1::integer),
      (4::integer, 'rock & roll', 1::integer)
  $$
);

SELECT results_eq(
  'all_aggregate_artist_tags',
  $$
    VALUES -- (artist, tag, count)
      (10::integer, 2::integer, -1::integer),
      (10::integer, 3::integer, 1::integer),
      (11::integer, 4::integer, -1::integer)
  $$
);

ALTER TABLE tag ENABLE TRIGGER delete_unused_tag;

SELECT finish();
ROLLBACK;
