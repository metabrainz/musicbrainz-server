-- Abstract: Create rating tables
  	
\set ON_ERROR_STOP  
  	
BEGIN;

-- The detailed/raw rating tables (live on a separate server, so no FKs to the main table).  
   	
CREATE TABLE artist_rating_raw
(
    artist      INTEGER NOT NULL,
    editor      INTEGER NOT NULL,
    rating      INTEGER NOT NULL
);
   	
CREATE TABLE release_rating_raw
(
    release     INTEGER NOT NULL,
    editor      INTEGER NOT NULL,
    rating      INTEGER NOT NULL
);
   	
CREATE TABLE track_rating_raw
(
    track       INTEGER NOT NULL,
    editor      INTEGER NOT NULL,
    rating      INTEGER NOT NULL
);
   	
CREATE TABLE label_rating_raw
(
    label       INTEGER NOT NULL,
    editor      INTEGER NOT NULL,
    rating      INTEGER NOT NULL
);
   	
	-- primary keys
   	
ALTER TABLE artist_rating_raw ADD CONSTRAINT artist_rating_raw_pkey PRIMARY KEY (artist, editor);
ALTER TABLE release_rating_raw ADD CONSTRAINT release_rating_raw_pkey PRIMARY KEY (release, editor);
ALTER TABLE track_rating_raw ADD CONSTRAINT track_rating_raw_pkey PRIMARY KEY (track, editor);
ALTER TABLE label_rating_raw ADD CONSTRAINT label_rating_raw_pkey PRIMARY KEY (label, editor);
   	
   	-- indexes
    	
CREATE INDEX artist_rating_raw_idx_artist ON artist_rating_raw (artist);
CREATE INDEX artist_rating_raw_idx_editor ON artist_rating_raw (editor);
    	
CREATE INDEX release_rating_raw_idx_release ON release_rating_raw (release);
CREATE INDEX release_rating_raw_idx_editor ON release_rating_raw (editor);
    	
CREATE INDEX track_rating_raw_idx_track ON track_rating_raw (track);
CREATE INDEX track_rating_raw_idx_editor ON track_rating_raw (editor);
    	
CREATE INDEX label_rating_raw_idx_label ON label_rating_raw (label);
CREATE INDEX label_rating_raw_idx_editor ON label_rating_raw (editor);
    	
COMMIT;
