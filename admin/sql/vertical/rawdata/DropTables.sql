\set ON_ERROR_STOP 1
BEGIN;

DROP TABLE artist_rating_raw;
DROP TABLE artist_tag_raw;
DROP TABLE cdtoc_raw;
DROP TABLE collection_info;
DROP TABLE collection_ignore_time_range;
DROP TABLE collection_watch_artist_join;
DROP TABLE collection_discography_artist_join;
DROP TABLE collection_ignore_release_join;
DROP TABLE collection_has_release_join;
DROP TABLE label_rating_raw;
DROP TABLE label_tag_raw;
DROP TABLE release_rating_raw;
DROP TABLE release_raw;
DROP TABLE release_tag_raw;
DROP TABLE track_raw;
DROP TABLE track_rating_raw;
DROP TABLE track_tag_raw;

COMMIT;

-- vi: set ts=4 sw=4 et :
