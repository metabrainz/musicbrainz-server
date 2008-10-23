\set ON_ERROR_STOP 1

BEGIN;



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
	ignoreattributes				INTEGER[] DEFAULT '{0,3,4,5,6,7,8,9,10,11,101,102,103}' -- list of attributes to ignore releases of
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

-- an unique index made out of all the fields in the collection_has_release_join table. used to not allow duplicates of tuples
CREATE UNIQUE INDEX collection_info_moderator ON collection_info (moderator);
CREATE UNIQUE INDEX collection_has_release_join_combined_index ON collection_has_release_join (collection_info, album);
CREATE UNIQUE INDEX collection_discography_artist_join_combined_index ON collection_discography_artist_join (collection_info, artist);
CREATE UNIQUE INDEX collection_ignore_release_combined_index ON collection_ignore_release_join (collection_info, album);
CREATE UNIQUE INDEX collection_watch_artist_combined_index ON collection_watch_artist_join (collection_info, artist);

CREATE INDEX collection_has_release_join_collection_info ON collection_has_release_join (collection_info);
CREATE INDEX collection_ignore_release_join_collection_info ON collection_ignore_release_join (collection_info);
CREATE INDEX collection_discography_artist_join_collection_info ON collection_discography_artist_join (collection_info);
CREATE INDEX collection_watch_artist_join_collection_info ON collection_watch_artist_join (collection_info);

CREATE INDEX collection_has_release_join_album ON collection_has_release_join (album);
CREATE INDEX collection_ignore_release_join_album ON collection_ignore_release_join (album);
CREATE INDEX collection_discography_artist_join_artist ON collection_discography_artist_join (artist);
CREATE INDEX collection_watch_artist_join_artist ON collection_watch_artist_join (artist);

ALTER TABLE collection_info ADD CONSTRAINT collection_info_pkey PRIMARY KEY (id);
ALTER TABLE collection_ignore_time_range ADD CONSTRAINT collection_ignore_time_range_pkey PRIMARY KEY (id);
ALTER TABLE collection_watch_artist_join ADD CONSTRAINT collection_watch_artist_join_pkey PRIMARY KEY (id);
ALTER TABLE collection_discography_artist_join ADD CONSTRAINT collection_discography_artist_join_pkey PRIMARY KEY (id);
ALTER TABLE collection_ignore_release_join ADD CONSTRAINT collection_ignore_release_join_pkey PRIMARY KEY (id);
ALTER TABLE collection_has_release_join ADD CONSTRAINT collection_has_release_join_pkey PRIMARY KEY (id);

COMMIT;
