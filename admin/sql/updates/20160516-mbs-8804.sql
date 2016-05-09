\set ON_ERROR_STOP 1
BEGIN;

DROP INDEX IF EXISTS edit_idx_open_time;
DROP INDEX IF EXISTS edit_idx_close_time;
DROP INDEX IF EXISTS edit_idx_expire_time;
CREATE INDEX edit_idx_open_time ON edit USING BRIN (open_time);
CREATE INDEX edit_idx_close_time ON edit USING BRIN (close_time);
CREATE INDEX edit_idx_expire_time ON edit USING BRIN (expire_time);

DROP INDEX IF EXISTS edit_note_idx_post_time;
CREATE INDEX edit_note_idx_post_time ON edit_note USING BRIN (post_time);

DROP INDEX IF EXISTS vote_idx_vote_time;
CREATE INDEX vote_idx_vote_time ON vote USING BRIN (vote_time);

COMMIT;
