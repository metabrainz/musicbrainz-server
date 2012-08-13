-- Automatically generated, do not edit.
\set ON_ERROR_STOP 1

SET search_path = 'cover_art_archive';

ALTER TABLE cover_art
   ADD CONSTRAINT cover_art_fk_release
   FOREIGN KEY (release)
   REFERENCES musicbrainz.release(id)
   ON DELETE CASCADE;

ALTER TABLE cover_art
   ADD CONSTRAINT cover_art_fk_edit
   FOREIGN KEY (edit)
   REFERENCES musicbrainz.edit(id);

ALTER TABLE cover_art_type
   ADD CONSTRAINT cover_art_type_fk_id
   FOREIGN KEY (id)
   REFERENCES cover_art_archive.cover_art(id)
   ON DELETE CASCADE;

ALTER TABLE cover_art_type
   ADD CONSTRAINT cover_art_type_fk_type_id
   FOREIGN KEY (type_id)
   REFERENCES art_type(id);

