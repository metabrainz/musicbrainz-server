CREATE INDEX CONCURRENTLY release_tag_idx_tag ON release_tag (tag);

CREATE INDEX CONCURRENTLY release_tag_raw_idx_tag ON release_tag_raw (tag);
CREATE INDEX CONCURRENTLY release_tag_raw_idx_editor ON release_tag_raw (editor);

CREATE INDEX CONCURRENTLY work_tag_raw_idx_tag ON work_tag_raw (tag);

CREATE INDEX CONCURRENTLY tag_relation_idx_tag2 ON tag_relation (tag2);

BEGIN;
SELECT delete_unused_tag(id) INTO discard_output FROM tag;
COMMIT;
