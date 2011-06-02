BEGIN;

ALTER TABLE recording ADD CONSTRAINT
      recording_length CHECK (length IS NULL OR length > 0);

ALTER TABLE track ADD CONSTRAINT
      track_length CHECK (length IS NULL OR length > 0);

COMMIT;
