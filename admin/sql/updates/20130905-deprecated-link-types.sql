\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE link_type ADD COLUMN is_deprecated BOOLEAN NOT NULL DEFAULT false;

UPDATE link_type SET is_deprecated = true
WHERE description LIKE '%deprecated%';

COMMIT;
