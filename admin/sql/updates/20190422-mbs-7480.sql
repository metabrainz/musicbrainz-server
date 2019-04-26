\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE cover_art_archive.cover_art ADD COLUMN filesize INTEGER;
ALTER TABLE cover_art_archive.cover_art ADD COLUMN thumb_250_filesize INTEGER;
ALTER TABLE cover_art_archive.cover_art ADD COLUMN thumb_500_filesize INTEGER;
ALTER TABLE cover_art_archive.cover_art ADD COLUMN thumb_1200_filesize INTEGER;

COMMIT;
