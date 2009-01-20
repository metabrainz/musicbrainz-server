\set ON_ERROR_STOP 1

BEGIN;

-- IMPORTANT: This script should only be run on non-SLAVE servers

DROP TRIGGER a_del_album ON album;
DROP FUNCTION delete_album_meta();

-- drop triggers
-- drop functions
-- create functions
-- create triggers

-- foreign keys
ALTER TABLE artist_meta
    	ADD CONSTRAINT fk_artist_meta_artist
    	FOREIGN KEY (id)
    	REFERENCES artist(id)
    	ON DELETE CASCADE;
    	
ALTER TABLE label_meta
    	ADD CONSTRAINT fk_label_meta_label
    	FOREIGN KEY (id)
    	REFERENCES label(id)
    	ON DELETE CASCADE;
    	
ALTER TABLE track_meta
    	ADD CONSTRAINT fk_track_meta_track
    	FOREIGN KEY (id)
    	REFERENCES track(id)
    	ON DELETE CASCADE;
    	
ALTER TABLE albummeta
    ADD CONSTRAINT albummeta_fk_album
    FOREIGN KEY (id)
    REFERENCES album(id)
    ON DELETE CASCADE;

COMMIT;

