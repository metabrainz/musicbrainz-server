\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE editor_collection_gid_redirect
   ADD CONSTRAINT editor_collection_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES editor_collection(id);

COMMIT;
