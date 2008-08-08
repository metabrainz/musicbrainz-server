-- Abstract: Create rating tables
  	
\set ON_ERROR_STOP  
  	
BEGIN;

-- Add aggregate rating fields on _meta tables   	
   	
ALTER table artist_meta ADD COLUMN rating       REAL;
ALTER table artist_meta ADD COLUMN rating_count INTEGER DEFAULT 0;
   	
ALTER table label_meta ADD COLUMN rating       REAL;
ALTER table label_meta ADD COLUMN rating_count INTEGER DEFAULT 0;
   	
ALTER table track_meta ADD COLUMN rating       REAL;
ALTER table track_meta ADD COLUMN rating_count INTEGER DEFAULT 0;
   	
ALTER table albummeta ADD COLUMN rating       REAL;
ALTER table albummeta ADD COLUMN rating_count INTEGER DEFAULT 0;
   	
COMMIT;
