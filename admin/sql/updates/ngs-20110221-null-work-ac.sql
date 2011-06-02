BEGIN;

ALTER TABLE work ALTER COLUMN artist_credit DROP NOT NULL;
UPDATE work SET artist_credit = NULL;

COMMIT;
