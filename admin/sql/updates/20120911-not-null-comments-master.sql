\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE artist
  ALTER COLUMN comment TYPE varchar(255) USING coalesce(comment, ''),
  ALTER COLUMN comment SET NOT NULL,
  ALTER COLUMN comment SET DEFAULT '';

ALTER TABLE label
  ALTER COLUMN comment TYPE varchar(255) USING coalesce(comment, ''),
  ALTER COLUMN comment SET NOT NULL,
  ALTER COLUMN comment SET DEFAULT '';

ALTER TABLE recording
  ALTER COLUMN comment TYPE varchar(255) USING coalesce(comment, ''),
  ALTER COLUMN comment SET NOT NULL,
  ALTER COLUMN comment SET DEFAULT '';

ALTER TABLE release
  ALTER COLUMN comment TYPE varchar(255) USING coalesce(comment, ''),
  ALTER COLUMN comment SET NOT NULL,
  ALTER COLUMN comment SET DEFAULT '';

ALTER TABLE release_raw
  ALTER COLUMN comment TYPE varchar(255) USING coalesce(comment, ''),
  ALTER COLUMN comment SET NOT NULL,
  ALTER COLUMN comment SET DEFAULT '';

ALTER TABLE release_group
  ALTER COLUMN comment TYPE varchar(255) USING coalesce(comment, ''),
  ALTER COLUMN comment SET NOT NULL,
  ALTER COLUMN comment SET DEFAULT '';

ALTER TABLE work
  ALTER COLUMN comment TYPE varchar(255) USING coalesce(comment, ''),
  ALTER COLUMN comment SET NOT NULL,
  ALTER COLUMN comment SET DEFAULT '';

ALTER TABLE artist_credit_name
  ALTER COLUMN join_phrase TYPE text USING coalesce(join_phrase, ''),
  ALTER COLUMN join_phrase SET NOT NULL,
  ALTER COLUMN join_phrase SET DEFAULT '';

COMMIT;
