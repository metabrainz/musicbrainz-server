\set ON_ERROR_STOP 1

BEGIN;

DELETE FROM tracklist_index WHERE tracklist IN (
       SELECT tracklist_index.tracklist
       FROM tracklist_index
       LEFT JOIN tracklist ON tracklist_index.tracklist = tracklist.id
       WHERE tracklist.id IS NULL);

ALTER TABLE tracklist_index ADD COLUMN medium INTEGER;
UPDATE tracklist_index
    SET medium = m.id
    FROM (SELECT id,tracklist FROM medium) m
    WHERE tracklist_index.tracklist = m.tracklist;
ALTER TABLE tracklist_index ALTER COLUMN medium SET NOT NULL;
ALTER TABLE tracklist_index DROP COLUMN tracklist;
ALTER TABLE tracklist_index RENAME TO medium_index;

COMMIT;
