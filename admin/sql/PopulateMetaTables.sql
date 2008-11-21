\set ON_ERROR_STOP 1

BEGIN;

select fill_album_meta();

-- Change the default values to NULL
ALTER TABLE artist_meta ALTER COLUMN lastupdate SET DEFAULT NULL;
ALTER TABLE label_meta ALTER COLUMN lastupdate SET DEFAULT NULL;

TRUNCATE TABLE artist_meta;
INSERT INTO artist_meta (id) SELECT id FROM artist;

TRUNCATE TABLE label_meta;
INSERT INTO label_meta (id) SELECT id FROM label;

TRUNCATE table track_meta;
INSERT INTO track_meta (id) SELECT id FROM track;

-- Change the default values to now()
ALTER TABLE artist_meta ALTER COLUMN lastupdate SET DEFAULT NOW();
ALTER TABLE label_meta ALTER COLUMN lastupdate SET DEFAULT NOW();

COMMIT;

