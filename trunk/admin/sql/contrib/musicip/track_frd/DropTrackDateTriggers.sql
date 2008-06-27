\set ON_ERROR_STOP 1

DROP TRIGGER a_ins_release_frd ON release;
DROP TRIGGER a_upd_release_frd ON release;
DROP TRIGGER a_del_release_frd ON release;

DROP TRIGGER a_ins_albumjoin_frd ON albumjoin;
DROP TRIGGER a_upd_albumjoin_frd ON albumjoin;
DROP TRIGGER a_del_albumjoin_frd ON albumjoin;

DROP TRIGGER a_ins_track_frd ON track;
DROP TRIGGER b_del_track_frd ON track;

-- vi: set ts=4 sw=4 et :
