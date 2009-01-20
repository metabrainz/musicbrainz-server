\unset ON_ERROR_STOP

-- Alphabetical order by table

ALTER TABLE artist_rating_raw DROP CONSTRAINT artist_rating_raw_pkey;
ALTER TABLE artist_tag_raw DROP CONSTRAINT artist_tag_raw_pkey;

ALTER TABLE cdtoc_raw DROP CONSTRAINT cdtoc_raw_pkey;
ALTER TABLE collection_info DROP CONSTRAINT collection_info_pkey;
ALTER TABLE collection_ignore_time_range DROP CONSTRAINT collection_ignore_time_range_pkey;
ALTER TABLE collection_watch_artist_join DROP CONSTRAINT collection_watch_artist_join_pkey;
ALTER TABLE collection_discography_artist_join DROP CONSTRAINT collection_discography_artist_join_pkey;
ALTER TABLE collection_ignore_release_join DROP CONSTRAINT collection_ignore_release_join_pkey;
ALTER TABLE collection_has_release_join DROP CONSTRAINT collection_has_release_join_pkey;

ALTER TABLE label_rating_raw DROP CONSTRAINT label_rating_raw_pkey;
ALTER TABLE label_tag_raw DROP CONSTRAINT label_tag_raw_pkey;

ALTER TABLE release_raw DROP CONSTRAINT release_raw_pkey;
ALTER TABLE release_rating_raw DROP CONSTRAINT release_rating_raw_pkey;
ALTER TABLE release_tag_raw DROP CONSTRAINT release_tag_raw_pkey;

ALTER TABLE track_raw DROP CONSTRAINT track_raw_pkey;
ALTER TABLE track_rating_raw DROP CONSTRAINT track_rating_raw_pkey;
ALTER TABLE track_tag_raw DROP CONSTRAINT track_tag_raw_pkey;

-- vi: set ts=4 sw=4 et :
