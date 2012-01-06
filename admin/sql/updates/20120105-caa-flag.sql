BEGIN;

CREATE TYPE cover_art_prescence AS ENUM ('absent', 'present', 'darkened');

ALTER TABLE release_meta ADD COLUMN cover_art_presence cover_art_prescence NOT NULL DEFAULT 'absent';

COMMIT;
