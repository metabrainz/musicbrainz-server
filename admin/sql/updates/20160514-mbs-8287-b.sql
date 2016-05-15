\set ON_ERROR_STOP 1
BEGIN;

CREATE TABLE editor_collection_deleted_entity (
    collection INTEGER NOT NULL,
    gid UUID NOT NULL
);

ALTER TABLE editor_collection_deleted_entity ADD CONSTRAINT editor_collection_deleted_entity_pkey PRIMARY KEY (collection, gid);

COMMIT;
