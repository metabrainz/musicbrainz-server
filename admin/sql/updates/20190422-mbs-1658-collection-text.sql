\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE editor_collection_area ADD COLUMN comment TEXT DEFAULT '' NOT NULL;
ALTER TABLE editor_collection_artist ADD COLUMN comment TEXT DEFAULT '' NOT NULL;
ALTER TABLE editor_collection_event ADD COLUMN comment TEXT DEFAULT '' NOT NULL;
ALTER TABLE editor_collection_instrument ADD COLUMN comment TEXT DEFAULT '' NOT NULL;
ALTER TABLE editor_collection_label ADD COLUMN comment TEXT DEFAULT '' NOT NULL;
ALTER TABLE editor_collection_place ADD COLUMN comment TEXT DEFAULT '' NOT NULL;
ALTER TABLE editor_collection_recording ADD COLUMN comment TEXT DEFAULT '' NOT NULL;
ALTER TABLE editor_collection_release ADD COLUMN comment TEXT DEFAULT '' NOT NULL;
ALTER TABLE editor_collection_release_group ADD COLUMN comment TEXT DEFAULT '' NOT NULL;
ALTER TABLE editor_collection_series ADD COLUMN comment TEXT DEFAULT '' NOT NULL;
ALTER TABLE editor_collection_work ADD COLUMN comment TEXT DEFAULT '' NOT NULL;
ALTER TABLE editor_collection_deleted_entity ADD COLUMN comment TEXT DEFAULT '' NOT NULL;

COMMIT;
