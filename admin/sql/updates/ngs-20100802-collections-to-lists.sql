BEGIN;

ALTER TABLE collection RENAME TO list;
ALTER TABLE collection_release RENAME TO list_release;

ALTER TABLE list_release RENAME COLUMN collection TO list;

ALTER INDEX collection_idx_gid RENAME TO list_idx_gid;
ALTER INDEX collection_idx_name RENAME TO list_idx_name;

CREATE INDEX list_idx_editor ON list (editor);

COMMIT;
