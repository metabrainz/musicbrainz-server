BEGIN;
UPDATE release_meta SET cover_art_presence = 'present' WHERE cover_art_presence = 'absent' AND EXISTS (SELECT TRUE FROM cover_art_archive.cover_art WHERE release = release_meta.id);
COMMIT;
