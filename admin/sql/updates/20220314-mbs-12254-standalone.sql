\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE genre_annotation
   ADD CONSTRAINT genre_annotation_fk_genre
   FOREIGN KEY (genre)
   REFERENCES genre(id);

ALTER TABLE genre_annotation
   ADD CONSTRAINT genre_annotation_fk_annotation
   FOREIGN KEY (annotation)
   REFERENCES annotation(id);

COMMIT;
