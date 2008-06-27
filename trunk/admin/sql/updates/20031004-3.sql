-- Abstract: change old albummeta functions and triggers to new ones

\set ON_ERROR_STOP 1

BEGIN;

DROP TRIGGER a_del_album ON album;
DROP TRIGGER a_ins_album ON album;
DROP TRIGGER a_del_albumjoin ON albumjoin;
DROP TRIGGER a_ins_albumjoin ON albumjoin;
DROP TRIGGER a_upd_discid_2 ON discid;
DROP TRIGGER a_upd_discid_1 ON discid;
DROP TRIGGER a_del_discid ON discid;
DROP TRIGGER a_ins_discid ON discid;
DROP TRIGGER a_del_trmjoin ON trmjoin;
DROP TRIGGER a_ins_trmjoin ON trmjoin;
DROP TRIGGER b_upd_moderation ON moderation;

DROP AGGREGATE join(VARCHAR);
DROP FUNCTION join_append(VARCHAR, VARCHAR);

DROP FUNCTION fill_album_meta();
DROP FUNCTION insert_album_meta();
DROP FUNCTION delete_album_meta();
DROP FUNCTION increment_track_count();
DROP FUNCTION decrement_track_count();
DROP FUNCTION increment_discid_count();
DROP FUNCTION decrement_discid_count();
DROP FUNCTION increment_trmid_count();
DROP FUNCTION decrement_trmid_count();
DROP FUNCTION before_update_moderation();

\i admin/sql/CreateFunctions.sql
\i admin/sql/CreateTriggers.sql

SELECT fill_album_meta();

DELETE FROM album WHERE id IN (SELECT id FROM albummeta WHERE tracks = 0 AND discids = 0);

UPDATE album SET name = '[non-album tracks]' WHERE name = 'Non-album tracks';

COMMIT;
