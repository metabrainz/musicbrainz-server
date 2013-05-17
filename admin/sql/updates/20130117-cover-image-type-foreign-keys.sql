\set ON_ERROR_STOP 1

SET search_path = 'cover_art_archive';

BEGIN;

ALTER TABLE cover_art
   ADD FOREIGN KEY (mime_type) REFERENCES image_type(mime_type);

COMMIT;
