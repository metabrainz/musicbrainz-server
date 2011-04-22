\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE medium ADD CONSTRAINT medium_release_position UNIQUE(release, position) DEFERRABLE;

COMMIT;
