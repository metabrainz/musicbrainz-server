\set ON_ERROR_STOP 1
BEGIN;
DELETE FROM edit_artist WHERE edit IN (SELECT id FROM edit WHERE type = 77);
DELETE FROM edit_release WHERE edit IN (SELECT id FROM edit WHERE type = 77);
DELETE FROM edit_release_group WHERE edit IN (SELECT id FROM edit WHERE type = 77);
COMMIT;

