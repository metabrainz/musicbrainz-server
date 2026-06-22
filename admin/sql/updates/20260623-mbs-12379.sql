\set ON_ERROR_STOP 1
BEGIN;

CREATE INDEX editor_idx_deleted ON editor (deleted);

COMMIT;
