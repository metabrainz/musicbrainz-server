DROP AGGREGATE join(VARCHAR);
DROP FUNCTION join_append(VARCHAR, VARCHAR);

DROP FUNCTION fill_album_meta();
DROP FUNCTION insert_album_meta();
DROP FUNCTION update_album_meta();
DROP FUNCTION a_ins_albumjoin();
DROP FUNCTION a_upd_albumjoin();
DROP FUNCTION a_del_albumjoin();
DROP FUNCTION b_del_albumjoin();
DROP FUNCTION a_ins_album_cdtoc();
DROP FUNCTION a_upd_album_cdtoc();
DROP FUNCTION a_del_album_cdtoc();
DROP FUNCTION after_update_moderation_open();
DROP FUNCTION before_insertupdate_release();
DROP FUNCTION set_album_firstreleasedate(INTEGER);
DROP FUNCTION a_ins_release();
DROP FUNCTION a_upd_release();
DROP FUNCTION a_del_release();
DROP FUNCTION set_album_asin(INTEGER);
DROP FUNCTION a_ins_album_amazon_asin ();
DROP FUNCTION a_upd_album_amazon_asin ();
DROP FUNCTION a_del_album_amazon_asin ();
DROP FUNCTION a_ins_puidjoin();
DROP FUNCTION a_upd_puidjoin();
DROP FUNCTION a_del_puidjoin();
DROP FUNCTION a_iu_entity();
DROP FUNCTION b_del_entity();

-- vi: set ts=4 sw=4 et :
