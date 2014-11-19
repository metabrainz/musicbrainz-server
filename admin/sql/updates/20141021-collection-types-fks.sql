\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE editor_collection_type
   ADD CONSTRAINT editor_collection_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES editor_collection_type(id);

ALTER TABLE editor_collection
   ADD CONSTRAINT editor_collection_fk_type
   FOREIGN KEY (type)
   REFERENCES editor_collection_type(id);

COMMIT;
