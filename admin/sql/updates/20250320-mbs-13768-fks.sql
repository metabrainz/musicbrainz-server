\set ON_ERROR_STOP 1

SET search_path = musicbrainz;

BEGIN;

ALTER TABLE medium_gid_redirect
   ADD CONSTRAINT medium_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES medium(id);

COMMIT;
