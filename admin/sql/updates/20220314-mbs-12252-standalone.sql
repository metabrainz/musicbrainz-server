\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE edit_genre
   ADD CONSTRAINT edit_genre_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_genre
   ADD CONSTRAINT edit_genre_fk_genre
   FOREIGN KEY (genre)
   REFERENCES genre(id)
   ON DELETE CASCADE;

COMMIT;
