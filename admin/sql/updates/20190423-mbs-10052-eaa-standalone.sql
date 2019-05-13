\set ON_ERROR_STOP 1
BEGIN;

SET search_path = 'event_art_archive';

-- Foreign keys

ALTER TABLE event_art
   ADD CONSTRAINT event_art_fk_edit
   FOREIGN KEY (edit)
   REFERENCES musicbrainz.edit(id);

ALTER TABLE art_type
   ADD CONSTRAINT art_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES event_art_archive.art_type(id);

ALTER TABLE event_art
   ADD CONSTRAINT event_art_fk_event
   FOREIGN KEY (event)
   REFERENCES musicbrainz.event(id)
   ON DELETE CASCADE;

ALTER TABLE event_art
   ADD CONSTRAINT event_art_fk_mime_type
   FOREIGN KEY (mime_type)
   REFERENCES cover_art_archive.image_type(mime_type);

ALTER TABLE event_art_type
   ADD CONSTRAINT event_art_type_fk_id
   FOREIGN KEY (id)
   REFERENCES event_art_archive.event_art(id)
   ON DELETE CASCADE;

ALTER TABLE event_art_type
   ADD CONSTRAINT event_art_type_fk_type_id
   FOREIGN KEY (type_id)
   REFERENCES event_art_archive.art_type(id);

-- Triggers

CREATE TRIGGER update_event_art AFTER INSERT OR DELETE
ON event_art_archive.event_art
FOR EACH ROW EXECUTE PROCEDURE materialize_eaa_presence();

CREATE CONSTRAINT TRIGGER resquence_event_art AFTER INSERT OR UPDATE OR DELETE
ON event_art_archive.event_art DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE resequence_event_art_trigger();

COMMIT;
