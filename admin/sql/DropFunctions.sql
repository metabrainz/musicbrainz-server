DROP AGGREGATE join(VARCHAR);
DROP FUNCTION join_append(VARCHAR, VARCHAR);

DROP FUNCTION fill_album_meta();
DROP FUNCTION insert_album_meta();
DROP FUNCTION delete_album_meta();
DROP FUNCTION a_ins_albumjoin();
DROP FUNCTION a_upd_albumjoin();
DROP FUNCTION a_del_albumjoin();
DROP FUNCTION a_ins_discid();
DROP FUNCTION a_upd_discid();
DROP FUNCTION a_del_discid();
DROP FUNCTION a_ins_trmjoin();
DROP FUNCTION a_upd_trmjoin();
DROP FUNCTION a_del_trmjoin();
DROP FUNCTION before_update_moderation();
DROP FUNCTION before_insertupdate_release();
DROP FUNCTION set_album_firstreleasedate(INTEGER);
DROP FUNCTION a_ins_release();
DROP FUNCTION a_upd_release();
DROP FUNCTION a_del_release();

-- vi: set ts=4 sw=4 et :
