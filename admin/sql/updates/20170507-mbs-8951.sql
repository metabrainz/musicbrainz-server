\set ON_ERROR_STOP 1
BEGIN;

-- Copy of 20160604-mbs-8951.sql for upgrade.sh (minus CONCURRENTLY, since it
-- runs inside a transaction).

DROP INDEX IF EXISTS edit_note_idx_post_time_edit;
CREATE INDEX edit_note_idx_post_time_edit ON edit_note (post_time DESC NULLS LAST, edit DESC);

COMMIT;
