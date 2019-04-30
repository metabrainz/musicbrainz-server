\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE editor_collection_area ADD COLUMN added TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE editor_collection_artist ADD COLUMN added TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE editor_collection_event ADD COLUMN added TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE editor_collection_instrument ADD COLUMN added TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE editor_collection_label ADD COLUMN added TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE editor_collection_place ADD COLUMN added TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE editor_collection_recording ADD COLUMN added TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE editor_collection_release ADD COLUMN added TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE editor_collection_release_group ADD COLUMN added TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE editor_collection_series ADD COLUMN added TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE editor_collection_work ADD COLUMN added TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE editor_collection_deleted_entity ADD COLUMN added TIMESTAMP WITH TIME ZONE DEFAULT NOW();

UPDATE editor_collection_area SET added = NULL;
UPDATE editor_collection_artist SET added = NULL;
UPDATE editor_collection_event SET added = NULL;
UPDATE editor_collection_instrument SET added = NULL;
UPDATE editor_collection_label SET added = NULL;
UPDATE editor_collection_place SET added = NULL;
UPDATE editor_collection_recording SET added = NULL;
UPDATE editor_collection_release SET added = NULL;
UPDATE editor_collection_release_group SET added = NULL;
UPDATE editor_collection_series SET added = NULL;
UPDATE editor_collection_work SET added = NULL;
UPDATE editor_collection_deleted_entity SET added = NULL;

COMMIT;
