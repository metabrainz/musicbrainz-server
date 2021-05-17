\set ON_ERROR_STOP 1

BEGIN;

CREATE INDEX IF NOT EXISTS artist_idx_lower_unaccent_name_comment ON artist (lower(musicbrainz_unaccent(name)), lower(musicbrainz_unaccent(comment)));
CREATE INDEX IF NOT EXISTS label_idx_lower_unaccent_name_comment ON label (lower(musicbrainz_unaccent(name)), lower(musicbrainz_unaccent(comment)));
CREATE INDEX IF NOT EXISTS place_idx_lower_unaccent_name_comment ON place (lower(musicbrainz_unaccent(name)), lower(musicbrainz_unaccent(comment)));
CREATE INDEX IF NOT EXISTS series_idx_lower_unaccent_name_comment ON series (lower(musicbrainz_unaccent(name)), lower(musicbrainz_unaccent(comment)));

CREATE INDEX IF NOT EXISTS artist_alias_idx_lower_unaccent_name ON artist_alias (lower(musicbrainz_unaccent(name)));
CREATE INDEX IF NOT EXISTS label_alias_idx_lower_unaccent_name ON label_alias (lower(musicbrainz_unaccent(name)));
CREATE INDEX IF NOT EXISTS place_alias_idx_lower_unaccent_name ON place_alias (lower(musicbrainz_unaccent(name)));
CREATE INDEX IF NOT EXISTS series_alias_idx_lower_unaccent_name ON series_alias (lower(musicbrainz_unaccent(name)));

DROP INDEX IF EXISTS artist_idx_lower_name;
DROP INDEX IF EXISTS label_idx_lower_name;

COMMIT;
