\set ON_ERROR_STOP 1

BEGIN;

SET search_path = 'cover_art_archive';

ALTER TABLE cover_art
      ADD COLUMN edits_pending INTEGER NOT NULL DEFAULT 0
      CHECK (edits_pending >= 0);

COMMIT;
