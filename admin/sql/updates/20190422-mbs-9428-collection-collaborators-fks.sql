\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE editor_collection_collaborator
   ADD CONSTRAINT editor_collection_collaborator_fk_collection
   FOREIGN KEY (collection)
   REFERENCES editor_collection(id);

ALTER TABLE editor_collection_collaborator
   ADD CONSTRAINT editor_collection_collaborator_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

COMMIT;
