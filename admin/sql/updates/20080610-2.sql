\set ON_ERROR_STOP 1

BEGIN;

-- IMPORTANT: This script should only be run on non-SLAVE servers

-- drop triggers
-- drop functions
-- create functions
-- create triggers

-- foreign keys
ALTER TABLE artist_meta
    	ADD CONSTRAINT fk_artist_meta_artist
    	FOREIGN KEY (id)
    	REFERENCES artist(id);
    	
ALTER TABLE label_meta
    	ADD CONSTRAINT fk_label_meta_label
    	FOREIGN KEY (id)
    	REFERENCES label(id);
    	
ALTER TABLE track_meta
    	ADD CONSTRAINT fk_track_meta_track
    	FOREIGN KEY (id)
    	REFERENCES track(id);
    	
COMMIT;

