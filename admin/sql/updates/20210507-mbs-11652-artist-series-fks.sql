\set ON_ERROR_STOP 1
BEGIN;

------------------
-- constraints  --
------------------

ALTER TABLE series_type ADD CONSTRAINT allowed_series_entity_type
  CHECK (
    entity_type IN (
      'artist',
      'event',
      'recording',
      'release',
      'release_group',
      'work'
    )
  );

COMMIT;
