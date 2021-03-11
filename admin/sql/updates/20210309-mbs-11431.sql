\set ON_ERROR_STOP 1

BEGIN;

CREATE INDEX CONCURRENTLY artist_idx_lower_unaccent_name_comment ON artist (lower(musicbrainz_unaccent(name)), lower(musicbrainz_unaccent(comment)));
CREATE INDEX CONCURRENTLY label_idx_lower_unaccent_name_comment ON label (lower(musicbrainz_unaccent(name)), lower(musicbrainz_unaccent(comment)));
CREATE INDEX CONCURRENTLY place_idx_lower_unaccent_name_comment ON place (lower(musicbrainz_unaccent(name)), lower(musicbrainz_unaccent(comment)));
CREATE INDEX CONCURRENTLY series_idx_lower_unaccent_name_comment ON series (lower(musicbrainz_unaccent(name)), lower(musicbrainz_unaccent(comment)));

CREATE INDEX CONCURRENTLY artist_alias_idx_lower_unaccent_name ON artist_alias (lower(musicbrainz_unaccent(name)));
CREATE INDEX CONCURRENTLY label_alias_idx_lower_unaccent_name ON label_alias (lower(musicbrainz_unaccent(name)));
CREATE INDEX CONCURRENTLY place_alias_idx_lower_unaccent_name ON place_alias (lower(musicbrainz_unaccent(name)));
CREATE INDEX CONCURRENTLY series_alias_idx_lower_unaccent_name ON series_alias (lower(musicbrainz_unaccent(name)));

DROP INDEX CONCURRENTLY IF EXISTS artist_idx_lower_name;
DROP INDEX CONCURRENTLY IF EXISTS label_idx_lower_name;

COMMIT;
