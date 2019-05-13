\set ON_ERROR_STOP 1

SET search_path = 'event_art_archive';

ALTER TABLE event_art
   ADD CONSTRAINT event_art_fk_edit
   FOREIGN KEY (edit)
   REFERENCES musicbrainz.edit(id);
