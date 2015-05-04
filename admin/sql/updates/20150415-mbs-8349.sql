\set ON_ERROR_STOP 1
BEGIN;

-- Drop old indexes where they exist.
DROP INDEX IF EXISTS track_idx_medium;
DROP INDEX IF EXISTS track_idx_uniq_medium_position;
DROP INDEX IF EXISTS medium_idx_release;
DROP INDEX IF EXISTS medium_idx_uniq;

-- Drop new indexes in the case of very new slave databases
DROP INDEX IF EXISTS medium_idx_release_position;
DROP INDEX IF EXISTS track_idx_medium_position;

-- Drop new constraints (should only exist if they were created manually).
ALTER TABLE track DROP CONSTRAINT IF EXISTS track_uniq_medium_position;
ALTER TABLE medium DROP CONSTRAINT IF EXISTS medium_uniq;

-- Create new slave-only indexes.
CREATE INDEX medium_idx_release_position ON medium (release, position);
CREATE INDEX track_idx_medium_position ON track (medium, position);

COMMIT;
