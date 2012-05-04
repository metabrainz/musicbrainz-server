BEGIN;

CREATE INDEX cover_art_idx_release ON cover_art (release);

COMMIT;
