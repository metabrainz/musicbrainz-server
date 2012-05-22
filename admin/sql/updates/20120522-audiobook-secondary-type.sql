BEGIN;

UPDATE release_group SET type = 11 -- Other
WHERE type = 8; -- Audiobook

DELETE FROM editor_watch_release_group_type WHERE release_group_type = 8;
DELETE FROM release_group_primary_type WHERE id = 8;

COMMIT;
