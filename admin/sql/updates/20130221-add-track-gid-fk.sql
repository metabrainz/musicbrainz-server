\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE track_gid_redirect
   ADD CONSTRAINT track_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES track(id);

COMMIT;
