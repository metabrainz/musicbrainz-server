BEGIN;

DELETE FROM artist_name WHERE name = '';
ALTER TABLE artist_name ADD CHECK (name != '');

DELETE FROM label_name WHERE name = '';
ALTER TABLE label_name ADD CHECK (name != '');

DELETE FROM release_name WHERE name = '';
ALTER TABLE release_name ADD CHECK (name != '');

DELETE FROM work_name WHERE name = '';
ALTER TABLE work_name ADD CHECK (name != '');

COMMIT;
