-- Abstract: Create rating tables
  	
\set ON_ERROR_STOP  
  	
BEGIN;

-- Add aggregate rating fields on _meta tables   	
   	
ALTER table artist_meta ADD COLUMN rating       REAL;
ALTER table artist_meta ADD COLUMN rating_count INTEGER;
   	
ALTER table label_meta ADD COLUMN rating       REAL;
ALTER table label_meta ADD COLUMN rating_count INTEGER;
   	
ALTER table track_meta ADD COLUMN rating       REAL;
ALTER table track_meta ADD COLUMN rating_count INTEGER;
   	
ALTER table albummeta ADD COLUMN rating       REAL;
ALTER table albummeta ADD COLUMN rating_count INTEGER;
   	
COMMIT;
