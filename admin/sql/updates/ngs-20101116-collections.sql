BEGIN;

ALTER TABLE list RENAME TO editor_collection;
ALTER TABLE list_release RENAME TO editor_collection_release;

ALTER TABLE editor_collection_release RENAME COLUMN list TO collection;

ALTER INDEX list_idx_gid RENAME TO editor_collection_idx_gid;
ALTER INDEX list_idx_name RENAME TO editor_collection_idx_name;
ALTER INDEX list_idx_editor RENAME TO editor_collection_idx_editor;

COMMIT;
