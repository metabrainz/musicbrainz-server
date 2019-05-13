\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE editor_collection_area ADD COLUMN position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0);
ALTER TABLE editor_collection_artist ADD COLUMN position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0);
ALTER TABLE editor_collection_event ADD COLUMN position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0);
ALTER TABLE editor_collection_instrument ADD COLUMN position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0);
ALTER TABLE editor_collection_label ADD COLUMN position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0);
ALTER TABLE editor_collection_place ADD COLUMN position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0);
ALTER TABLE editor_collection_recording ADD COLUMN position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0);
ALTER TABLE editor_collection_release ADD COLUMN position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0);
ALTER TABLE editor_collection_release_group ADD COLUMN position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0);
ALTER TABLE editor_collection_series ADD COLUMN position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0);
ALTER TABLE editor_collection_work ADD COLUMN position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0);
ALTER TABLE editor_collection_deleted_entity ADD COLUMN position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0);

COMMIT;
