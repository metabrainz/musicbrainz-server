\set ON_ERROR_STOP 1
BEGIN;

CREATE INDEX IF NOT EXISTS annotation_idx_editor ON annotation (editor);
CREATE INDEX IF NOT EXISTS autoeditor_election_vote_idx_voter ON autoeditor_election_vote (voter);
CREATE INDEX IF NOT EXISTS editor_idx_deleted ON editor (id) WHERE deleted;

COMMIT;
