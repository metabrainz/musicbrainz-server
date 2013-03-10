BEGIN;

ALTER TABLE tracklist_index ADD COLUMN medium INTEGER;
UPDATE tracklist_index
    SET medium = m.id
    FROM (SELECT id,tracklist FROM medium) m
    WHERE tracklist_index.tracklist = m.tracklist;
ALTER TABLE tracklist_index ALTER COLUMN medium SET NOT NULL;
ALTER TABLE tracklist_index DROP COLUMN tracklist;
ALTER TABLE tracklist_index RENAME TO medium_index;

DROP INDEX track_idx_tracklist;
DROP INDEX medium_idx_tracklist;
CREATE INDEX track_idx_medium ON track (medium, position);
ALTER TABLE track DROP COLUMN tracklist;
CREATE INDEX medium_idx_track_count ON medium (track_count);
ALTER TABLE medium DROP COLUMN tracklist
ALTER TABLE medium ADD COLUMN track_count INTEGER NOT NULL DEFAULT 0;
CREATE INDEX medium_idx_track_count ON medium (track_count);
DROP TABLE tracklist;

COMMIT;
