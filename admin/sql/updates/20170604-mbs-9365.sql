\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE event_meta DROP CONSTRAINT IF EXISTS event_meta_fk_id;

ALTER TABLE event_meta
   ADD CONSTRAINT event_meta_fk_id
   FOREIGN KEY (id)
   REFERENCES event(id)
   ON DELETE CASCADE;

COMMIT;
