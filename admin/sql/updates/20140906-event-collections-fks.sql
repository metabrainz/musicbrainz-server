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

ALTER TABLE editor_collection_type ADD CONSTRAINT allowed_collection_entity_type
  CHECK (
    entity_type IN (
      'event',
      'release'
    )
  );

COMMIT;
