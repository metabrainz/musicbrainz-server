\set ON_ERROR_STOP 1
BEGIN;

-- Broken index exists on totoro, drop it first.
DROP INDEX IF EXISTS edit_note_idx_post_time_edit;

-- For Data::EditNote::find_by_recipient
CREATE INDEX edit_note_idx_post_time_edit ON edit_note (post_time DESC, edit DESC);

COMMIT;
