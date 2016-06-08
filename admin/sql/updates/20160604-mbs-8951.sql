\set ON_ERROR_STOP 1

DROP INDEX CONCURRENTLY edit_note_idx_post_time_edit;
CREATE INDEX CONCURRENTLY edit_note_idx_post_time_edit ON edit_note (post_time DESC NULLS LAST, edit DESC);
