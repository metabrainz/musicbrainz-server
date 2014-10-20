\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE editor_collection_event
   ADD CONSTRAINT editor_collection_event_fk_collection
   FOREIGN KEY (collection)
   REFERENCES editor_collection(id);

ALTER TABLE editor_collection_event
   ADD CONSTRAINT editor_collection_event_fk_event
   FOREIGN KEY (event)
   REFERENCES event(id);

COMMIT;
