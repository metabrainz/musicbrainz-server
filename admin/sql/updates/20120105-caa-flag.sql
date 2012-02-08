BEGIN;

CREATE TYPE cover_art_presence AS ENUM ('absent', 'present', 'darkened');

ALTER TABLE release_meta ADD COLUMN cover_art_presence cover_art_presence NOT NULL DEFAULT 'absent';

COMMIT;
