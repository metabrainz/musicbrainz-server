\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE artist_tag_raw
(
    artist              INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    moderator           INTEGER NOT NULL
);

CREATE TABLE release_tag_raw
(
    release             INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    moderator           INTEGER NOT NULL
);

CREATE TABLE track_tag_raw
(
    track               INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    moderator           INTEGER NOT NULL
);

CREATE TABLE label_tag_raw
(
    label               INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    moderator           INTEGER NOT NULL
);

CREATE TABLE collection_info
(
	id								SERIAL,
	moderator						INTEGER NOT NULL, -- references moderator
	--collection_watch				INTEGER NOT NULL, -- references collection_watch
	collection_ignore_time_range	INTEGER, -- references collection_ignore_time_range
	lastcheck						TIMESTAMP,
	publiccollection				BOOLEAN NOT NULL, -- publicly display collection?
	emailnotifications				BOOLEAN DEFAULT TRUE, -- send notifications by e-mail?
	notificationinterval			INTEGER DEFAULT 7, -- specifies how many days in advance of a release date the user want to be notified
	ignorecollectionattributes		INTEGER[], -- list of attributes to ignore when displaying missing releases
	ignorewatchattributes				INTEGER[] -- list of attributes to ignore when sending notifications
);

CREATE TABLE collection_ignore_time_range
(
	id				SERIAL,
	rangestart		TIMESTAMP NOT NULL,
	rangeend		TIMESTAMP NOT NULL
);

CREATE TABLE collection_watch_artist_join
(
	id					SERIAL,
	collection_info		INTEGER NOT NULL,
	artist				INTEGER NOT NULL
);

CREATE TABLE collection_discography_artist_join
(
	id					SERIAL,
	collection_info		INTEGER NOT NULl, -- references collection_info
	artist				INTEGER NOT NULL -- references artist
);

CREATE TABLE collection_ignore_release_join
(
	id					SERIAL,
	collection_info		INTEGER NOT NULl, -- references collection_info
	album				INTEGER NOT NULL -- references album
);

CREATE TABLE collection_has_release_join
(
	id					SERIAL,
	collection_info		INTEGER NOT NULl, -- references collection_info
	album				INTEGER NOT NULL -- references album
);





CREATE INDEX artist_tag_raw_idx_artist ON artist_tag_raw (artist);
CREATE INDEX artist_tag_raw_idx_tag ON artist_tag_raw (tag);
CREATE INDEX artist_tag_raw_idx_moderator ON artist_tag_raw (moderator);

CREATE INDEX release_tag_raw_idx_release ON release_tag_raw (release);
CREATE INDEX release_tag_raw_idx_tag ON release_tag_raw (tag);
CREATE INDEX release_tag_raw_idx_moderator ON release_tag_raw (moderator);

CREATE INDEX track_tag_raw_idx_track ON track_tag_raw (track);
CREATE INDEX track_tag_raw_idx_tag ON track_tag_raw (tag);
CREATE INDEX track_tag_raw_idx_moderator ON track_tag_raw (moderator);

CREATE INDEX label_tag_raw_idx_label ON label_tag_raw (label);
CREATE INDEX label_tag_raw_idx_tag ON label_tag_raw (tag);
CREATE INDEX label_tag_raw_idx_moderator ON label_tag_raw (moderator);

-- an unique index made out of all the fields in the collection_has_release_join table. used to not allow duplicates of tuples
CREATE UNIQUE INDEX collection_has_release_join_combined_index ON collection_has_release_join (id, collection_info, album);




ALTER TABLE artist_tag_raw ADD CONSTRAINT artist_tag_raw_pkey PRIMARY KEY (artist, tag, moderator);
ALTER TABLE release_tag_raw ADD CONSTRAINT release_tag_raw_pkey PRIMARY KEY (release, tag, moderator);
ALTER TABLE track_tag_raw ADD CONSTRAINT track_tag_raw_pkey PRIMARY KEY (track, tag, moderator);
ALTER TABLE label_tag_raw ADD CONSTRAINT label_tag_raw_pkey PRIMARY KEY (label, tag, moderator);
ALTER TABLE collection_info ADD CONSTRAINT collection_info_pkey PRIMARY KEY (id);
ALTER TABLE collection_ignore_time_range ADD CONSTRAINT collection_ignore_time_range_pkey PRIMARY KEY (id);
ALTER TABLE collection_watch_artist_join ADD CONSTRAINT collection_watch_artist_join_pkey PRIMARY KEY (id);
ALTER TABLE collection_discography_artist_join ADD CONSTRAINT collection_discography_artist_join_pkey PRIMARY KEY (id);
ALTER TABLE collection_ignore_release_join ADD CONSTRAINT collection_ignore_release_join_pkey PRIMARY KEY (id);
ALTER TABLE collection_has_release_join ADD CONSTRAINT collection_has_release_join_pkey PRIMARY KEY (id);

COMMIT;