\set ON_ERROR_STOP 1
BEGIN;

-- For Data::EditNote::find_by_recipient
CREATE INDEX CONCURRENTLY edit_note_idx_post_time_edit ON edit_note (post_time DESC, edit DESC);

COMMIT;
