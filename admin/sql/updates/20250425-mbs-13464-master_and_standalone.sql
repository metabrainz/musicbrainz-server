\set ON_ERROR_STOP 1

SET search_path = musicbrainz;

BEGIN;

ALTER TABLE artist_release
   ADD CONSTRAINT artist_release_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id)
   ON DELETE CASCADE;

ALTER TABLE artist_release
   ADD CONSTRAINT artist_release_fk_release
   FOREIGN KEY (release)
   REFERENCES release(id)
   ON DELETE CASCADE;

COMMIT;
