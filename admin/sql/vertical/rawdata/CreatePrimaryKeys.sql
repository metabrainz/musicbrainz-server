\set ON_ERROR_STOP 1

-- Alphabetical order by table

ALTER TABLE artist_rating_raw ADD CONSTRAINT artist_rating_raw_pkey PRIMARY KEY (artist, editor);
ALTER TABLE artist_tag_raw ADD CONSTRAINT artist_tag_raw_pkey PRIMARY KEY (artist, tag, moderator);
ALTER TABLE release_rating_raw ADD CONSTRAINT release_rating_raw_pkey PRIMARY KEY (release, editor);
ALTER TABLE release_tag_raw ADD CONSTRAINT release_tag_raw_pkey PRIMARY KEY (release, tag, moderator);
ALTER TABLE track_rating_raw ADD CONSTRAINT track_rating_raw_pkey PRIMARY KEY (track, editor);
ALTER TABLE track_tag_raw ADD CONSTRAINT track_tag_raw_pkey PRIMARY KEY (track, tag, moderator);
ALTER TABLE label_rating_raw ADD CONSTRAINT label_rating_raw_pkey PRIMARY KEY (label, editor);
ALTER TABLE label_tag_raw ADD CONSTRAINT label_tag_raw_pkey PRIMARY KEY (label, tag, moderator);

-- vi: set ts=4 sw=4 et :
