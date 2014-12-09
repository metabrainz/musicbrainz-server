DROP INDEX IF EXISTS edit_idx_editor;

CREATE INDEX CONCURRENTLY edit_idx_type_id ON edit (type, id);
DROP INDEX IF EXISTS edit_idx_type;

CREATE INDEX CONCURRENTLY edit_idx_editor_open_time ON edit (editor, open_time);

CREATE INDEX CONCURRENTLY edit_idx_status_id ON edit (status, id) WHERE status <> 2;
DROP INDEX IF EXISTS edit_idx_status;

CREATE INDEX CONCURRENTLY edit_idx_close_time ON edit (close_time);
CREATE INDEX CONCURRENTLY edit_idx_expire_time ON edit (expire_time);

ANALYZE edit;


CREATE INDEX CONCURRENTLY vote_idx_editor_vote_time ON vote (editor, vote_time);
CREATE INDEX CONCURRENTLY vote_idx_editor_edit ON vote (editor, edit) WHERE superseded = FALSE;
DROP INDEX IF EXISTS vote_idx_editor;

ALTER INDEX edit_idx_vote_time RENAME TO vote_idx_vote_time;

ANALYZE vote;
