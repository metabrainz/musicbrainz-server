\set ON_ERROR_STOP 1
BEGIN;

INSERT INTO editor_collection (editor, name, public, description, type) 
   SELECT (id, 'Attending', 1, 'A list of events I attended or plan to attend', 5) FROM editor WHERE deleted = 0;
INSERT INTO editor_collection (editor, name, public, description, type) 
   SELECT (id, 'Maybe attending', 1, 'A list of events I might attend', 6) FROM editor WHERE deleted = 0;

COMMIT;
