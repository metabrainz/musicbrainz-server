-- Automatically generated, do not edit.
\set ON_ERROR_STOP 1

SET search_path = 'event_art_archive';

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

