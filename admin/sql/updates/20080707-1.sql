-- Abstract: Create rating tables
  	
\set ON_ERROR_STOP  
  	
BEGIN;

-- The aggregate rating tables   	
   	
CREATE TABLE artist_rating
(
    artist              INTEGER NOT NULL,
    rating             INTEGER NOT NULL,
    count             INTEGER NOT NULL
);
   	
CREATE TABLE release_rating
(
    release           INTEGER NOT NULL,
    rating             INTEGER NOT NULL,
    count             INTEGER NOT NULL
);
   	
CREATE TABLE track_rating
(
    track             INTEGER NOT NULL,
    rating            INTEGER NOT NULL,
    count            INTEGER NOT NULL
);
   	
CREATE TABLE label_rating
(
    label             INTEGER NOT NULL,
    rating            INTEGER NOT NULL,
    count            INTEGER NOT NULL
);
   	
   	-- primary keys
   	
ALTER TABLE artist_rating ADD CONSTRAINT artist_rating_pkey PRIMARY KEY (artist, rating);
ALTER TABLE release_rating ADD CONSTRAINT release_rating_pkey PRIMARY KEY (release, rating);
ALTER TABLE track_rating ADD CONSTRAINT track_rating_pkey PRIMARY KEY (track, rating);
ALTER TABLE label_rating ADD CONSTRAINT label_rating_pkey PRIMARY KEY (label, rating);
   	
   	-- indexes
   	
CREATE INDEX artist_rating_idx_artist ON artist_rating (artist);
CREATE INDEX artist_rating_idx_rating ON artist_rating (rating);
CREATE INDEX release_rating_idx_release ON release_rating (release);
CREATE INDEX release_rating_idx_rating ON release_rating (rating);
CREATE INDEX track_rating_idx_track ON track_rating (track);
CREATE INDEX track_rating_idx_rating ON track_rating (rating);
CREATE INDEX label_rating_idx_label ON label_rating (label);
CREATE INDEX label_rating_idx_rating ON label_rating (rating);
    	
    	-- foreign keys
ALTER TABLE artist_rating
    	ADD CONSTRAINT fk_artist_rating_artist
    	FOREIGN KEY (artist)
    	REFERENCES artist(id);
    	
    	
ALTER TABLE release_rating
    	ADD CONSTRAINT fk_release_rating_release
    	FOREIGN KEY (release)
    	REFERENCES album(id);
    	
    	
ALTER TABLE track_rating
    	ADD CONSTRAINT fk_track_rating_track
    	FOREIGN KEY (track)
    	REFERENCES track(id);
    	
    	
ALTER TABLE label_rating
    	ADD CONSTRAINT fk_label_rating_track
    	FOREIGN KEY (label)
    	REFERENCES label(id);
    	
COMMIT;
