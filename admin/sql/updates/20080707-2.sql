-- Abstract: Create rating tables
  	
\set ON_ERROR_STOP  
  	
BEGIN;

-- The detailed/raw rating tables (live on a separate server, so no FKs to the main table).  
   	
CREATE TABLE artist_rating_raw
(
    artist              INTEGER NOT NULL,
    rating             INTEGER NOT NULL,
    moderator     INTEGER NOT NULL
);
   	
CREATE TABLE release_rating_raw
(
    release          INTEGER NOT NULL,
    rating            INTEGER NOT NULL,
    moderator    INTEGER NOT NULL
);
   	
CREATE TABLE track_rating_raw
(
    track            INTEGER NOT NULL,
    rating           INTEGER NOT NULL,
    moderator   INTEGER NOT NULL
);
   	
CREATE TABLE label_rating_raw
(
    label            INTEGER NOT NULL,
    rating            INTEGER NOT NULL,
    moderator    INTEGER NOT NULL
);
   	
	-- primary keys
   	
ALTER TABLE artist_rating_raw ADD CONSTRAINT artist_rating_raw_pkey PRIMARY KEY (artist, rating, moderator);
ALTER TABLE release_rating_raw ADD CONSTRAINT release_rating_raw_pkey PRIMARY KEY (release, rating, moderator);
ALTER TABLE track_rating_raw ADD CONSTRAINT track_rating_raw_pkey PRIMARY KEY (track, rating, moderator);
ALTER TABLE label_rating_raw ADD CONSTRAINT label_rating_raw_pkey PRIMARY KEY (label, rating, moderator);
   	
   	-- indexes
    	
CREATE INDEX artist_rating_raw_idx_artist ON artist_rating_raw (artist);
CREATE INDEX artist_rating_raw_idx_rating ON artist_rating_raw (rating);
CREATE INDEX artist_rating_raw_idx_moderator ON artist_rating_raw (moderator);
    	
CREATE INDEX release_rating_raw_idx_release ON release_rating_raw (release);
CREATE INDEX release_rating_raw_idx_rating ON release_rating_raw (rating);
CREATE INDEX release_rating_raw_idx_moderator ON release_rating_raw (moderator);
    	
CREATE INDEX track_rating_raw_idx_track ON track_rating_raw (track);
CREATE INDEX track_rating_raw_idx_rating ON track_rating_raw (rating);
CREATE INDEX track_rating_raw_idx_moderator ON track_rating_raw (moderator);
    	
CREATE INDEX label_rating_raw_idx_label ON label_rating_raw (label);
CREATE INDEX label_rating_raw_idx_rating ON label_rating_raw (rating);
CREATE INDEX label_rating_raw_idx_moderator ON label_rating_raw (moderator);
    	
COMMIT;
