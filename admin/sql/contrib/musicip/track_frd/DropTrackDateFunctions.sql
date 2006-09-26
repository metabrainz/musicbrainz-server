\set ON_ERROR_STOP 1

--'-----------------------------------------------------------------
-- Populate the track_firstreleasedate table, one-to-one join with track.
-- All columns are non-null integers, except firstreleasedate
-- which is CHAR(10) WITH NULL
--'-----------------------------------------------------------------

DROP FUNCTION fill_track_firstreleasedate ();
DROP FUNCTION set_album_firstreleasedate_frd(INTEGER);
DROP FUNCTION a_ins_release_frd ();
DROP FUNCTION a_upd_release_frd ();
DROP FUNCTION a_del_release_frd ();
DROP FUNCTION set_track_firstreleasedate_frd(INTEGER, INTEGER);
DROP FUNCTION a_ins_albumjoin_frd ();
DROP FUNCTION a_upd_albumjoin_frd ();
DROP FUNCTION a_del_albumjoin_frd ();

--'-- vi: set ts=4 sw=4 et :
