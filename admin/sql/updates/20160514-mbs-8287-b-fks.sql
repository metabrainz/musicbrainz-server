\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE editor_collection_deleted_entity
   ADD CONSTRAINT editor_collection_deleted_entity_fk_collection
   FOREIGN KEY (collection)
   REFERENCES editor_collection(id);

ALTER TABLE editor_collection_deleted_entity
   ADD CONSTRAINT editor_collection_deleted_entity_fk_gid
   FOREIGN KEY (gid)
   REFERENCES deleted_entity(gid);

COMMIT;
