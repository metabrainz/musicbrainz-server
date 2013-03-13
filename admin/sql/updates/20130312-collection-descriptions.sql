BEGIN; 
ALTER TABLE editor_collection ADD COLUMN description TEXT DEFAULT '' NOT NULL; 
COMMIT;
