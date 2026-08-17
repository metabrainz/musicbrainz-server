\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE artist_noindex
   ADD CONSTRAINT artist_noindex_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id)
   ON DELETE CASCADE;

COMMIT;
