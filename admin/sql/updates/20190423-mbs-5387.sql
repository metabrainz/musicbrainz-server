\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE artist_credit
ADD COLUMN edits_pending INTEGER NOT NULL DEFAULT 0
CHECK (edits_pending >= 0);

COMMIT;
