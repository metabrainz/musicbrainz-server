\set ON_ERROR_STOP 1

BEGIN;

select fill_album_meta();

--TRUNCATE TABLE artist_meta;
--INSERT INTO artist_meta (id, lastupdate) SELECT id, NULL FROM artist;

--TRUNCATE TABLE label_meta;
--INSERT INTO label_meta (id, lastupdate) SELECT id, NULL FROM label;

--TRUNCATE table track_meta;
--INSERT INTO track_meta (id) SELECT id FROM track;

COMMIT;

