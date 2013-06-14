\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE track_gid_redirect ADD CONSTRAINT track_gid_redirect_fk_new_id
   FOREIGN KEY (new_id) REFERENCES track(id);

ALTER TABLE medium_index ADD CONSTRAINT medium_index_fk_medium
   FOREIGN KEY (medium) REFERENCES medium(id) ON DELETE CASCADE;

ALTER TABLE track ADD CONSTRAINT track_fk_artist_credit
   FOREIGN KEY (artist_credit) REFERENCES artist_credit(id);

ALTER TABLE track ADD CONSTRAINT track_fk_recording
   FOREIGN KEY (recording) REFERENCES recording(id);

ALTER TABLE track ADD CONSTRAINT track_fk_medium
   FOREIGN KEY (medium) REFERENCES medium(id);

ALTER TABLE track ADD CONSTRAINT track_fk_name
   FOREIGN KEY (name) REFERENCES track_name(id);

ALTER TABLE medium_cdtoc
  DROP CONSTRAINT IF EXISTS medium_cdtoc_fk_medium,
  ADD CONSTRAINT medium_cdtoc_fk_medium FOREIGN KEY (medium) REFERENCES medium (id);

COMMIT;
