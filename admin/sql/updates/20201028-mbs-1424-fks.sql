\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE release_first_release_date
   ADD CONSTRAINT release_first_release_date_fk_release
   FOREIGN KEY (release)
   REFERENCES release(id)
   ON DELETE CASCADE;

ALTER TABLE recording_first_release_date
  ADD CONSTRAINT recording_first_release_date_fk_recording
  FOREIGN KEY (recording)
  REFERENCES recording(id)
  ON DELETE CASCADE;

COMMIT;
