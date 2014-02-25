\set ON_ERROR_STOP 1

SET search_path = 'cover_art_archive';

ALTER TABLE cover_art
   ADD CONSTRAINT cover_art_fk_edit
   FOREIGN KEY (edit)
   REFERENCES musicbrainz.edit(id);
