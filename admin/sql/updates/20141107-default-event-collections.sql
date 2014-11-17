\set ON_ERROR_STOP 1
BEGIN;

INSERT INTO editor_collection (editor, gid, name, public, description, type) 
   SELECT id, generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/user/' || id::varchar || '/collection/attending'), 'Attending', TRUE, 'A list of events I attended or plan to attend', 5 FROM editor WHERE NOT deleted;
INSERT INTO editor_collection (editor, gid, name, public, description, type) 
   SELECT id, generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/user/' || id::varchar || '/collection/maybeattending'), 'Maybe attending', TRUE, 'A list of events I might attend', 6 FROM editor WHERE NOT deleted;

COMMIT;
