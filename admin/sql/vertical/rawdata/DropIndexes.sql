\set ON_ERROR_STOP 1

DROP INDEX artist_tag_raw_idx_artist;
DROP INDEX artist_tag_raw_idx_tag;
DROP INDEX artist_tag_raw_idx_moderator;

DROP INDEX release_tag_raw_idx_release;
DROP INDEX release_tag_raw_idx_tag;
DROP INDEX release_tag_raw_idx_moderator;

DROP INDEX track_tag_raw_idx_track;
DROP INDEX track_tag_raw_idx_tag;
DROP INDEX track_tag_raw_idx_moderator;

DROP INDEX label_tag_raw_idx_label;
DROP INDEX label_tag_raw_idx_tag;
DROP INDEX label_tag_raw_idx_moderator;

DROP INDEX collection_has_release_join_combined_index;