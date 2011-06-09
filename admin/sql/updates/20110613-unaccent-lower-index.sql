\set ON_ERROR_STOP 1

-- MBS-2347: Artist and Label name indexes for missing entities in the release editor.

BEGIN;
CREATE INDEX artist_name_idx_unaccent_lower_name ON artist_name (unaccent(lower(name)));
CREATE INDEX label_name_idx_unaccent_lower_name ON label_name (unaccent(lower(name)));
COMMIT;

