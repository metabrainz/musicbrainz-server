\set ON_ERROR_STOP 1

BEGIN;

select fill_album_meta();

truncate table artist_meta;
INSERT INTO artist_meta (id) SELECT id FROM artist;

truncate table label_meta;
INSERT INTO label_meta (id) SELECT id FROM label;

truncate table track_meta;
INSERT INTO track_meta (id) SELECT id FROM track;

COMMIT;

