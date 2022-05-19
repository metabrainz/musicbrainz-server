\set ON_ERROR_STOP 1

SET search_path = musicbrainz;

BEGIN;

ALTER TABLE artist_credit_gid_redirect
   ADD CONSTRAINT artist_credit_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES artist_credit(id);

COMMIT;
