\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE artist_isni
   ADD CONSTRAINT artist_isni_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id);

ALTER TABLE label_isni
   ADD CONSTRAINT label_isni_fk_label
   FOREIGN KEY (label)
   REFERENCES label(id);

COMMIT;
