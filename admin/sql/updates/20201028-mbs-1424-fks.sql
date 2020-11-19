\set ON_ERROR_STOP 1

SET search_path = musicbrainz;

BEGIN;

ALTER TABLE recording_first_release_date
  ADD CONSTRAINT recording_first_release_date_fk_recording
  FOREIGN KEY (recording)
  REFERENCES recording(id)
  ON DELETE CASCADE;

COMMIT;
