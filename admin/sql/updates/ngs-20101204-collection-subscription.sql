BEGIN;

ALTER TABLE editor_collection ADD COLUMN subscribed BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE editor_collection ADD COLUMN last_edit_sent INTEGER
    CHECK (NOT subscribed OR last_edit_sent IS NOT NULL);

ALTER TABLE editor_collection_release ADD COLUMN deleted_by_edit INTEGER;
ALTER TABLE editor_collection_release ADD COLUMN merged_by_edit INTEGER;

COMMIT;
