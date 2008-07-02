\unset ON_ERROR_STOP

ALTER TABLE artist_tag_raw DROP CONSTRAINT artist_tag_raw_pkey;
ALTER TABLE release_tag_raw DROP CONSTRAINT release_tag_raw_pkey;
ALTER TABLE track_tag_raw DROP CONSTRAINT track_tag_raw_pkey;
ALTER TABLE label_tag_raw DROP CONSTRAINT label_tag_raw_pkey;